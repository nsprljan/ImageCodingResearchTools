function [S,Sind] = submatrix(X,Ssiz,Soff)
%Extracts submatrix from a multidimensional matrix
%[S,Sind]=submatrix(X,Ssiz,Soff)
%
%Input: 
% X - matrix of n dimensions
% Ssiz - submatrix size to be extracted
% Soff - submatrix starts at this offset
%
%Output:
% S - submatrix
% Sind - indices of the extracted submatrix in the original submatrix
%
%Note:
% To get the extracted indices use X(Sind{:})
%
%Example: 
% Suppose I have an N-dimensional matrix X, and want to extract the 
% submatrix of which each dimension is half than in X (with 
% the offset at the first element of X). Then, the function would be called
% with: S = submatrix(X,ceil(size(X)/2));

if isvector(X) 
    n = 1;
else 
    n = ndims(X);
end;
if (nargin < 3) 
    Soff = ones(n,1); %sets the default offset
end; 
Sind = repmat({':'},n,1);
for i = 1:n
    Sind{i} = Soff(i):(Soff(i) + Ssiz(i) - 1);
end;
S = X(Sind{:});
