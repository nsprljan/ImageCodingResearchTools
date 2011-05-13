function Y=blkdct2cos(X,block)
%Y = blkdct2cos(X,block)
%2D DCT on blocks (using cosine function), optimised for square matrices 
%
%Input: 
% X - input matrix (must be square as no check is performed)
% block - size of the block on which X will be divided, must be square 
%
%Output: 
% Y - DCT coefficients matrix, divided in blocks
%
%Note: 
% Works faster then 'blkdct2fft' when the blocks are small.
%
%Example:
% Y = blkdct2cos(rand(16),4);

j1=0:block-1;
j2=0:block-1;
[J1,J2]=meshgrid(j1,j2);
C=cos(((2.*J1+1).*J2*pi)/(block*2));
D=C';
X=double(X)./(block/2);
siz=size(X,1);
nblocks=siz/block;
rowscols=1:block;
[rr,cc]=meshgrid(0:(nblocks-1), 0:(nblocks-1));
rr=rr(:);
cc=cc(:);
Y = zeros(size(X));

for k=1:length(rr)
    x=X(rr(k)*block+rowscols,cc(k)*block+rowscols);
    D1=x*D;
    D2=C*D1;
    D2(:,1)=D2(:,1).*(1/sqrt(2));
    D2(1,:)=D2(1,:).*(1/sqrt(2));
    Y(rr(k)*block+rowscols,cc(k)*block+rowscols)=D2(rowscols,rowscols);
end;
