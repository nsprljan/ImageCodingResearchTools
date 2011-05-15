function script_channel_performance(method_hndl,hmany,CRC_siz,chnlname)
%i.e. hmany=200000, parametar=-2:0.5:7;
% RCPC{1}='1/1';ls{1}='--';lw{1}=1;lb{1}='k';lm{1}='x';
% RCPC{2}='8/9';ls{2}='-';lw{2}=1;lb{2}='k';lm{2}='*';
% RCPC{3}='4/5';ls{3}='-.';lw{3}=2;lb{3}='k';lm{3}='s';
% RCPC{4}='2/3';ls{4}=':';lw{4}=2;lb{4}='k';lm{4}='o';
% RCPC{5}='4/7';ls{5}='--';lw{5}=2;lb{5}='k';lm{5}='*';
% RCPC{6}='1/2';ls{6}='-';lw{6}=2;lb{6}='k';lm{6}='+';
% RCPC{7}='4/9';ls{7}='-.';lw{7}=2;lb{7}='k';lm{7}='d';
% RCPC{8}='2/5';ls{8}=':';lw{8}=2;lb{8}='k';lm{8}='^';
% RCPC{9}='4/11';ls{9}='--';lw{9}=2;lb{9}='k';lm{9}='v';
% RCPC{10}='1/3';ls{10}='-';lw{10}=2;lb{10}='k';lm{10}='h';

RCPC{1}='1/1';ls{1}='--';lw{1}=2;lb{1}='k';lm{1}='x';
RCPC{2}='8/9';ls{2}='-';lw{2}=2;lb{2}='yellow';lm{2}='*';
RCPC{3}='4/5';ls{3}='-';lw{3}=2;lb{3}='magenta';lm{3}='s';
RCPC{4}='2/3';ls{4}='-';lw{4}=2;lb{4}='cyan';lm{4}='o';
RCPC{5}='4/7';ls{5}='-';lw{5}=2;lb{5}='red';lm{5}='+';
RCPC{6}='1/2';ls{6}='-';lw{6}=2;lb{6}='green';lm{6}='d';
RCPC{7}='4/9';ls{7}='-';lw{7}=2;lb{7}='blue';lm{7}='^';
RCPC{8}='2/5';ls{8}='-';lw{8}=2;lb{8}='yellow';lm{8}='v';
RCPC{9}='4/11';ls{9}='-';lw{9}=2;lb{9}='magenta';lm{9}='x';
RCPC{10}='1/3';ls{10}='-';lw{10}=2;lb{10}='k';lm{10}='h';

[ch_handle,parametar]=get_channel(chnlname);
parametar.gain=0;
packet_siz=parametar.Nch;
%COMMENT THIS BELOW AND UNCOMMENT 'load' LINE TO LOAD PREVIOUSLY SAVED RESULTS
 for i=1:10     
    [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(RCPC{i});
    [PunctIndFull,PacketData,DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz);
    [BER(i),PER(i)]=feval(method_hndl,hmany,packet_siz,chnlname,RCPC{i},CRC_siz,0); %RCPC_test_equal_packet
end;
% save(['.\RCPC_performance\RCPC_performance_' chnlname],'BER','PER');
% load(['.\RCPC_performance\RCPC_performance_' chnlname],'BER','PER');
set(0,'Units','pixels');
scnsize = get(0,'ScreenSize');

ticks=[1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1];
%BER
lb=floor(log10(min(BER(BER>0))));
figure('Position',[1 scnsize(4)/4 scnsize(3) 2*scnsize(4)/5]);
berh=axes('Box','on','FontSize',14,'Position',[0.13  0.20  0.80  0.75],...
    'XLim',[1 10],'XGrid','on','XTick',1:10,'XTickLabel',RCPC,...
    'YScale','log','YLim',[10^lb 0.5],'YGrid','on','YTick',ticks(end+lb:end));
y=ylabel('{\it\epsilon}','FontName','Times New Roman','FontSize',24,'Rotation',0);
x=xlabel('RCPC code','FontName','Times New Roman','FontSize',24);
line('Parent',berh,'XData',1:10,'YData',BER,'LineStyle','-','LineWidth',2,'Color','k','Marker','o','MarkerSize',8);
%enable for small plot
set(berh,'FontSize',10);
set(x,'FontSize',16);
set(y,'FontSize',16);
set(gcf,'Position',[100 100 352 240]);

%PER
lp=floor(log10(min(PER(PER>0))));
figure('Position',[1 scnsize(4)/4 scnsize(3) 2*scnsize(4)/5]);
perh=axes('Box','on','FontSize',14,'Position',[0.13  0.20  0.80  0.75],...
    'XLim',[1 10],'XGrid','on','XTick',1:10,'XTickLabel',RCPC,...
    'YScale','log','YLim',[10^lp 1],'YGrid','on','YTick',ticks(end+lp:end));
y=ylabel('{\it\rho}','FontName','Times New Roman','FontSize',24,'Rotation',0);
x=xlabel('RCPC code','FontName','Times New Roman','FontSize',24);
line('Parent',perh,'XData',1:10,'YData',PER,'LineStyle','-','LineWidth',2,'Color','k','Marker','o','MarkerSize',8);
%enable for small plot
set(perh,'FontSize',10);
set(x,'FontSize',16);
set(y,'FontSize',16);
set(gcf,'Position',[100 100 352 240]);