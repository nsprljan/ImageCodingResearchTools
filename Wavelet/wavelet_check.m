function [ort,Er,Vr]=wavelet_check(wvf,lvls)
%Lists properties of a wavelet and performs several tests
%[ort,Er,Vr]=wavelet_check(wvf,lvls)
%
%Input:
% wvf - wavelet identification string, or wavelet data structure
% lvls  - levels of iteration for computation of wavelet and scaling
%         functions (used only when the results of tests are displayed)
%
%Output:
% ort - specifies orthogonality of the wavelet:
%        'b'-biorthogonal;
%        'o'-orthogonal;
%        'n'-none
% Er - error energy contribution ratio between the high-pass and low-pass
%      subband
% Vr - error energy ratio between the reconstructed even and odd 
%      samples. Even samples are coincide with the low-pass subsampling 
%      position, while the odd coincide with the high-pass.
%
%Note:
% The function displays (if there are no output arguments):
%  -filter taps for both analysis and synthesis;
%  -the number of vanishing moments;
%  -the result of the orthogonality test;
%  -DC and Nyquist gain, and L1 and L2 norms;
%  -Time-Frequency localisation measure;
%  -the result of the Perfect Recostruction (PR) property test for a array of
%   random size and content. Two tests: one for periodic and one for symmetric
%   extension on the matrix borders.
%  -PCR = Peak cyclostationary reconstruction error ratio (maximum
%  variation of the expected error in the reconstructed samples)
%
%Uses:
% load_wavelet.m
% wavelet_fun.m
% get_sf.m
%
%Example:
% wavelet_check('CDF_9x7',3);

if (nargout > 0) %display only if output is not defined
    disp = 0;
else
    disp = 1;
end;
if nargin < 2
    lvls = 1;
end;
if ischar(wvf)
    wvf = load_wavelet(wvf);
end;
lLD=length(wvf.filt_H0);
lHD=length(wvf.filt_H1);
lLR=length(wvf.filt_G0);
lHR=length(wvf.filt_G1);
if disp
    fprintf('Analysis (decomposition) filters (H0 taps, H1 taps) = (%d,%d)\n',lLD,lHD);
    fprintf('H0 taps = [');
    for i=1:lLD
        fprintf('%1.5f',wvf.filt_H0(i));
        if (i ~=lLD) 
            fprintf(' '); 
        else 
            fprintf(']\n');
        end;
    end;
    fprintf('H1 taps = [');
    for i=1:lHD
        fprintf('%1.5f',wvf.filt_H1(i));
        if (i ~=lHD) 
            fprintf(' '); 
        else 
            fprintf(']\n');
        end;
    end;
    fprintf('H0 (DC,Nyquist) gain = (%f,%f) \n',...
        abs(sum(wvf.filt_H0)),abs(sum(wvf.filt_H0(mod(wvf.filt_H0_delay,2) == 0)) - sum(wvf.filt_H0(mod(wvf.filt_H0_delay,2) ~= 0))));
    fprintf('H1 (DC,Nyquist) gain = (%f,%f) \n',...
        abs(sum(wvf.filt_H1)),abs(sum(wvf.filt_H1(mod(wvf.filt_H1_delay,2) == 0)) - sum(wvf.filt_H1(mod(wvf.filt_H1_delay,2) ~= 0))));
    fprintf('\nSynthesis (reconstruction) filters (H0 taps, H1 taps) = (%d,%d)\n',lLR,lHR);
    fprintf('H0 taps = [');
    for i=1:lLR
        fprintf('%1.5f',wvf.filt_G0(i));
        if (i ~=lLR) 
            fprintf(' '); 
        else 
            fprintf(']\n');
        end;
    end;
    fprintf('H1 taps = [');
    for i=1:lHR
        fprintf('%1.5f',wvf.filt_G1(i));
        if (i ~=lHR) 
            fprintf(' '); 
        else 
            fprintf(']\n');
        end;
    end;
    fprintf('H0 (DC,Nyquist) gain = (%f,%f) \n',...
        abs(sum(wvf.filt_G0)),abs(sum(wvf.filt_G0(mod(wvf.filt_G0_delay,2) == 0)) - sum(wvf.filt_G0(mod(wvf.filt_G0_delay,2) ~= 0))));
    fprintf('H1 (DC,Nyquist) gain = (%f,%f) \n',...
        abs(sum(wvf.filt_G1)),abs(sum(wvf.filt_G1(mod(wvf.filt_G1_delay,2) == 0)) - sum(wvf.filt_G1(mod(wvf.filt_G1_delay,2) ~= 0))));    
end;
%INSTRUCTION: change norm_tolerance depending on how precise the coefficients have to be
norm_tolerance = 10^(-6);
%simple orthogonality check
tmpLoF_D = wvf.filt_H0 / sum(abs(wvf.filt_H0));
tmpHiF_D = wvf.filt_H1 / sum(abs(wvf.filt_H1));
tmpHiF_R = wvf.filt_G1 / sum(abs(wvf.filt_G1));
if (lLD==lHD) && all(abs(tmpLoF_D)-fliplr(abs(tmpHiF_D)) < norm_tolerance)
    ort='o';
