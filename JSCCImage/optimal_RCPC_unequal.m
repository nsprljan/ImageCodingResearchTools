function [unequal_RCPC,unequal_data_bits,minD_unequal]=optimal_RCPC_unequal(trans_time,CRC_siz,chnlname,RDfile,draw)
%EBits=optimalRCPC(EsN0,BitTotCh,paket,CRC_size)
RCPC{1}='1/1';
RCPC{2}='8/9';
RCPC{3}='4/5';
RCPC{4}='2/3';
RCPC{5}='4/7';
RCPC{6}='1/2';
RCPC{7}='4/9';
RCPC{8}='2/5';
RCPC{9}='4/11';
RCPC{10}='1/3';
[ch_handle,parametar]=get_channel(chnlname);
packet_siz=parametar.Nch;
channel_bits=(parametar.Bch*trans_time)/1000;
num_packets=floor(channel_bits/packet_siz); %number of packets that satisfy the time condition
load(['.\RCPC_performance\RCPC_performance_' chnlname],'BER','PER');
%load the pre-computed byte-precision R-D curve
load(['.\RD_curve\' RDfile],'PSNR_RD8','MSE_RD8');  
for i=1:10
    [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(RCPC{i});
    [PunctIndFull,PacketData(i),DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
    pckt_error=PER(i);
end;   

[equal_RCPC,minD_equal]=optimal_RCPC_equal(trans_time,CRC_siz,chnlname,RDfile,'no draw');

minD_unequal=minD_equal;
pckt_RCPC=equal_RCPC;

unequal_RCPC=pckt_RCPC*ones(1,num_packets); 
data_bits=PacketData(unequal_RCPC); %how many bits each packet contains
unequal_data_bits=data_bits;
pckt_error=PER(pckt_RCPC)*ones(num_packets+1,1); %probability that current packet will be in error
unequal_pckt_error=pckt_error;
pckt_correct=1-pckt_error; %probability that previous packet is correct
pckt_correct(1)=1;
unequal_pckt_correct=pckt_correct;

minD_prev=Inf;
while minD_unequal<minD_prev
    minD_prev=minD_unequal;
[unequal_RCPC,minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct]=add_protection(unequal_RCPC,...
    minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct,MSE_RD8,PER,num_packets,PacketData);

[unequal_RCPC,minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct]=sub_protection(unequal_RCPC,...
    minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct,MSE_RD8,PER,num_packets,PacketData);
end;
fprintf('\n***\nMinimal distortion unequal protection: %f\n',minD_unequal);
fprintf('PSNR: %f\n\n',10*log10(255^2/minD_unequal));


if strcmp(draw,'draw')
    set(0,'Units','pixels');
    scnsize = get(0,'ScreenSize');
    df=figure('Position',[1 scnsize(4)/10 2*scnsize(3)/3 3*scnsize(4)/4]);
    bh=axes('Parent',df,'XLim',[1 num_packets],'YLim',[0 11],'Box','on','FontSize',14,'YGrid','on','YTick',1:10,'YTickLabel',RCPC);
    ylabel('RCPC kod','FontName','Times New Roman','FontSize',24);
    xlabel('paket','FontName','Times New Roman','FontSize',24);
    line('Parent',bh,'XData',1:num_packets,'YData',unequal_RCPC,'LineStyle','-','LineWidth',2,'Color','k');   
end;

function [unequal_RCPC,minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct]=add_protection(unequal_RCPC,...
                       minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct,MSE_RD8,PER,num_packets,PacketData);

local_depth=10;
used_RCPC=unequal_RCPC;
pckt_error=unequal_pckt_error;
pckt_correct=unequal_pckt_correct;
data_bits=unequal_data_bits;
num_rates=length(PER);

prevoius_pckts_correct=cumprod(pckt_correct);
prob_exact_num_pckts=prevoius_pckts_correct(1:end-1).*pckt_error(2:end);
prob_no_err=1-sum(prob_exact_num_pckts);
prob_exact_num_pckts=[prob_exact_num_pckts; prob_no_err];

cum_num_bits=cumsum(data_bits);
MSE_vect=[MSE_RD8(1) MSE_RD8(floor(cum_num_bits./8))];
MSE_avg=MSE_vect*prob_exact_num_pckts; 

local_cnt=0;
rate_borders=find([Inf used_RCPC]~=[used_RCPC used_RCPC(end)]);
border_rates=used_RCPC(rate_borders);
old_border_rates=Inf;
while ~isequal(old_border_rates,border_rates) & ~isempty(border_rates)
    old_border_rates=border_rates;
    if border_rates(1)==num_rates
        border_rates=border_rates(2:end);
        rate_borders=rate_borders(2:end);
    end;
    if length(rate_borders)>0 
    for rb=1:length(rate_borders) 
        packet_ind=rate_borders(rb);
        
        while packet_ind<num_packets+1 %& packet_ind<rate_borders(rb+1)
            pckt_RCPC=used_RCPC(packet_ind)+1;
            data_bits(packet_ind)=PacketData(pckt_RCPC);
            pckt_error(packet_ind)=PER(pckt_RCPC);
            pckt_correct(packet_ind+1)=1-pckt_error(packet_ind);
            
            prevoius_pckts_correct=cumprod(pckt_correct);
            prob_exact_num_pckts=prevoius_pckts_correct(1:end-1).*pckt_error(2:end);
            prob_no_err=1-sum(prob_exact_num_pckts);
            prob_exact_num_pckts=[prob_exact_num_pckts; prob_no_err];
            
            cum_num_bits=cumsum(data_bits);
            MSE_vect=[MSE_RD8(1) MSE_RD8(floor(cum_num_bits./8))];
            MSE_avg=MSE_vect*prob_exact_num_pckts; 
            if MSE_avg>=minD_unequal
                local_cnt=local_cnt+1;
                if local_cnt>=local_depth
                    local_cnt=0;
                   break;
                else
                    used_RCPC(packet_ind)=pckt_RCPC;
                end;
            else
                used_RCPC(packet_ind)=pckt_RCPC;
                
                unequal_RCPC=used_RCPC;
                unequal_data_bits=data_bits;
                unequal_pckt_error=pckt_error;
                unequal_pckt_correct=pckt_correct;
                minD_unequal=MSE_avg;
                
                rate_borders(rb)=packet_ind+1;
                border_rates(rb)=pckt_RCPC-1;
                local_cnt=0;
            end;
            packet_ind=packet_ind+1;   
        end;
        used_RCPC=unequal_RCPC;
        data_bits=unequal_data_bits;
        pckt_error=unequal_pckt_error;
        pckt_correct=unequal_pckt_correct;
    end;  
    if packet_ind==num_packets+1 
        if rate_borders(end)==num_packets+1
            rate_borders=[1 rate_borders(1:end-1)];
        elseif ~(rate_borders(1)==1)
            rate_borders=[1 rate_borders];
        end;
     end;
    border_rates=used_RCPC(rate_borders); 
end;
end; 

function [unequal_RCPC,minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct]=sub_protection(unequal_RCPC,...
    minD_unequal,unequal_data_bits,unequal_pckt_error,unequal_pckt_correct,MSE_RD8,PER,num_packets,PacketData);

local_depth=10;
used_RCPC=unequal_RCPC;
pckt_error=unequal_pckt_error;
pckt_correct=unequal_pckt_correct;
data_bits=unequal_data_bits;
num_rates=length(PER);

prevoius_pckts_correct=cumprod(pckt_correct);
prob_exact_num_pckts=prevoius_pckts_correct(1:end-1).*pckt_error(2:end);
prob_no_err=1-sum(prob_exact_num_pckts);
prob_exact_num_pckts=[prob_exact_num_pckts; prob_no_err];

cum_num_bits=cumsum(data_bits);
MSE_vect=[MSE_RD8(1) MSE_RD8(floor(cum_num_bits./8))];
MSE_avg=MSE_vect*prob_exact_num_pckts; 

local_cnt=0;
rate_borders=find(used_RCPC~=[used_RCPC(2:end) Inf]);
%rate_borders=num_packets;
border_rates=used_RCPC(rate_borders);
old_border_rates=Inf;

while ~isequal(old_border_rates,border_rates) & ~isempty(border_rates)
    old_border_rates=border_rates;
    if border_rates(1)==1
        border_rates=border_rates(2:end);
        rate_borders=rate_borders(2:end);
    end;
    if length(rate_borders)>0 
        for rb=1:length(rate_borders) 
            packet_ind=rate_borders(rb);
            while packet_ind>0 %& packet_ind<rate_borders(rb+1)
                pckt_RCPC=used_RCPC(packet_ind)-1;
                data_bits(packet_ind)=PacketData(pckt_RCPC);
                pckt_error(packet_ind)=PER(pckt_RCPC);
                pckt_correct(packet_ind+1)=1-pckt_error(packet_ind);
                
                prevoius_pckts_correct=cumprod(pckt_correct);
                prob_exact_num_pckts=prevoius_pckts_correct(1:end-1).*pckt_error(2:end);
                prob_no_err=1-sum(prob_exact_num_pckts);
                prob_exact_num_pckts=[prob_exact_num_pckts; prob_no_err];
                
                cum_num_bits=cumsum(data_bits);
                MSE_vect=[MSE_RD8(1) MSE_RD8(floor(cum_num_bits./8))];
                MSE_avg=MSE_vect*prob_exact_num_pckts; 
                if MSE_avg>=minD_unequal
                    local_cnt=local_cnt+1;
                    if local_cnt>=local_depth
                        local_cnt=0;
                        break;
                    else
                        used_RCPC(packet_ind)=pckt_RCPC;
                    end;
                else
                    used_RCPC(packet_ind)=pckt_RCPC;
                    
                    unequal_RCPC=used_RCPC;
                    unequal_data_bits=data_bits;
                    unequal_pckt_error=pckt_error;
                    unequal_pckt_correct=pckt_correct;
                    minD_unequal=MSE_avg;
                    
                    rate_borders(rb)=packet_ind-1;
                    border_rates(rb)=pckt_RCPC-1;
                    local_cnt=0;
                end;
                packet_ind=packet_ind-1;   
            end;
            used_RCPC=unequal_RCPC;
            data_bits=unequal_data_bits;
            pckt_error=unequal_pckt_error;
            pckt_correct=unequal_pckt_correct;
        end;  
            if packet_ind==0 & rate_borders(end)==0
                rate_borders=[num_packets rate_borders(1:end-1)];
            end;
        if ~(rate_borders(1)==num_packets)
                rate_borders=[num_packets rate_borders];
        end;
        border_rates=used_RCPC(rate_borders); 
    end;
end; 