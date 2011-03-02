function [a,d] = dwt_conv1D(x,wvf)
%DWT of a 1D signal in convolution implementation
%[a,d]=dwt_conv1D(x,wvf)
%
%Input: 
% x - signal to be transformed
% wvf - wavelet identification string, or wavelet data structure
%     
%Output: 
% a - approximation (low-pass) signal
% d - detail (high-pass) signal
%
%Note:
% TODO: handle the situation where the signal is shorter than what the 
% extension requires. Different extensions.
%
%Uses:
% load_wavelet.m
%
%Example:
% [a,d] = dwt_conv1D(x,wvf);
% [a,d] = dwt_conv1D(x,'CDF_9x7');

if ischar(wvf)
    wvf = load_wavelet(wvf);
end;
sym_ext = false;
if (strcmp(wvf.wvf_type,'symmetric_even') || strcmp(wvf.wvf_type,'symmetric_odd'))
 sym_ext = true;
end;

%low-pass filtering
Lle = -1 * wvf.filt_H0_delay(1); %left extension length
Lre = wvf.filt_H0_delay(end); %right extension length
if (sym_ext)
    %setup the indices by using the symmetric extension
    I = [(Lle+1):-1:2 1:length(x) (length(x)-1):-1:(length(x) - Lre)];
else
    %setup the indices by using the periodic extension
    I = [(length(x) - Lle):(length(x)-1) 1:length(x) 1:Lre]; 
end;
h0 = fliplr(wvf.filt_H0);
%oversampled approximation signal
ao = conv2(x(I),h0,'valid');
%downsample
a = ao(1:2:end);

%high-pass filtering
Hle = -1 * wvf.filt_H1_delay(1); %left extension
Hre = wvf.filt_H1_delay(end); %right extension
if (sym_ext)
    %setup the indices by using the symmetric extension
    I = [(Hle+1):-1:2 1:length(x) (length(x)-1):-1:(length(x) - Hre)];
else
    %setup the indices by using the periodic extension
    I = [(length(x) - Hle):(length(x)-1) 1:length(x) 1:Hre]; 
end;
h1 = fliplr(wvf.filt_H1);
%oversampled approximation signal
do = conv2(x(I),h1,'valid');
%downsample
d = do(1:2:end);