elseif (lLD==lHR) && all(abs(tmpLoF_D)-fliplr(abs(tmpHiF_R)) < norm_tolerance)
    ort='b';
else
    ort='n';
end;
%Er
Er = sum(wvf.filt_G1.^2)/sum(wvf.filt_G0.^2);
HiRodd = mod(wvf.filt_G1_delay,2) == 1;
LoRodd = mod(wvf.filt_G0_delay,2) == 1;
%Vr - for the (e,o) downsampling lattice
%even samples
emse_Lo = sum(wvf.filt_G0(~LoRodd).^2);
emse_Hi = sum(wvf.filt_G1(HiRodd).^2);
%odd samples
omse_Lo = sum(wvf.filt_G0(LoRodd).^2);
omse_Hi = sum(wvf.filt_G1(~HiRodd).^2);
Vr = (omse_Lo + omse_Hi) / (emse_Lo + emse_Hi);
%Vr - for the (e,e) downsampling lattice
Vree = (omse_Lo + emse_Hi) / (emse_Lo + omse_Hi);
%%%DISPLAY SECTION%%%
if disp
    fprintf('\nOrthogonality (test) = ');
    switch ort
        case 'o'
            fprintf('orthogonal (o)');
        case 'b'
            fprintf('biorthogonal (b)')
        case 'n'
            fprintf('none (n)');
    end;
    fprintf('\nH0/H1 L2 norms ratio = %f',sqrt(Er));
    fprintf('\no/e reconstructed error energies ratio, (e,o) lattice = %f',Vr);
    fprintf('\n                                        (e,e) lattice = %f',Vree);
    fprintf('\nOrthonormality parameter = %f',orthnormpar(wvf.filt_H0,wvf.filt_H1));
    %vanishing moments for decomposition wavelet
    %INSTRUCTION: change moment_tolerance depending on how precise the computation has to be
    moment_tolerance = 10^(-1);
    plypnts=0:lHD-1;
    %plypnts = plypnts./sum(plypnts);
    mmntD=0;summnt=0;
    while abs(summnt) < moment_tolerance;
        polyf=plypnts.^mmntD;
        summnt=sum(wvf.filt_H1.*polyf);
        mmntD=mmntD+1;
    end;
    %vanishing moments for reconstruction wavelet
    plypnts=0:lHR-1;
    mmntR=0;summnt=0;
    while abs(summnt) < moment_tolerance;
        polyf=plypnts.^mmntR;
        summnt=sum(wvf.filt_G1.*polyf);
        mmntR=mmntR+1;
    end;
    mmnt=[mmntD-1 mmntR-1]; %number of the vanishing moments of the wavelet; 
    %mmnt(1) given by test performed on the analysis HP filter, and mmnt(2) 
    %on the synthesis HP    
    fprintf('\nVanishing moments (test) = (%d,%d)',mmnt(1),mmnt(2));
    %Time-frequency localisation
    [TFL,t,w]=tfl(wvf.filt_G1);
    fprintf('\nTime-frequency localisation wavelet f. (t, w) = %f (%f, %f)',TFL, t, w);    
    [TFL,t,w]=tfl(wvf.filt_G0);
    fprintf('\nTime-frequency localisation scaling f. (t, w) = %f (%f, %f)',TFL, t, w);
    fprintf('\n\n');
    bgl = ones(lvls+1,1);
    bgh = ones(lvls+1,1);
    bglcum = zeros(lvls,1);
    bghcum = zeros(lvls,1);
    sigma = cell(lvls + 1);
    sigma{1} = 1;
    eLo_left = abs(min(wvf.filt_G0_delay(~LoRodd))/2);
    oLo_left = abs(min(wvf.filt_G0_delay(LoRodd)+1)/2);
    %even samples
    eLo = wvf.filt_G0(~LoRodd).^2;
    eHi = wvf.filt_G1(HiRodd).^2;
    %odd samples
    oLo = wvf.filt_G0(LoRodd).^2;
    oHi = wvf.filt_G1(~HiRodd).^2;
    fprintf('level  L2(G0)   L2(G1)   dBIBO(L) dBIBO(H) PCR(e,o)\n');
    for i=1:lvls
        fprintf('%2d     ',i);
        AL = scaling_fun(wvf,i-1,'d');
        AH = wavelet_fun(wvf,i-1,'d');
        SL = scaling_fun(wvf,i-1,'r');
        SH = wavelet_fun(wvf,i-1,'r');     
        %L2
        fprintf('%.5f  ',sqrt(sum(SL.^2)));
        fprintf('%.5f  ',sqrt(sum(SH.^2)));
        %BIBO
        bgl(i+1) = sum(abs(AL));
        bglcum(i) = bgl(i+1) / bgl(i);
        bgh(i+1) = sum(abs(AH));
        bghcum(i) = bgh(i+1) / bgl(i);
        fprintf('%.5f  ',bglcum(i));
        fprintf('%.5f  ',bghcum(i));
        %PCR
        sigmaeven = circonv(sigma{i},eLo,eLo_left) + sum(eHi);
        sigmaodd = circonv(sigma{i},oLo,oLo_left) + sum(oHi);
        sigma{i+1} = zeros(1,length(sigmaeven) + length(sigmaodd));       
        sigma{i+1}(1:2:end) = sigmaeven;
        sigma{i+1}(2:2:end) = sigmaodd;
        fprintf('%.5f ( ',max(sigma{i+1})/min(sigma{i+1}));
        fprintf('%.2f ',sigma{i+1})
        fprintf(')\n');
    end;
    %test to see how similar are the result of DWI in lifting and convolution 
    %implementations
     test_signal_size=32;
     x=rand(1,test_signal_size);
     [al,dl] = dwt_lifting1D(x,wvf);
     [ac,dc] = dwt_conv1D(x,wvf);
     fprintf('\nSum of absolute differences (lifting - convolution), low-pass = %f, high-pass = %f\n',...
         sum(abs(al - ac)),sum(abs(dl - dc)));     
     yl = idwt_lifting1D(al,dl,wvf);
     yc = idwt_conv1D(ac,dc,wvf);
     fprintf('Sum of absolute differences to original, lifting = %f, convolution = %f\n',...
         sum(abs(yl - x)),sum(abs(yc - x)));
