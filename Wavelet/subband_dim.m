function [ld,hd,N] = subband_dim(sdim, N)
%Computes the subband dimensions for a specified number of decompositions
%[ld,hd,N]=subband_dim(sdim, N)
%
%Input:
% sdim - vector of lengths of the original signal
% N - number of signal decompositions
%
%Output:
% ld - size of the low-pass signal after N levels of decomposition
% hd - size of the high-pass signal after N levels of decomposition 
% N - number of actually performed number of decompositions
%
%Note:
% If N is too large, the function will return ld = 1, and N will equal 
% the number of allowed decompositions.
% In the smallest non-singleton dimension direction the low-pass subband 
% can have only one coefficient.
%
%Example:
% [ld,hd,N]= subband_dim(9, 3); %if upper_limit = 1 -> ld = 2, hd = 1
% [ld,hd,N]= subband_dim(100, Inf); %for max. number of decompositions

sdim = double(sdim);
ld = zeros(size(sdim));
hd = zeros(size(sdim));
n = zeros(size(sdim)); 

for d=1:length(sdim)
    if (sdim(d) == 1) %singleton dimension, skip it!
        ld(d) = 1;
        hd(d) = 1;
        n(d) = N;
    else
       n(d) = sb_dim(sdim(d),N);
    end;
end;
 
N = min(n);
for d=1:length(sdim)
 [n(d),ld(d),hd(d)] = sb_dim(sdim(d),N);
end;

function [i,ld,hd] = sb_dim(sdim,N)
ld = sdim;
hd = 0;
for i=1:N
    ldold = ld;
    ld = ceil(ldold / 2);
    hd = ldold - ld;
    if (ld == 1) 
        break; 
    end;
end;
