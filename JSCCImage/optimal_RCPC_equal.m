function [equal_RCPC,minD_equal]=optimal_RCPC_equal(trans_time,CRC_siz,chnlname,RDfile,draw)
%
%the variable MSE_RD8 contains the Rate-Distortion curve of an image
%encoded with SPIHT, measured at byte points. On the other hand, num_bits 
%specifies the number of bits, so for each consecutive 8 bits the RD value
%of an image will be the same. The difference in performance due to this 
%lack of precision should be negligible. 

prob_res=1000;
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
if findstr(draw,'draw')
    %figure for results
    set(0,'Units','pixels');
    scnsize = get(0,'ScreenSize');
    ticks=0.1:0.1:1;
    xdat=1/prob_res:1/prob_res:1;
    fig=figure;
    for i=1:10 ticksc{i}=[num2str(round(ticks(i)*100)) '%'];end;
    if strcmp(draw,'draw_small')
     ah=axes('XLim',[0 1],'Box','on','FontSize',10,'XGrid','on','XTick',ticks,'XTickLabel',ticksc);
     ylabel('{\itPSNR} [dB]','FontName','Times New Roman','FontSize',16);
     xlabel('\Phi','FontName','Times New Roman','FontSize',16);
    else
     ah=axes('XLim',[0 1],'Box','on','FontSize',14,'XGrid','on','XTick',ticks,'XTickLabel',ticksc);
     ylabel('{\itPSNR} [dB]','FontName','Times New Roman','FontSize',24);
     xlabel('\Phi','FontName','Times New Roman','FontSize',24);  
    end;
end; 
minPSNR=Inf;maxPSNR=0;
%get channel parameters
[ch_handle,parametar]=get_channel(chnlname);
packet_siz=parametar.Nch;
channel_bits=(parametar.Bch*trans_time)/1000;
num_packets=floor(channel_bits/packet_siz); %number of packets that satisfy the time condition
%load BER and PER charateristics
load(['.\RCPC_performance\RCPC_performance_' chnlname],'BER','PER');
%load the pre-computed byte-precision R-D curve
load(['.\RD_curve\' RDfile],'PSNR_RD8','MSE_RD8');

min_MSE=Inf;
prob_arrival=zeros(1,num_packets+1);
MSE=zeros(1,num_packets+1);
for i=1:10
    [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(RCPC{i});
    [PunctIndFull,PacketData(i),DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
    total_bits=num_packets*PacketData(i);
    avg_bits=0;
    avg_MSE_cur=0;
    pckt_error=PER(i);
    pckt_correct=1-PER(i);
    %prob_arrival=zeros(1,num_packets);
    for j=0:num_packets
        num_bits=j*PacketData(i);
        if j==num_packets
            prob_arrival(j+1)=(pckt_correct^j);  
            %avg_bits=avg_bits+prob_arrival*num_bits;
        else
            prob_arrival(j+1)=(pckt_correct^j)*pckt_error;  
            %avg_bits=avg_bits+prob_arrival*num_bits;
        end;
        if num_bits==0
            MSE(j+1)=MSE_RD8(1);
        else
            %MSE=MSE_RD8(floor(num_bits/8));
            MSE(j+1)=MSE_RD8(floor(num_bits/8));
        end;
        avg_MSE_cur=avg_MSE_cur+prob_arrival(j+1)*MSE(j+1);
    end;
    avg_MSE(i)=avg_MSE_cur;
    %phi_PSNR to figure  
    phi_PSNR=probMSE2phi(prob_res,prob_arrival,MSE);
    minPSNR=min([minPSNR phi_PSNR]);
    maxPSNR=max([maxPSNR phi_PSNR]);
    if findstr(draw,'draw')
        line('Parent',gca,'XData',xdat,'YData',phi_PSNR,'Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i});
        %results to command prompt
        fprintf('RCPC total rate: %d/%d - ',Ib,Kb);
        %fprintf('Average number of bits received correctly: %f\n',avg_bits);
        %fprintf('Average MSE: %f\n',avg_MSE(i));
        fprintf('average PSNR: %f\n',10*log10(255^2/avg_MSE(i)));
    end;
    if avg_MSE(i)<min_MSE
        min_MSE=avg_MSE(i);
        minD_ind=i;
    end;
end;
if findstr(draw,'draw')
    %figure adjustment
    set(ah,'YLim',[floor(minPSNR) ceil(maxPSNR)]);
    legend(RCPC{1},RCPC{2},RCPC{3},RCPC{4},RCPC{5},RCPC{6},RCPC{7},RCPC{8},RCPC{9},RCPC{10});
    if findstr(draw,'draw_small')
        set(fig,'Position',[100 100 352 288],'Units','pixels'); 
    end;
end;
%results to command prompt
fprintf('***\nMinimal distortion RCPC code: %s\n',RCPC{minD_ind});
fprintf('PSNR: %f',10*log10(255^2/min_MSE));
equal_RCPC=minD_ind;
minD_equal=min_MSE;