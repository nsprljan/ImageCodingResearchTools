function y = idwt_conv1D(a,d,wvf)
%IDWT of a 1D signal in convolution implementation
%y=idwt_conv1D(a,d,wvf)
%
%Input:
% a - approximation (low-pass) signal
% d - detail (high-pass) signal
% wvf - wavelet identification string, or wavelet data structure
%     
%Output: 
% y - reconstructed signal
%
%Uses:
% load_wavelet.m
%
%Note:
% TODO: handle the situation where the signal is shorter than what the 
% extension requires. Different extensions.
%
%Example:
% y = idwt_conv1D(a,d,wvf);
% y = idwt_conv1D(a,d,'CDF_9x7');

if ischar(wvf)
    wvf = load_wavelet(wvf);
end;    
sym_ext = false;
if (strcmp(wvf.wvf_type,'symmetric_even') || strcmp(wvf.wvf_type,'symmetric_odd'))
 sym_ext = true;
end;

%%low-pass filtering%%
Lle = -1 * wvf.filt_G0_delay(1); %left extension
Lre = wvf.filt_G0_delay(end); %right extension
%upsample the approximation signal
au = zeros(1, 2*length(a));
au(1:2:end) = a;
if (sym_ext)
    %setup the indices by using the symmetric extension
    I = [(Lle+1):-1:2 1:length(au) (length(au)-1):-1:(length(au) - Lre)];
else
    %setup the indices by using the periodic extension
    I = [(length(au) - Lle):(length(au)-1) 1:length(au) 1:Lre]; 
end;
g0 = fliplr(wvf.filt_G0);
%convolution
ao = conv2(au(I),g0,'valid');

%%high-pass filtering%%
Hle = -1 * wvf.filt_G1_delay(1); %left extension
Hre = wvf.filt_G1_delay(end); %right extension
%upsample the detail signal
du = zeros(1, 2*length(d));
du(2:2:end) = d; %subsampling defined so it starts on odd pixels
%Note that symmetric extension is here different since the point of
%symmetry is around odd numbered pixel!
if (sym_ext)
    %setup the indices by using the symmetric extension
    I = [(Hle+1):-1:2 1:length(du) (length(du)-1):-1:(length(du) - Hre)];
else
    %setup the indices by using the periodic extension
    I = [(length(du) - Hle):(length(du)-1) 1:length(du) 1:Hre]; 
end;
g1 = fliplr(wvf.filt_G1);
%convolution
do = conv2(du(I),g1,'valid');

%%combine%%
y = ao + do;
