function [a,d] = dwt_lifting1D(x,wvf)
%DWT of a 1D signal in lifting implementation
%[a,d]=dwt_lifting1D(x,wvf)
%
%Input: 
% x - signal to be transformed
% wvf - wavelet identification string, or wavelet data structure
%     
%Output: 
% a - approximation (low-pass) signal
% d - detail (high-pass) signal
%
%Uses:
% load_wavelet.m
%
%Example:
% [a,d] = dwt_lifting1D(x,wvf);
% [a,d] = dwt_lifting1D(x,'CDF_9x7');

if ischar(wvf)
    wvf = load_wavelet(wvf);
end;    
s = wvf.lift_coeff;
K = wvf.lift_norm;
cn = wvf.lift_cnct;

%xe - for 1-pixel extended signal
xe = zeros(1,length(x)+2);
xe(2:end-1) = x;
if (strcmp(cn,'00'))
    warning('Lifting not available!');
else
    for i=1:size(s,1)
        xe(1) = xe(3); %extension on the left
        xe(end) = xe(end-2); %extension on the right
        start = rem(i,2); %determines if it is prediction or update step, 1 - prediction, 0 - update
        lind = 1+start:2:length(xe)-2;
        cind = lind + 1;
        rind = cind + 1;
        if (cn(i,1) == '1') %left connection present
            xe(cind) = xe(cind) + s(i,1)*xe(lind); %left pixel lifting
        end;
        if (cn(i,2) == '1') %right connection present
            xe(cind) = xe(cind) + s(i,2)*xe(rind); %right pixel lifting
        end;
    end;
end;
%normalisation
a = xe(2:2:end-1) * K(1);
d = xe(3:2:end-1) * K(2);