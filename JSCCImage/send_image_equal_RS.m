function [PSNR,PSNRmean,PSNRcum,Phi09,PhiPSNRmax,PSNRmax]=send_image_equal_RS(imgname,trans_time,chnlname,PunctRate,hmany,gain,dps,RSsyms)

PSNR=0;PSNRmean=0;PSNRcum=0;Phi09=0;PhiPSNRmax=0;PSNRmax=0;
CRC_siz=16;
dps=15;
A=imread(imgname);
%get the parameters of the selected channel
[ch_handle,parametar]=get_channel(chnlname);
parametar.gain=gain;
packet_siz=parametar.Nch;
Ni=floor((1/dps)/(packet_siz/parametar.Bch));

%compute parameters of the selected RCPC code
[Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(PunctRate);
fprintf('Mother code rate: 1/%d\n',PN/P);
fprintf('Puncturing code rate: %d/%d\n',length(PunctInd),PN);
fprintf('Total rate: %d/%d\n',Ib,Kb);
[PunctIndFull,PacketData,DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
PacketUnused=mod(PacketData,8); %solve this!!
PacketData=PacketData-PacketUnused;
PacketBytes=PacketData/8;
Unusedbits=zeros(1,PacketUnused);
channel_bits=(parametar.Bch*trans_time)/1000;
fprintf('Computed channel bits: %f\n',channel_bits);
num_packets=floor(channel_bits/packet_siz); %number of packets that satisfy the time condition
last_pckts=mod(num_packets,Ni);
data_per_intlvd=Ni-RSsyms;
last_RS_packet=floor(num_packets/Ni)*data_per_intlvd;
data_Packets=last_RS_packet+last_pckts;
Av_channel_bits=num_packets*packet_siz;
fprintf('Available channel bits: %f\n',Av_channel_bits);
fprintf('Data bits per packet: %f\n',PacketData);
data_bits=PacketData*data_Packets;
bpp=data_bits/numel(A);
fprintf('Effective bpp: %f\n',bpp);
%compute the actual bitstream
bpp_byte=8*ceil(data_bits/8)/numel(A);
N=log2(size(A,1))-2;
[Arec,bitstream,PSNR,MSE,D,Drec,s,p_stream]=spiht_wpackets(A,bpp_byte,'CDF_9x7',N);
InputStream=bitstream(1,1:data_bits);
%load the pre-computed byte-precision R-D curve
[pathstr,filename]=fileparts(imgname);
load([filename 'RD'],'PSNR_RD8','MSE_RD8');

errpckt=zeros(1,num_packets);
InPckts=zeros(1,PacketData*Ni);
MSEuk=0;
RSindices=data_per_intlvd*PacketData+1:Ni*PacketData;
for j=1:hmany
    fprintf('%d\n',j);
    DetectedErr=0;
    RSsymbols=RSsyms;
    data_per_intlvd=Ni-RSsyms;
    Ni_cur=Ni;
    for i=1:data_per_intlvd:data_Packets
        if i>=last_RS_packet 
            data_per_intlvd=data_Packets-i+1;
            RSsymbols=0;
            Ni_cur=data_per_intlvd;
        end; %last packets are reached
        InPckts(1:data_per_intlvd*PacketData)=InputStream((i-1)*PacketData+1:(i+data_per_intlvd-1)*PacketData);
        if RSsymbols
            %InPcktsInt=bi2de(reshape(InPckts,[8 length(InPckts)/8])');
            %InPcktsGF=reshape(InPcktsInt,[PacketBytes data_per_intlvd]);
            %msg=gf(InPcktsGF,8); 
            %RScoded=rsenc(msg,Ni,data_per_intlvd);
            %de2bi(double(RScoded'))
            InPckts(RSindices)=randint(length(RSindices),1,2)'; %heh, only simulation of RS -> fooled ya!!
        end;
        OutputStreamPunct=zeros(1,data_per_intlvd*packet_siz); %(data_per_intlvd,packet_siz)
        for k=0:Ni_cur-1 
            InPckt=InPckts(k*PacketData+1:(k+1)*PacketData); 
            CRC=generic_crc(InPckt,CRC_siz);
            %Convolutional encoding + puncturing
            OutputStreamPunct(1,k*packet_siz+1:(k+1)*packet_siz)=RCPC_encode([CRC InPckt Unusedbits],Memory,t,P,PunctIndFull); % OutputStreamPunct is bipolar!!
        end;
        [OutputStreamPunctCh,parametar]=feval(ch_handle,OutputStreamPunct,parametar); %Power of the signal is now 1, i.e. 0dBW
        OutputStreamPunctCh=reshape(OutputStreamPunctCh,packet_siz,Ni_cur)'; %reshape
        numCRCerr=0;
        DetectedErr=0;
        for k=0:Ni_cur-1   
            %Viterbi decoding
            CRCOutPckt=RCPC_decode(OutputStreamPunctCh(k+1,:),Memory,t,PunctIndFull,DepunctLen,PacketData+CRC_siz);
            OutPckt=CRCOutPckt(CRC_siz+1:end);
            if CRC_siz>0 %check CRC
                CRC=CRCOutPckt(1:CRC_siz);
                CRCerr=any(generic_crc(OutPckt,CRC_siz)~=CRC);
            end;
            %RS decode using erasures simulation -> fooled ya!! 
            if CRCerr
                numCRCerr=numCRCerr+1;
                if numCRCerr==1 
                    firstCRCerr=k;
                end;
                if numCRCerr>RSsymbols
                    DetectedErr=1;
                    k=firstCRCerr;
                    break;
                end;   
            end;    
        end;
        if DetectedErr
            break;
        end;
    end;
    if ~DetectedErr k=k+1;end;
    ind=((i-1+k)*PacketData)/8;
    if ind==0 ind=1;end;
    MSE(j)=MSE_RD8(ind);
    PSNR(j)=PSNR_RD8(ind);
    fprintf('PSNR = %f\n',PSNR(j));
    MSEuk=MSEuk+MSE(j);
end;

PSNRmean=10*log10(255^2/(MSEuk/hmany));
PSNRcum=fliplr(sort(PSNR));
fprintf('mean PSNR = %f\n',PSNRmean);
Phi09=PSNRcum(round(hmany*0.9));
fprintf('Phi-1(0.9) = %f\n',Phi09);
PSNRmax=PSNR_RD8(floor((data_bits)/8));
fprintf('PSNRmax = %f\n', PSNRmax);
PhiPSNRmax=sum(PSNRcum==PSNRmax)/hmany;
fprintf('Phi(PSNRmax) =%f\n',PhiPSNRmax);