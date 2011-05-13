function Y=blkdct2fft(X, block)
% Y = blkdct2fft(X, block)
%2D DCT on blocks (using fft), optimised for square matrices 
%
%Input: 
% X - input matrix (must be square as no check is performed)
% block - size of the blocks in which X will be divided, must be square 
%
%Output: 
% Y - DCT coefficients matrix, divided in blocks
%
%Note: 
% Various tweaks introduced. Compare the speed with 'blkproc', especially
% for 2^n sized inputs. Core of the dct2sq.m is used here - take a look at 
% the note for dct2sq.m!
% Works faster then 'blkdct2cos' when the blocks are large.
%
%Example:
% Y = blkdct2fft(rand(256),4);

X = double(X);
siz = size(X,1);
nblocks = siz/block;
rowscols = 1:block;
[rr,cc] = meshgrid(0:(nblocks-1), 0:(nblocks-1));
rr = rr(:);
cc = cc(:);
ww = 2*exp(-i*(0:block-1)'*pi/(2*block))/sqrt(2*block);
ww(1) = ww(1) / sqrt(2);
W = repmat(ww,[1 block]);
Y = zeros(size(X));

for k = 1:length(rr)
    x = X(rr(k)*block+rowscols,cc(k)*block+rowscols);
    
    c = [ x(1,:); x(3:2:block,:); x(block,:); x(block-2:-2:2,:)];
    c = real(W .* fft(c))';
    
    d = [ c(1,:); c(3:2:block,:); c(block,:); c(block-2:-2:2,:)];
    d = real(W .* fft(d))';
    
    Y(rr(k)*block+rowscols,cc(k)*block+rowscols) = d(rowscols,rowscols);
end;
