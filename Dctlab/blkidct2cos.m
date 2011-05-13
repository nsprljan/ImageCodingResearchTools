function X=blkidct2cos(Y,block)
%X = blkidct2cos(Y,block)
%2D IDCT on blocks (using cosine function), optimised for square matrices
%
%Input: 
% Y - DCT coefficients matrix (must be square as no check is performed)
% block - size of the blocks in which Y is divided, must be square 
%
%Output: 
% X - inverse transformed matrix
%
%Note: 
% Works faster then 'blkidct2fft' when the blocks are small.
%
%Example:
% X = blkidct2cos(rand(16), 4);

j1=0:block-1;
j2=0:block-1;
[J1,J2]=meshgrid(j1,j2);
C=cos(((2.*J1+1).*J2*pi)/(block*2));
D=C';
Y=double(Y)./(block/2);
siz=size(Y,1);
nblocks=siz/block;
rowscols=1:block;
[rr,cc]=meshgrid(0:(nblocks-1), 0:(nblocks-1));
rr=rr(:);
cc=cc(:);
X = zeros(size(Y));

for k=1:length(rr)
    x=Y(rr(k)*block+rowscols,cc(k)*block+rowscols);
    x(:,1)=x(:,1).*(1/sqrt(2));
    x(1,:)=x(1,:).*(1/sqrt(2));
    D1=x*C;
    D2=D*D1;
    X(rr(k)*block+rowscols,cc(k)*block+rowscols)=D2(rowscols,rowscols);
end;
