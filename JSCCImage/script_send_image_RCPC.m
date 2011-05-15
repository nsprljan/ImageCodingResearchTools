function script_send_image_RCPC(imgname,trans_time,chnlname,dir,method_hndl,hmany,RCPCind,varargin)
%Equal protection - method_hndl=@send_image_equal
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
gain=0;
gains=zeros(1,10);
status=mkdir(dir);
% for j=1:length(RCPCind)
%      i=RCPCind(j);
%      %load([dir '\' chnlname 'RCPC' num2str(i)],'PSNR','PSNRmean','PSNRcum','Phi09','PhiPSNRmax','PSNRmax');
%      [PSNR,PSNRmean,PSNRcum,Phi09,PhiPSNRmax,PSNRmax]=feval(method_hndl,imgname,trans_time,chnlname,RCPC{i},hmany,gain,varargin{:}); 
%      %PhiPSNRmax=sum(PSNRcum==PSNRmax)/1000;
%      save([dir '\' chnlname 'RCPC' num2str(i)],'PSNR','PSNRmean','PSNRcum','Phi09','PhiPSNRmax','PSNRmax');
% end;
set(0,'Units','pixels');
scnsize = get(0,'ScreenSize');
ticks=0.1:0.1:1;
xdat=1/hmany:1/hmany:1;
figure;
for i=1:10 ticksc{i}=[num2str(round(ticks(i)*100)) '%'];end;
ah=axes('XLim',[0 1],'Box','on','FontSize',14,'XGrid','on','XTick',ticks,'XTickLabel',ticksc);
ylabel('{\itPSNR} [dB]','FontName','Times New Roman','FontSize',24);
xlabel('\Phi','FontName','Times New Roman','FontSize',24);
minPSNR=Inf;maxPSNR=0;
for i=1:10
    load([dir '\' chnlname 'RCPC' num2str(i)],'PSNR','PSNRmean','PSNRcum','Phi09','PhiPSNRmax','PSNRmax');
    minPSNR=min(minPSNR,PSNRcum(end));
    maxPSNR=max(maxPSNR,PSNRcum(1));
    if isempty(findstr('BSC',chnlname))
    gains(i)=compute_gain(imgname,PSNRmean,chnlname,gain);
    end;
    fprintf('\n Rate %s, PSNRmean=%f, Phi09=%f, PSNRmax=%f, PhiPSNRmax=%f, Gain=%f\n',RCPC{i},PSNRmean,Phi09,PSNRmax,PhiPSNRmax,gains(i));
    line('Parent',gca,'XData',xdat,'YData',PSNRcum,'Tag',RCPC{i},'LineStyle',ls{i},'LineWidth',lw{i},'Color',lb{i}); 
    PSNRmeans(i)=PSNRmean;
    Phi09s(i)=Phi09;
    PSNRmaxs(i)=PSNRmax;
    PhiPSNRmaxs(i)=PhiPSNRmax;   
end;
assignin('base','PSNRmean',PSNRmeans);
assignin('base','gain',gains);
assignin('base','Phi09',Phi09s);
assignin('base','PSNRmax',PSNRmaxs);
assignin('base','PhiPSNRmax',PhiPSNRmaxs);

set(ah,'YLim',[floor(minPSNR) ceil(maxPSNR)]);
legend(RCPC{1},RCPC{2},RCPC{3},RCPC{4},RCPC{5},RCPC{6},RCPC{7},RCPC{8},RCPC{9},RCPC{10});

figure('Position',[1 scnsize(4)/4 scnsize(3) 2*scnsize(4)/5]);
bh=axes('XLim',[1 10],'YLim',[floor(min(PSNRmeans)) ceil(max(PSNRmeans))],'Box','on','FontSize',14,'XGrid','on','XTick',1:10,'XTickLabel',RCPC,'Position',[0.1300  0.2100  0.7750  0.7150]);
ylabel('{\itPSNR} [dB]','FontName','Times New Roman','FontSize',24);
xlabel('RCPC kod','FontName','Times New Roman','FontSize',24);
line('Parent',bh,'XData',1:10,'YData',PSNRmeans,'LineStyle','-','LineWidth',2,'Color','k');
h=axes('Position',[0 0 1 1],'Visible','off','XLim',[0 1],'YLim',[0 1]); %dummy axes
line('Parent',h,'XData',[0.061035 0.061035],'YData',[0.57915 0.36091]);

if any(gains)
    figure('Position',[1 scnsize(4)/4 scnsize(3) 2*scnsize(4)/5]);
    bh=axes('XLim',[1 10],'YLim',[floor(min(gains)) ceil(max(gains))],'Box','on','FontSize',14,'XGrid','on','XTick',1:10,'XTickLabel',RCPC,'Position',[0.1300  0.2100  0.7750  0.7150]);
    ylabel('{\itg} [dB]','FontName','Times New Roman','FontSize',24);
    xlabel('RCPC kod','FontName','Times New Roman','FontSize',24);
    line('Parent',bh,'XData',1:10,'YData',gains,'LineStyle','-','LineWidth',2,'Color','k');   
end;
