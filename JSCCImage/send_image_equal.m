function [PSNR,PSNRmean,PSNRcum,Phi09,PhiPSNRmax,PSNRmax]=send_image_equal(imgname,trans_time,chnlname,PunctRate,hmany,gain)

PSNR=0;PSNRmean=0;PSNRcum=0;Phi09=0;PhiPSNRmax=0;PSNRmax=0;
CRC_siz=16;
A=imread(imgname);
%get the parameters of the selected channel
[ch_handle,parametar]=get_channel(chnlname);
parametar.gain=gain;
packet_siz=parametar.Nch;
%compute parameters of the selected RCPC code
[Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(PunctRate);
fprintf('Mother code rate: 1/%d\n',PN/P);
fprintf('Puncturing code rate: %d/%d\n',length(PunctInd),PN);
fprintf('Total rate: %d/%d\n',Ib,Kb);
[PunctIndFull,PacketData,DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
channel_bits=(parametar.Bch*trans_time)/1000;
fprintf('Computed channel bits: %f\n',channel_bits);
num_packets=floor(channel_bits/packet_siz); %number of packets that satisfy the time condition
Av_channel_bits=num_packets*packet_siz;
fprintf('Available channel bits: %f\n',Av_channel_bits);
fprintf('Data bits per packet: %f\n',PacketData);
data_bits=PacketData*num_packets;
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

MSEuk=0;
for j=1:hmany
    fprintf('%d\n',j);
    DetectedErr=0;
    CRCDetErr=0;
    for i=1:num_packets
        InPckt=InputStream((i-1)*PacketData+1:i*PacketData); 
        CRC=generic_crc(InPckt,CRC_siz);
        %Convolutional encoding + puncturing
        OutputStreamPunct=RCPC_encode([CRC InPckt],Memory,t,P,PunctIndFull); % OutputStreamPunct is bipolar!!
        [OutputStreamPunctCh,parametar]=feval(ch_handle,OutputStreamPunct,parametar); %Power of the signal is now 1, i.e. 0dBW
        %Viterbi decoding
        CRCOutPckt=RCPC_decode(OutputStreamPunctCh,Memory,t,PunctIndFull,DepunctLen,PacketData+CRC_siz);
        OutPckt=CRCOutPckt(CRC_siz+1:end);
        if CRC_siz>0 %check CRC
            CRC=CRCOutPckt(1:CRC_siz);
            CRCerr=any(generic_crc(OutPckt,CRC_siz)~=CRC);
            DetectedErr=DetectedErr+CRCerr;
        end;
        if DetectedErr break;end;    
    end;
    if ~DetectedErr i=i+1;end;
    ind=floor(((i-1)*PacketData)/8);      
    if ind==0 ind=1;end;
    MSE(j)=MSE_RD8(ind);
    PSNR(j)=PSNR_RD8(ind);
    fprintf('PSNR = %f\n',PSNR(j));
    MSEuk=MSEuk+MSE(j);
    parametar.state=-1;
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