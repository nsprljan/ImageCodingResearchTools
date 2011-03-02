function [f1freq,f1phase,f2freq,f2phase]=wavelet_char(wavelet1,wavelet2,type,plt)
%Computes (and plots) frequency and phase charateristic of a wavelet
%[f1freq,f1phase,f2freq,f2phase]=wavelet_char(wavelet1,wavelet2,type,plt)
%
%Input: 
% wavelet1 - identification string of the first wavelet 
% wavelet2 - identification string of the second wavelet 
% type - specifies wavelet type
%         if ('d' in type) analysis (decomposition) filter
%         if ('r' in type) synthesis (reconstruction) filter
%         if ('l' in type) then low-pass
%         if ('h' in type) then high-pass
% plt - [optional, default = ''] 
%        if (plt == 'plot') then plots the characteristics
%
%Output: 
% f1freq,f2freq - frequency charateristics
% f1phase,f2phase - phase charateristics
%
%Uses: 
% load_wavelet.m
%
%Note: 
% Number of discrete frequencies in which transfer function is computed is 
% specified by wsamples variable
%
%Example:
% wavelet_char('CDF_9x7','Haar','dl','plot');
% [f1f,f1p]=wavelet_char('haar','haar','d');

%CONSTANTS
wnumsamples=1024; %change this to change sampling of the frequency axis
w = 0:pi/(wnumsamples-1):pi;
%set to 1 to enable display of the freqency characteristic of convolution
%of two dispalayed filters
%show_convolved = 0; 
%set to true to enable displays the power spectrum characterstic of the two
%displayed filters, or the P_0(z) halfband filter
show_power_spectrum = true;
%
two_wavelets = false;
if nargin<=3
    plt='';
end;
if strcmp(wavelet1,wavelet2) %if it is the same wavelet
    wvf=load_wavelet(wavelet1);
    switch type(1)
        case 'd'
            filter1 = wvf.filt_H0;
            leg1='$|H_0(z)|$';
            filter2 = wvf.filt_H1;
            leg2='$|H_1(z)|$';
            leg3='$S(z)$'; %S(z) = (|H_0(z)|^2 + |H_1(z)|^2)/2
            leg1ph='$\arg(H_0(z))$';
            leg2ph='$\arg(H_1(z))$';  
        case 'r'
            filter1 = wvf.filt_G0;
            leg1='$|G_0(z)|$';
            filter2 = wvf.filt_G1;
            leg2='$|G_1(z)|$';
            leg3='$|S(z)|$'; %S(z) = (|H_0(z)|^2 + |H_1(z)|^2)/2
            leg1ph='$\arg(G_0(z))$';
            leg2ph='$\arg(G_1(z))$';             
        case 'l'
            filter1 = wvf.filt_H0;
            leg1='$|H_0(z)|$';
            filter2 = wvf.filt_G0;
            leg2='$|G_0(z)|$'; 
            leg3='$|P_0(z)|$'; %|P_0(z)| = |H_0(z) * G_0(z)| == |H_0(z) * H_1(-z)|
            leg1ph='$\arg(H_0(z))$';
            leg2ph='$\arg(G_0(z))$';               
        case 'h'
            filter1 = wvf.filt_H1;
            leg1='$|H_1(z)|$';
            filter2 = wvf.filt_G1;
            leg2='$|G_1(z)|$';
            leg3='$|P_0(-z)|$'; %|P_0(-z)| = |H_0(-z) * H_1(z)| == |-G_1(z) * H_1(z)|
            leg1ph='$\arg(H_1(z))$';
            leg2ph='$\arg(G_1(z))$';             
        otherwise
            error('Option for type not correct!');            
    end;
else
    wvf1=load_wavelet(wavelet1);
    wvf2=load_wavelet(wavelet2);
    two_wavelets = true;
    switch type
        case {'dl','ld','l'}
            filter1 = wvf1.filt_H0;
            leg1=['$|H_0(z)|$ wavelet1'];
            filter2 = wvf2.filt_H0;
            leg2=['$|H_0(z)|$ wavelet2'];
            leg1ph=['$\arg(H_0(z))$ wavelet1'];
            leg2ph=['$\arg(H_0(z))$ wavelet2'];
        case {'dh','hd','d'}
            filter1 = wvf1.filt_H1;
            leg1=['$|H_1(z)|$ wavelet1'];
            filter2 = wvf2.filt_H1;
            leg2=['$|H_1(z)|$ wavelet2'];
            leg1ph=['$\arg(H_1(z))$ wavelet1'];
            leg2ph=['$\arg(H_1(z))$ wavelet2'];
        case {'rl','lr','r'}
            filter1 = wvf1.filt_G0;
            leg1=['$|G_0(z)|$ wavelet1'];
            filter2 = wvf2.filt_G0;
            leg2=['$|G_0(z)|$ wavelet2'];
            leg1ph=['$\arg(G_0(z))$ wavelet1'];
            leg2ph=['$\arg(G_0(z))$ wavelet2'];
        case {'rh','hr','h'}
            filter1 = wvf1.filt_G1;
            leg1=['$|G_1(z)|$ wavelet1'];
            filter2 = wvf2.filt_G1;
            leg2=['$|G_1(z)|$ wavelet2'];
            leg1ph=['$\arg(G_1(z))$ wavelet1'];
            leg2ph=['$\arg(G_1(z))$ wavelet2'];
        otherwise
            error('Option for type not correct!');
    end;
end;

[f1freq, f1phase, F1]=freqphase(filter1, w);
[f2freq, f2phase, F2]=freqphase(filter2, w);

