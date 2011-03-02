function X=dwt_dim(X,d,wavelet)
%DWT in specific dimension of an n-dimensional matrix
%X=dwt_dim(X,d,wavelet)
%
%Input: 
% X - matrix to be transformed containing the input signal
% d - dimension in which the transform will take place
% wavelet - wavelet identification string, or wavelet data structure
%     
%Output: 
% X - matrix of wavelet coefficients
%
%Note:
% Filters across the d-th dimension. For instance, if X is 2D then it first
% filters across columns, as size(X,1) is number of rows (column length).
%
%Uses: 
% load_wavelet.m
% dwt_lifting1D.m
% subband_dim.m
%
%Example:
% Y = dwt_dim(X,1,'CDF_9x7');

%load the wavelet here
if ischar(wavelet)
    wvf = load_wavelet(wavelet);
else
    wvf = wavelet;
end;

if ~isa(X,'double') 
    X = double(X);
end;
N = ndims(X);
dimprod = numel(X);
X = shiftdim(X,d-1); %rotates the order of dimensions
sv = size(X); %matrix size before reshaping
sizdim = sv(1); %size of the first dimension
if sizdim > 1 %if non-singleton dimension
    sizcol = dimprod/sizdim; %product of other dimensions
    X = reshape(X,sizdim,sizcol); %reshape into 2D sizdim x sizcol matrix
    lpasiz = subband_dim(sizdim, 1);    
    for j=1:sizcol
        [X(1:lpasiz,j),X(lpasiz+1:sizdim,j)] = dwt_lifting1D(X(:,j),wvf);      
    end;
    X = reshape(X,sv);
end;
X = shiftdim(X,N-d+1); %rotates the order of dimensions forward to the original