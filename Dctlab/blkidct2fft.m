function X=blkidct2fft(Y, block)
% X = blkidct2fft(Y, block)
%2D IDCT on blocks (using fft), optimised for square matrices 
%
%Input: 
% Y - DCT coefficients matrix (must be square as no check is performed)
% block - size of the blocks in which Y is divided, must be square 
%
%Output: 
% X - take a look at idct2sq.m for explanation of this output...
%
%Note: 
% Take a look at the note for blkdct2fft.m!
%
%Example:
% X = blkidct2fft(rand(256), 64);

Y = double(Y);
siz = size(Y,1);
nblocks = siz/block;
rowscols = 1:block;
[rr,cc] = meshgrid(0:(nblocks-1), 0:(nblocks-1));
rr = rr(:);
cc = cc(:);

ww = sqrt(2*block) * exp(j*(0:block-1)*pi/(2*block)).';
ww(1) = ww(1)/sqrt(2);
W = repmat(ww,[1 block]);
X = zeros(size(Y));

for k = 1:length(rr)
    y = Y(rr(k)*block+rowscols,cc(k)*block+rowscols);
    
    y = real(ifft(W.*y));
    c(1,:) = y(1,:);
    c(3:2:block,:) = y(2:block/2,:);
    c(2:2:block-2,:) = y(block:-1:block/2+2,:);
    c(block,:) = y(block/2+1,:);
    c = c';
  
    c = real(ifft(W.*c));
    d(1,:) = c(1,:);
    d(3:2:block,:) = c(2:block/2,:);
    d(2:2:block-2,:) = c(block:-1:block/2+2,:);
    d(block,:) = c(block/2+1,:);
    d = d';    
        
    X(rr(k)*block+rowscols,cc(k)*block+rowscols) = d(rowscols,rowscols);
end;
