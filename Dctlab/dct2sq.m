function Y=dct2sq(X)
%Y = dct2sq(X)
%Version: 3.01, Date: 2008/03/02, author: Nikola Sprljan
%2D DCT optimised for square matrices 
%
%Input: 
% X - input matrix (must be square as no check is performed)
%
%Output: 
% Y - DCT coefficients matrix
%
%Note: 
% If the input matrix is of size 2^n x 2^n, the execution can around two 
% times faster than the default Matlab's 'dct2' command. The reason is that
% in 'dct2' the line aa = a(1:n,:); gets executed while in this function it
% is not needed (no truncation necessary). n is equal to the number of rows
% (n = size(a,1);), and strangely for n = 2^k the abovementioned line is 
% several times slower than for other n. Don't have a clue why.
%
%Example:
% Y = dct2sq(rand(1024));

n = size(X,1);
ww = 2*exp(-i*(0:n-1)'*pi/(2*n))/sqrt(2*n);
ww(1) = ww(1) / sqrt(2);
W = repmat(ww,[1 n]);

Y = dctsq1D(dctsq1D(X,W,n)',W,n)';

function b=dctsq1D(aa,W,n)
%y = double([ aa(1:2:n,:); aa(n:-2:2,:) ]);
%rather like this below, to avoid n = 2^k strangeness
y = double([ aa(1,:); aa(3:2:n,:); aa(n,:); aa(n-2:-2:2,:)]);
b = real(W .* fft(y));
