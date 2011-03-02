function X = idwt_dim(X,d,wavelet)
%IDWT in specific dimension of an n-dimensional matrix
%X=idwt_dim(X,d,wavelet)
%
%Input: 
% X - matrix of wavelet coeffcients
% d - dimension in which the transform will take place
% wavelet - wavelet identification string, or wavelet data structure
%     
%Output: 
% X - reconstructed matrix
% 
%Uses: 
% load_wavelet.m
% idwt_lifting1D.m
% subband_dim.m
%
%Example:
% X = idwt_dim(Y,1,'Haar');

%load the wavelet here
if ischar(wavelet)
    wvf = load_wavelet(wavelet);
else
    wvf = wavelet;
end;

N = ndims(X);
dimprod = numel(X);
X = shiftdim(X,d-1); %rotates the order of dimensions
sv = size(X); %matrix size before reshaping
sizdim = sv(1); %size of the first dimension
if sizdim > 1 %if non-singleton dimension
    sizcol = dimprod/sizdim; %product of other dimensions
    X = reshape(X,sizdim,sizcol); %reshape into 2D sizdim x sizcol matrix
    [lpasiz,hpasiz] = subband_dim(sizdim, 1);
    for j=1:sizcol   
        X(:,j) = idwt_lifting1D(X(1:lpasiz,j),X(lpasiz+1:sizdim,j),wvf);
    end;
    X = reshape(X,sv);    
end;
X = shiftdim(X,N-d+1); %rotates the order of dimensions forward to the original