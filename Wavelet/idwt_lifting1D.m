function y = idwt_lifting1D(a,d,wvf)
%IDWT of a 1D signal in lifting implementation
%y=idwt_lifting1D(a,d,wvf)
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
%Example:
% y = idwt_lifting1D(a,d,wvf);
% y = idwt_lifting1D(a,d,'CDF_9x7');

if ischar(wvf)
    wvf = load_wavelet(wvf);
end; 
s = wvf.lift_coeff;
K = wvf.lift_norm;
cn = wvf.lift_cnct;

%xe - for 1-pixel extended signal
xe = zeros(1,length(a)+length(d)+2);
%undo the normalisation
xe(2:2:end-1) = a / K(1);
xe(3:2:end-1) = d / K(2);
if (strcmp(cn,'00'))
    warning('Lifting not available!');
else
    for i=size(s,1):-1:1
        xe(1) = xe(3); %extension on the left
        xe(end) = xe(end-2); %extension on the right
        start = rem(i,2); %determines if it is prediction or update step, 1 - prediction, 0 - update
        lind = 1+start:2:length(xe)-2;
        cind = lind + 1;
        rind = cind + 1;
        if (cn(i,1) == '1') %left connection present
            xe(cind) = xe(cind) - s(i,1)*xe(lind); %left pixel lifting
        end;
        if (cn(i,2) == '1') %right connection present
            xe(cind) = xe(cind) - s(i,2)*xe(rind); %right pixel lifting
        end;
    end;
end;
y = xe(2:end-1);