end;


function OP=orthnormpar(LoF_Dx,HiF_Dx)
%Orthonormality parameter, as in:
%M. Lightstone & E. Majani, “Low bit-rate design considerations for wavelet
% -based image coding,” VCIP, vol. 2308, pp. 501-512, September 1994.
%
%OP = 0 for orthonormal wavelets
%
%ON = int((2-O(w))^2)
%O(w) = H0(w)*H0(-w)+H1(w)*H1(-w)

%inserting zeroes
nl = length(LoF_Dx);
nh = length(HiF_Dx);
n = max(nl,nh);
LoF_D = zeros(1,n);
HiF_D = zeros(1,n);
nl1 = 1 + floor((n-nl) / 2);
LoF_D(nl1:nl1+nl-1) = LoF_Dx;
nl2 = 1 + floor((n-nh) / 2);
HiF_D(nl2:nl2+nh-1) = HiF_Dx;

OP = 4 - 4*(sum(LoF_D.^2) + sum(HiF_D.^2));
LM = LoF_D'*LoF_D;
HM = HiF_D'*HiF_D;
LHM = LoF_D'*HiF_D;
[X,Y] = meshgrid(1:length(LoF_D));
I = X+Y;
for i=1:size(LM,1)
    for j=1:size(LM,2)
        indices = find(I == I(i,j));
        Lsum = sum(LM(indices));
        Hsum = sum(HM(indices));
        LHsum = sum(LHM(indices));
        OP = OP + LM(i,j) * Lsum + 2 * LHM(i,j) * LHsum + HM(i,j) * Hsum;
    end;
end;

function [TFL,delta_t,delta_w]=tfl(h)
%[TFL,delta_t,delta_w] = tfl(h)
%Time-Frequency Localization measure of a wavelet
% 
%Input:
% h - wavelet coefficients
%
%Output:
% TFL - Time Frequency Localization measure
% delta_t - measure of localisation in time domain
% delta_w - measure of localisation in frequency domain
%
%Note:
% delta_t and delta_w are computed as variances in time and frequency domain,
% and multiplied they give TFL.
%
%Uses:
% load_wavelet.m
%
%Example:
% [TFL,t,w]=tfl('db2','l');
% [TFL,t,w]=tfl('bior4.4','r');
% [TFL,t,w]=tfl('haar','h');

fftL=65536;
%total energy of the sequence
%time domain
E=sum(h.^2);
%frequency domain
Hw=(1/fftL)*abs(fft(h,fftL)).^2; %normalized to sum of 1 for orthogonal case
%Hws=sum(Hw) %Energy obtained from the frequency domain
%the centre of mass of the sequence
n=1:length(h);
tm=sum(n.*(h.^2))/E;
%frequency domain
w=1:fftL/2;
Hw=Hw(w);
%the centre of mass in the frequency domain, normalized to 2pi
wm=0; %for low-pass
%wm=sum(Hw.*(2*pi*(w-1)/fftL))/(E/2); %for band-pass
delta_t=sqrt((1/E)*sum(((n-tm).*h).^2));
delta_w=sqrt( (1/(E/2)) * sum(Hw.*((2*pi*w/fftL-wm).^2) ));
TFL=delta_t*delta_w;

function xc=circonv(x,y,yc) 
%circular convolution
%yc is the length of the y on the left of the central pixel
if (~isvector(x) || ~isvector(y))
    error('Input parameters must be vectors!');
end;
if (size(x,1)>1)
    x = x';
end;    
if (size(y,1)>1)
    y = y';
end;    
xl = length(x);
yl = length(y);
N = lcm(xl,yl);
xe = repmat(x,[1 N/xl]);
ye = zeros(1,N);
ye(1:yl) = y;
xc = ifft(fft(xe).*fft(ye));
xc = xc(1:xl);
%xc = xc((yc+1):(yc+xl));