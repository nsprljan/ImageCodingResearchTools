function B=wavelet_downscale(A,wavelet,scale)
%Image resizing performed by wavelet decomposition
%B=wavelet_downscale(A,wavelet,scale)
%
%Input: 
% A - array containing an image
% wavelet - wavelet identification string
% scale - the scale the image is resized to (e.g. scale=1 halves the image
%         dimensions)
%      
%Output: 
% B - downscaled image
%
%Uses: 
% dwt_dyadic_decomp.m
% subband.m
%
%Example:
% B=wavelet_downscale(A,'CDF_9x7',3);

if scale == 0
    B = A;
else
    if ischar(A)
        A=imread(A);   
    end;   
    A=double(A);
    D = dwt_dyadic_decomp(A,wavelet,scale);
    Dr = subband(D,scale,'ll');
    B=Dr/(2^scale); %assumed that the DC gain factor is sqrt(2)
    B(B>255)=255;
    B(B<0)=0;
    B=uint8(round(B));
end;