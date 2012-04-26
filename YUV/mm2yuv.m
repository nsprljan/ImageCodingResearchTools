function mm2yuv(inputmm,outputyuv,yuvformat)
%Converts video file into raw YCbCr format
%mm2yuv(inputmm,outputyuv,yuvformat)
%
%Input:
% inputmm - input multimedia file (e.g. avi, mpg, etc.)
% outputyuv - output yuv file
% yuvformat - [optional, default = 'YUV420_8']. YUV format, supported formats 
%             are defined in yuv_import.m
%
%Example:
% mm2yuv('input.avi','output.yuv','YUV444_8');

if (nargin < 3)
    yuvformat = 'YUV420_8';
end;
M = mmreader(inputmm);
outfile = outputyuv;
for f = 1 : M.NumberOfFrames
    Mframe = read(M, f);
    R = Mframe(:,:,1);
    G = Mframe(:,:,2);
    B = Mframe(:,:,3);
    [Y{1},U{1},V{1}]=rgb2yuv(R,G,B,yuvformat);   
    yuv_export(Y,U,V,outfile,1);
end;
