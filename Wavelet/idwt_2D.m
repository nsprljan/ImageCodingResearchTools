function Y = idwt_2D(A,H,V,D,wavelet)
%Two-dimensional separable IDWT
%Y=idwt_2D(A,H,V,D,wavelet)
%
%Input:
% A,H,V,D - approximation signal, horizontal, vertical and diagonal details
%           signal
% wavelet - wavelet identification string, or wavelet data structure
%     
%Output: 
% Y - reconstructed matrix
%
%Uses:
% load_wavelet.m
% idwt_dim.m
%
%Example:
% Y = idwt_2D(A,H,V,D,'CDF_9x7');

%load the wavelet here
if ischar(wavelet)
    wvf = load_wavelet(wavelet);
else
    wvf = wavelet;
end;
Y = [A H;V D];
Y = idwt_dim(Y,2,wvf); %rows
Y = idwt_dim(Y,1,wvf); %columns
