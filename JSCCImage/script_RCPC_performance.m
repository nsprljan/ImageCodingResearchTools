function script_RCPC_performance(hmany,data_siz,CRC_siz,gain_vector)
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

BER=zeros(length(gain_vector),10);
PER=zeros(length(gain_vector),10);
%COMMENT THIS BELOW AND UNCOMMENT LOAD TO LOAD PREVIOUSLY SAVED RESULTS
for j=1:length(gain_vector)
  for i=1:10
   [diffvec,BER(j,i),PER(j,i)]=RCPC_test_equal_data(hmany,data_siz,'AWGN_0dB',RCPC{i},CRC_siz,gain_vector(j));  
end;
end;
% save(['.\RCPC_performance\RCPC_performance_' num2str(hmany) 'x' num2str(data_siz)],'BER','PER');
%load(['.\RCPC_performance\RCPC_performance_' num2str(hmany) 'x' num2str(data_siz)],'BER','PER');
ticks=gain_vector(1):gain_vector(end);
af=figure;
ah=axes('Parent',af,'XLim',[gain_vector(1) gain_vector(end)],'YLim',[1e-5 0.5],'Box','on','FontSize',14,'XGrid','on','YGrid','on',...
    'YScale','log','XTick',ticks,'YTick',[1e-5 1e-4 1e-3 1e-2 1e-1]);
ylabel('\it\epsilon','FontName','Times New Roman','FontSize',24,'Rotation',0);
xlabel('{\itE}_{\its}/{\itN}_0 [dB]','FontName','Times New Roman','FontSize',24);

pf=figure;
ph=axes('Parent',pf,'XLim',[gain_vector(1) gain_vector(end)],'YLim',[1e-3 1],'Box','on','FontSize',14,'XGrid','on','YGrid','on',...
    'YScale','log','XTick',ticks,'YTick',[1e-3 1e-2 1e-1]);
ylabel('\it\rho','FontName','Times New Roman','FontSize',24,'Rotation',0);
xlabel('{\itE}_{\its}/{\itN}_0 [dB]','FontName','Times New Roman','FontSize',24);

bf=figure;
bh=axes('Parent',bf,'XLim',[gain_vector(1) gain_vector(end)],'YLim',[1e-5 0.5],'Box','on','FontSize',14,'XGrid','on','YGrid','on',...
    'YScale','log','XTick',gain_vector(1):gain_vector(end)-10*log10(str2num(RCPC{end})),'YTick',[1e-5 1e-4 1e-3 1e-2 1e-1]);
ylabel('\it\epsilon','FontName','Times New Roman','FontSize',24,'Rotation',0);
xlabel('{\itE}_{\itb}/{\itN}_0 [dB]','FontName','Times New Roman','FontSize',24);

%Shannon limit
ep=logspace(-5,log10(0.5));
Hb=-ep.*log2(ep)-(1-ep).*log2(1-ep);
EsN0=0.5*(2.^(2*(1-Hb))-1);
EsN0=10*log10(EsN0+eps);

for i=1:10
    line('Parent',ah,'XData',gain_vector,'YData',BER(:,i)','Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i},'Marker',lm{i},'MarkerSize',8); 
    line('Parent',ph,'XData',gain_vector,'YData',PER(:,i)','Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i},'Marker',lm{i},'MarkerSize',7); 
    line('Parent',bh,'XData',gain_vector-10*log10(str2num(RCPC{i})),'YData',BER(:,i)','Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i},'Marker',lm{i},'MarkerSize',7); 
end;
line('Parent',bh,'XData',EsN0,'YData',ep,'Tag','Shannon','LineStyle','--','LineWidth',2,'Color','k'); 
legend(RCPC{1},RCPC{2},RCPC{3},RCPC{4},RCPC{5},RCPC{6},RCPC{7},RCPC{8},RCPC{9},RCPC{10});