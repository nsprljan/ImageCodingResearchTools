function Xr = idwt_dyadic_recon(Y,wavelet,N)
%Dyadic wavelet reconstruction of a multidimensional signal
%X=idwt_dyadic_recon(Y,wavelet,N)
%
%Input:
% X - matrix of wavelet coefficients
% wavelet - wavelet identification string
% N - specifies the number of levels of reconstruction (inverse DWT)
%     
%Output: 
% Xr - reconstructed matrix
% 
%Uses: 
% submatrix.m
% idwt_dim.m
% 
%Example:
% Xr=idwt_dyadic_recon(Y,'CDF_9x7',6);

Xr=double(Y);

transposed = 0; %by default, do not transpose
if (size(Y,1) == 1) %if one-row vector, needs to be transposed
 Xr = Xr'; 
 transposed = 1; %remember to transpose it back later
end;
Xsiz=size(Xr);
if isvector(Xr) 
    n = 1;
else 
    n = ndims(Xr);
end;

for i=N-1:-1:0
    Lsiz = ceil(Xsiz / 2^i); %low-pass subband dimensions
    [Li,Lind] = submatrix(Xr,Lsiz);
    for j=n:-1:1 %inverse transform in j-th dimension     
        Li = idwt_dim(Li,j,wavelet);
    end;
    Xr(Lind{:}) = Li;
end;

if transposed
    Xr = Xr';
end;
