function [A,H,V,D]=dwt_2D(X,wavelet)
%Two-dimensional separable DWT
%[A,H,V,D]=dwt_2D(X,wavelet)
%
%Input: 
% X - matrix to be transformed containing the input signal
% wavelet - wavelet identification string, or wavelet data structure
%     
%Output: 
% A,H,V,D - approximation signal, horizontal, vertical and diagonal details
%           signal
%
%Uses:
% load_wavelet.m
% dwt_dim.m
% subband.m
%
%Example:
% [A,H,V,D] = dwt_2D(X,'CDF_9x7');

%load the wavelet here
if ischar(wavelet)
    wvf = load_wavelet(wavelet);
else
    wvf = wavelet;
end;

X = dwt_dim(X,1,wvf); %columns
X = dwt_dim(X,2,wvf); %rows

A = subband(X,1,'ll');
H = subband(X,1,'hl');
V = subband(X,1,'lh');
D = subband(X,1,'hh');
