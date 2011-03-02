function [Y,N]=dwt_dyadic_decomp(X,wavelet,N)
%Dyadic wavelet decomposition of a multidimensional signal 
%[Y,N]=dwt_dyadic_decomp(X,wavelet,N)
%
%Input: 
% X - matrix to be transformed containing the input signal or image's
%     filename (in that case the transform is 2D)
% wavelet - wavelet identification string
% N - [optional, default = max] specifies the number of levels of decomposition
%     default value is the maximum possible, e.g. down to the smallest possible 
%     LL subband 
%     
%Output: 
% Y - matrix of wavelet coefficients
% N - number of actually performed levels of decomposition
%
%Note: 
% Performs dyadic decomposition, i.e. the dimensions of low-pass subband
% are half of the original subband.
% 
%Uses: 
% submatrix.m
% dwt_dim.m
% subband_dim.m
%
%Example:
% Y=dwt_dyadic_decomp(X,'CDF_9x7',6);
% [Y,N]=dwt_dyadic_decomp('Lena512.png','Haar');

if ischar(X)
    X=imread(X);   
end;   
Y=double(X);

transposed = 0; %by default do not transpose
if isvector(X)
   n = 1; %number of dimensions 
   if (size(X,1) == 1) %if one-row vector, needs to be transposed
       Y = Y';
       transposed = 1; %remember to transpose it back later
   end;
else
    n = ndims(Y);
end;
Xsiz=size(Y); 

%to find Nmax - the maximum number of decompositions possible
[ld,hd,Nmax]= subband_dim(Xsiz, Inf);
if nargin==2 
    %if not specified, the number of decomposition is set to Nmax
    N = Nmax;
elseif (N > Nmax)  
    warning(['Specified number of decompositions exceeds the maximum. N is set to Nmax = ' num2str(Nmax)]);
    N = Nmax;
end;

Lsiz = Xsiz; %low-pass subband dimensions 
for i=1:N
    [Li,Lind] = submatrix(Y,Lsiz);
    for j=1:n %transform in the j-th dimension
        Li = dwt_dim(Li,j,wavelet);
    end;
    Y(Lind{:}) = Li;
    Lsiz = ceil(Lsiz/2); %i.e. low-pass of signal of 3 samples contains 2 samples 
end;

if transposed
    Y = Y';
end;
