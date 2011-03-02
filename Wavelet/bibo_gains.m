function [bgl,bgh,bglcum,bghcum]=bibo_gains(wavelet,n)
%Computes BIBO(Bounded Input Bounded Output) gains of a wavelet
%[bgl,bgh,bglcum,bghcum]=bibo_gains(wavelet,n)
%
%Input: 
% wavelet - wavelet identification string
% n - number of maximum decomposition levels for which gain will be computed
%
%Output: 
% bgl - vector of BIBO gains for low-pass filter
% bgh - vector of BIBO gains for high-pass filter 
% bglcum - vector of cumulative BIBO gains for low-pass filter
% bghcum - vector of cumulative BIBO gains for high-pass filter
%
%Note:
% The function displays result if there are no output arguments specified.
%
%Uses: 
% scaling_fun.m
% wavelet_fun.m
%
%Example:
% [bgl,bgh,bglcum,bghcum]=bibo_gains('CDF_9x7',15);

if (nargout > 0) %display only if output is not defined
    disp = 0;
else
    disp = 1;
end;
bgl = zeros(n,1);
bgh = zeros(n,1);
bglcum = zeros(n,1);
bghcum = zeros(n,1);
for i=0:n-1
    lp = scaling_fun(wavelet,i,'d');
    bgl(i+1) = sum(abs(lp));
    if (i > 0)
        bglcum(i + 1) = bgl(i + 1) / bgl(i);
    else
        bglcum(1) =  bgl(1);
    end;
    hp = wavelet_fun(wavelet,i,'d');
    bgh(i+1) = sum(abs(hp));
    if (i > 0)
        bghcum(i + 1) = bgh(i + 1) / bgh(i);
    else
        bghcum(1) =  bgh(1);
    end;
end;
if disp
    fprintf('Low-pass filter (H0) BIBO gains (cumulative)= ');
    for i=1:n
        fprintf('%.2f(%.2f) ',bgl(i),bglcum(i));
    end;
    fprintf('\nHigh-pass filter (H1) BIBO gains (cumulative)= ');
    for i=1:n
        fprintf('%.2f(%.2f) ',bgh(i),bghcum(i));
    end;
    fprintf('\n');
end;

 