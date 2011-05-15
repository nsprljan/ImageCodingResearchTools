function [equal_RS_RCPC,RSsyms,min_MSE]=optimal_RCPC_RS_equal(trans_time,CRC_siz,chnlname,Ni,RSsymsvect,RDfile,draw)

%warning off MATLAB:nchoosek:LargeCoefficient
RCPC{1}='1/1';ls{1}='--';lw{1}=1;lb{1}='k';
RCPC{2}='8/9';ls{2}='-';lw{2}=1;lb{2}='k';
RCPC{3}='4/5';ls{3}='-.';lw{3}=2;lb{3}=[0.753 0.753 0.753];
RCPC{4}='2/3';ls{4}=':';lw{4}=2;lb{4}=[0.753 0.753 0.753];
RCPC{5}='4/7';ls{5}='--';lw{5}=2;lb{5}=[0.753 0.753 0.753];
RCPC{6}='1/2';ls{6}='-';lw{6}=2;lb{6}=[0.753 0.753 0.753];
RCPC{7}='4/9';ls{7}='-.';lw{7}=2;lb{7}='k';
RCPC{8}='2/5';ls{8}=':';lw{8}=2;lb{8}='k';
RCPC{9}='4/11';ls{9}='--';lw{9}=2;lb{9}='k';
RCPC{10}='1/3';ls{10}='-';lw{10}=2;lb{10}='k';
%get channel parameters
[ch_handle,parametar]=get_channel(chnlname);
packet_siz=parametar.Nch;
for i=1:10
    [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(RCPC{i});
    [PunctIndFull,PacketData(i),DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
    DataBits(i)=floor(PacketData(i)/8)*8;
end;   
%Ni=floor((1/dps)/(packet_siz/parametar.Bch));
channel_bits=(parametar.Bch*trans_time)/1000;
num_packets=floor(channel_bits/packet_siz); %number of packets that satisfy the time condition
%load BER and PER charateristics
load(['RCPC_performance_' chnlname],'BER','PER');
%load the pre-computed byte-precision R-D curve
load(RDfile,'PSNR_RD8','MSE_RD8');  

min_MSE=Inf;
min_ind=0;
min_RSsyms=0;
lastRCPCind=10;
avgPSNRold=zeros(1,10);
%VisitedPoints=zeros(RSsymsvect(end),lastRCPCind);
for RSsyms=RSsymsvect(1):RSsymsvect(end)
    if strcmp(draw,'draw')
        fprintf('%d protection symbols ***\n',RSsyms);
    end;
    [RCPCind,minMSEsyms,avgPSNR,frstRCPCind,RCPCindmin]=RS_numsym(PER,MSE_RD8,Ni,RSsyms,DataBits,num_packets,RCPC,ls,lb,lw,lastRCPCind,draw);
    %VisitedPoints(RSsyms,frstRCPCind:lastRCPCind)=1;
    lastRCPCind=RCPCindmin;
    if ~any(avgPSNR>avgPSNRold)
        break;
    end;
    if minMSEsyms<min_MSE    
        %frstRCPCind=max(1,RCPCind-2);
        min_MSE=minMSEsyms;
        min_ind=RCPCind; 
        min_RSsyms=RSsyms;
    end;
    avgPSNRold=avgPSNR;
end;
equal_RS_RCPC=RCPC{min_ind}
RSsyms=min_RSsyms;
%results to command prompt
fprintf('\nMinimal distortion RCPC code: %s\n',equal_RS_RCPC);
fprintf('Number of protection symbols: %d\n',RSsyms);
fprintf('PSNR: %f',10*log10(255^2/min_MSE));
%VisitedPoints

function [RCPCind,minMSE,avgPSNR,i,RCPCindmin]=RS_numsym(PER,MSE_RD8,Ni,RSsyms,DataBits,num_packets,RCPC,ls,lb,lw,lastRCPCind,draw)

if strcmp(draw,'draw')
    %figure for results
    set(0,'Units','pixels');
    scnsize = get(0,'ScreenSize');
    ticks=0.1:0.1:1;
    prob_res=1000;
    xdat=1/prob_res:1/prob_res:1;
    figure;
    for i=1:10 ticksc{i}=[num2str(round(ticks(i)*100)) '%'];end;
    ah=axes('XLim',[0 1],'Box','on','FontSize',14,'XGrid','on','XTick',ticks,'XTickLabel',ticksc);
    ylabel('{\itPSNR} [dB]','FontName','Times New Roman','FontSize',24);
    xlabel('\Phi','FontName','Times New Roman','FontSize',24);
    minPSNR=Inf;maxPSNR=0;
end;
avgPSNR=zeros(1,length(RCPC));
last_pckts=mod(num_packets,Ni); %last packets without RS encoding
last_RS_packet=floor(num_packets/Ni)*(Ni-RSsyms); %last packet in last block encoded with Reed-Solomon 
data_Packets=last_RS_packet+last_pckts;
prob_arrival=zeros(1,data_Packets+1);
MSE=zeros(1,data_Packets+1);
minMSE=Inf;
currminMSE=Inf;
decr=0;
RCPCind=lastRCPCind;
i=lastRCPCind;
while i>=1
    pckt_error=PER(i);
    pckt_correct=1-PER(i);
    Pcb=prob_correct_block(PER(i),Ni,RSsyms); %block Ni is with RSsyms or less erasures
    %prob=0;
    for j=0:Ni-RSsyms
        PRSerr(j+1)=1-prob_correct_block(pckt_error,Ni-j,RSsyms-1); %probability that in Ni-j packets (symbols) there is RSsyms or more errors
        %prob=prob+(pckt_correct^(j-1))*pckt_error*PRSerr(j); 
    end;
    ProbExactNum=(pckt_correct.^(0:Ni-RSsyms-1)).*pckt_error.*PRSerr((1:Ni-RSsyms)+1);
    %sum(ProbExactNum)+Pcb %should be = 1
    
    total_bits=num_packets*DataBits(i);
    %avg_bits=0;
    avg_MSE_cur=0;
    
    data_packets=0;
    num_prev_blocks=0;
    no_pckt_block=0;
    j=0;
    while j<num_packets+1
        num_bits=data_packets*DataBits(i);
        if j>0 
            no_pckt_block=no_pckt_block+1;        
            if data_packets>last_RS_packet
                if j==num_packets
                    prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*(pckt_correct^no_pckt_block);
                    %prob_arrival(data_packets+1)=1-sum(prob_arrival(1:data_packets));                   
                else
                    prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*(pckt_correct^no_pckt_block)*pckt_error;
                end;
                %avg_bits=avg_bits+prob_arrival*num_bits;
            else     
                if mod(j+RSsyms,Ni)==0 
                    num_prev_blocks=num_prev_blocks+1;
                    if data_packets==last_RS_packet
                        if last_pckts>0
                            prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*pckt_error; 
                        else
                            prob_arrival(data_packets+1)=1-sum(prob_arrival(1:data_packets));
                            %prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*(pckt_correct^no_pckt_block); 
                        end;
                    else
                        prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*ProbExactNum(1);%pckt_error*PRSerr(1); 
                    end;
                    no_pckt_block=0;
                    j=j+RSsyms;    
                else   
                    prob_arrival(data_packets+1)=(Pcb^num_prev_blocks)*ProbExactNum(no_pckt_block+1);%(pckt_correct^no_pckt_block)*pckt_error*PRSerr(no_pckt_block+1); 
                    %avg_bits=avg_bits+prob_arrival*num_bits;
                end;      
            end;
        else
            prob_arrival(data_packets+1)=pckt_error*PRSerr(1); %probability that first packet is unrecoverable and in error
        end;
        j=j+1;
        if num_bits==0
            MSE(data_packets+1)=MSE_RD8(1);
        else
            MSE(data_packets+1)=MSE_RD8(floor(num_bits/8));
        end;
        avg_MSE_cur=avg_MSE_cur+prob_arrival(data_packets+1)*MSE(data_packets+1);
        data_packets=data_packets+1;
    end;
    avg_MSE(i)=avg_MSE_cur;
    avgPSNR(i)=10*log10(255^2/avg_MSE(i));
    
    %results to command prompt
    if strcmp(draw,'draw')
        %phi_PSNR to figure  
        phi_PSNR=probMSE2phi(prob_res,prob_arrival,MSE);
        minPSNR=min([minPSNR phi_PSNR]);
        maxPSNR=max([maxPSNR phi_PSNR]);    
        line('Parent',gca,'XData',xdat,'YData',phi_PSNR,'Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i}); 
        fprintf('Total rate: %s',RCPC{i});
        %fprintf('Average number of bits received correctly: %f\n',avg_bits);
        %fprintf('Average MSE: %f\n',avg_MSE(i));
        fprintf(' - meanPSNR: %f\n',avgPSNR(i));
    end;
    if avg_MSE(i)<currminMSE
        currminMSE=avg_MSE(i);
        RCPCindmin=i;
        decr=0;
    end;
    if avg_MSE(i)<minMSE
        minMSE=avg_MSE(i);
        RCPCind=i;
    elseif avg_MSE(i)>currminMSE
        decr=decr+1;    
    end;
    if decr>=1 & abs(avg_MSE(i)-currminMSE)/currminMSE>0.1
        break
    end;
    i=i-1;
end;
%figure adjustment
if strcmp(draw,'draw')
    set(ah,'YLim',[floor(minPSNR) ceil(maxPSNR)]);
    legend(RCPC{10:-1:i});
end;


function Pcb=prob_correct_block(ro,Ni,RSsyms)
%probability that all block packets are recoverable
factNi=prod(1:Ni);
factNi_i=factNi;
facti=1;
cmb_rec=1;
for i=1:RSsyms;
    facti=facti*i;
    factNi_i=factNi_i/(Ni-i+1);
    cmb_rec(i+1)=factNi/(facti*factNi_i);
    %cmb_rec(i+1)=nchoosek(Ni,i);
end;
Pcb=sum(cmb_rec.*ro.^(0:RSsyms).*(1-ro).^(Ni-(0:RSsyms)));