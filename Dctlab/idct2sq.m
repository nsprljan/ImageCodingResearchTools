function X=idct2sq(Y)
%X = idct2sq(Y)
%Version: 3.01, Date: 2008/03/02, author: Nikola Sprljan
%2D IDCT optimised for square matrices 
%
%Input: 
% Y - DCT coefficients matrix (must be square as no check is performed)
%
%Output: 
% X - just a matrix, what else? :)
%
%Note: 
% Take a look at the note for dct2sq.m!
%
%Example:
% X = idct2sq(Y);

n = size(Y,1);
ww = sqrt(2*n) * exp(j*(0:n-1)*pi/(2*n)).';
ww(1) = ww(1)/sqrt(2);
W = repmat(ww,[1 n]);

X = idctsq1D(idctsq1D(Y,W,n)',W,n)';

function a = idctsq1D(bb,W,n)
yy = W.*bb;
y = real(ifft(yy));
%this below is to avoid n = 2^k strangeness
a = zeros(n-1,n);
a(1,:) = y(1,:);
a(3:2:n,:) = y(2:n/2,:);
a(2:2:n-2,:) = y(n:-1:n/2+2,:);
a(n,:) = y(n/2+1,:);