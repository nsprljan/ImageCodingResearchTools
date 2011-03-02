function hn=scaling_fun(wavelet,n,type,plt)
%Computes (and plots) samples of the scale function
%hn=scaling_fun(wavelet,n,type,plt)
%
%Input:
% wavelet - wavelet identification string
% n - number of successive approximation iterations
% type - specifies wavelet
%         if (type == 'd') analysis (decomposition) filter
%         if (type == 'r') synthesis (reconstruction) filter
% plt - [optional, default = 'stairs']
%        if (plt == 'plot') then plots the scaling function using 'plot'
%        if (plt == 'stairs') then plots the scaling function using 'stairs'
%        Note that the stem plot is used if n is 0.
%
%Output:
% hn - n-th approximation of the scaling function
%
%Note:
% If n is 0, then use stem instead of plot. Also, if output defined, does
% not plot at all.
%
%Uses:
% load_wavelet.m
%
%Example: 
% scaling_fun('CDF_9x7',5,'d','plot');
% h = scaling_fun('LeGall_5x3',0,'r');

if (nargin <= 3)
    plt = 'stairs';
end;
if (nargout > 0) %display only if output is not defined
    plt = '';
end;
if ischar(wavelet)
    wvf = load_wavelet(wavelet);
    waveletstr = wavelet;
else
    wvf = wavelet;
    waveletstr = '';    
end;
if (type == 'd')
    hl = wvf.filt_H0;
    delay = wvf.filt_H0_delay;
    figstr = [waveletstr ' analysis, '];  
elseif (type == 'r')
    hl = wvf.filt_G0;
    delay = wvf.filt_G0_delay;    
    figstr = [waveletstr ' synthesis, '];  
else
    error('Wavelet type wrong - choose ''d'' for analysis (decomposition) filter or ''r'' for synthesis (reconstruction) filter!');
end;

hn = hl;
if (n > 0)
    %hl = 2*hl./sum(hl); %normalise to 2, to preserve the amplitude range    
    for i=1:n
        hnn = zeros(1,max(length(hn)*2 - 1,2));
        hnn(1:2:end) = hn;
        hn = conv(hnn,hl);
    end;
end;
hn = fliplr(hn);
if ~isempty(plt)
    support_length=length(hl);
    k = (length(hn) - 1)/max((support_length - 1),1); %factor k to normalize support
    sr = (support_length - 1) / 2;
    x = -sr:1/k:sr;
    figstr = [figstr num2str(n) ' iterations'];
    figure('NumberTitle','off','Name',figstr);
    if (n > 0)
        xpartback = 1/k:1/k:0.5;
        xback = [-sr-fliplr(xpartback) x sr+xpartback];
        hnback = zeros(size(xback)); %for the background plot
        startback = ceil(0.5*k);
        hnback(startback:startback+length(hn)-1) = hn;
        if strcmp(plt,'plot')
            plot(xback,hnback,'Linewidth',1,'Color','k');
            hold on;
            plot(x,hn,'Linewidth',2.5,'Color','k');
        elseif strcmp(plt,'stairs')
            stairs([(xback-1/(2*k)) (xback(end)+1/(2*k))],[hnback hnback(end)],'Linewidth',1,'Color','k');
            hold on;
            stairs([(x-1/(2*k)) (x(end)+1/(2*k))],[hn hn(end)],'Linewidth',2.5,'Color','k');
        end;
        if (type == 'd')
            titlstr = '$$\tilde{\varphi}(t)$$';
        elseif (type == 'r')
            titlstr = '$$\varphi \; \, (t)$$'; %space is added to comepnsate for bug when saving into eps
        end;
        set(gca,'YTick',[]); %disable ticks to hide the scaling difference
        xlim([-sr-0.5 sr+0.5]);
        xlabel('$t$','interpreter','latex','FontSize',20);       
    else
        stem(delay,hn,'Linewidth',1.5,'Color','k');
        if (type == 'd')
            titlstr = '$$h_{0,n}$$';
        elseif (type == 'r')
            titlstr = '$$g_{0,n}$$';
        end;
        set(gca,'XTick',delay);
        xlim([delay(1)-0.5 delay(end)+0.5]);
        xlabel('$n$','interpreter','latex','FontSize',20);
    end;
    title(titlstr,'interpreter','latex','FontSize',20); %interpreter should be the first parameter!
    set(gca,'FontSize',15,'LineWidth',2,'FontName','Times New Roman','Box','on');
    ymargin = 0.1*max(max(hn),abs(min(hn)));
    ylim([min(0,min(hn))-ymargin max(hn)+ymargin]);
    set(gca,'Position',[0.075 0.1100 0.85 0.7750]); %shifted to fit the title
    %set(gcf,'Color','w');
end;