if strcmp(plt,'plot')
 wavelet1=strrep(wavelet1,'_','');
 wavelet2=strrep(wavelet2,'_',''); 
 %%%frequency plot%%%
 maxf1freq=max(f1freq(:));
 maxf2freq=max(f2freq(:));
 maxyos=1.1*max([maxf1freq maxf2freq]);
 if (two_wavelets)
     figstr = ['Wavelet filter z-transfer function (' wavelet1 ',' wavelet2 ')'];
 else
     figstr = ['Wavelet filter z-transfer function (' wavelet1 ')'];
 end;     
 figure('Name',figstr,'NumberTitle','off');
 hold on;
 plot(w,f1freq,'-k',w,f2freq,'-r','LineWidth',2);
%  if (show_convolved == 1)
%     f3freq=freqphase(conv(filter1, filter2), w);
%     maxyos=max([1.1*max(f3freq(:)) maxyos]);
%     plot(w,f3freq,'-y','LineWidth',2);
%  end;
 if (show_power_spectrum && ~two_wavelets)
     if ((type(1) == 'l') || (type(1) == 'h'))
       f4freq = F1.*F2;
     else
       f4freq = (abs(F1).^2)/2 + (abs(F2).^2)/2;
     end;
     maxyos=max([1.1*max(abs(f4freq(:))) maxyos]);
     plot(w,abs(f4freq),'--g','LineWidth',2);
 end;
 set(gca,'Position',[0.075 0.1100 0.85 0.7750],'FontName','Times New Roman','FontSize',14,'Box','on','LineWidth',2);
 if (two_wavelets)
     al = legend(leg1,leg2,'Location','Best');
 else
     al = legend(leg1,leg2,leg3,'Location','Best');
 end;
 set(al,'interpreter','latex');
 set(gca,'LineWidth',2);
 axis([0 pi 0 maxyos]);
 grid on;
 %x axis
 set(gca,'XTick',0:pi/4:pi,'XTickLabel',{});
 text(pi/2,-maxyos/30,'$0 \hspace{47pt} \pi/4  \hspace{47pt} \pi/2  \hspace{47pt} 3\pi/4 \hspace{47pt} \pi$',...
     'FontSize',14,'HorizontalAlignment','center','interpreter','latex');
 text(pi/2,-maxyos/10,'$\omega$','FontSize',20,'HorizontalAlignment','center','interpreter','latex');
 %y axis
 set(gca,'YTick',0:0.2:maxyos);
 %plot(x,f1freq,'-y',x,f2freq,'-k',x,W3(,'-b','LineWidth',2); %FIR example leftover
 hold off;
 
 %%%phase plot%%%
 if (two_wavelets)
     figstr = ['Wavelet filter phase characteristic (' wavelet1 ',' wavelet2 ')'];
 else
     figstr = ['Wavelet filter phase characteristic (' wavelet1 ')'];
 end;
 figure('Name',figstr,'NumberTitle','off');
 hold on;
 plot(w,f1phase,'-k',w,f2phase,'-r','LineWidth',2);
 set(gca,'Position',[0.075 0.1100 0.85 0.7750],'FontName','Times New Roman','FontSize',14,'Box','on','LineWidth',2);
 al = legend(leg1ph,leg2ph,'Location','Best');
 set(al,'interpreter','latex');
 set(gca,'LineWidth',2);
 axis([0 pi -pi pi]);
 grid on; 
 %x axis
 set(gca,'XTick',0:pi/4:pi,'XTickLabel',{});
 text(pi/2,-pi-2*pi/30,'$0 \hspace{47pt} \pi/4  \hspace{47pt} \pi/2  \hspace{47pt} 3\pi/4 \hspace{47pt} \pi$',...
     'FontSize',14,'HorizontalAlignment','center','interpreter','latex');
 text(pi/2,-pi-2*pi/10,'$\omega$','FontSize',20,'HorizontalAlignment','center','interpreter','latex'); 
 %y axis
 set(gca,'YTick',-pi:pi/2:pi,'YTickLabel',{}); 
 prop_name(1)={'FontSize'};
 properti(1)={14};
 prop_name(2)={'HorizontalAlignment'};
 properti(2)={'right'};
 prop_name(3)={'interpreter'};
 properti(3)={'latex'};
 text(-0.05,pi,'$\pi$',prop_name,properti);
 text(-0.05,pi/2,'$\pi/2$',prop_name,properti);
 text(-0.05,0,'$0$',prop_name,properti);
 text(-0.05,-pi/2,'$-\pi/2$',prop_name,properti);
 text(-0.05,-pi,'$-\pi$',prop_name,properti);
 %text(-0.4,0,'\Phi(\omega)','FontSize',20,'Rotation',90,'HorizontalAlignment','center');
 hold off;
end;

function [freq, phase, F]=freqphase(filter, w)
%frequency and phase characteristic computed by the z-transform
wsamples = length(w);
W = repmat(w,[length(filter) 1]);
z = cos(W)+i*sin(W);
n = 0:-1:-length(filter)+1;
N = repmat(n',[1 wsamples]);
F = repmat(filter',[1 wsamples]);
F = sum(F.*(z.^N),1); %sums along columns 
freq=abs(F);
phase=angle(F);
%%computed by FFT 
%filter1
% f1freq = abs(fft(filter1,wsamples*2));
% f1freq = f1freq(1:size(f1freq,2)/2);
% %filter2
% f2freq = abs(fft(filter2,wsamples*2));
% f2freq = f2freq(1:size(f2freq,2)/2);
% % h = fir1(20,1/2); %FIR example leftover
% % W3=abs(fft(h,wsamples*2)); %FIR example leftover
% % W3 = W3(1:size(W3,2)/2);
