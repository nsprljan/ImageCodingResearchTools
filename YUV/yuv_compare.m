function [PSNRY,PSNRU,PSNRV,MSEY,MSEU,MSEV]=yuv_compare(yuvfile1,yuvfile2,dims,frames1,frames2)
%Compares two YUV sequences by computing PSNR
%[PSNRY,PSNRU,PSNRV,MSEY,MSEU,MSEV]=yuv_compare(yuvfile1,yuvfile2,dims)
%
%Input:
% yuvfile1 - first YUV sequence file
% yuvfile2 - second YUV sequence file
% dims - frame dimensions
% frames1 - [optional, default = all frames] frames in yuvfile1 to compare
% frames2 - [optional, default = frames1] frames in yuvfile2 to compare
%
%Output:
% PSNRY, PSNRU, PSNRV - PSNR values of the sequence for each frame, for Y, 
%                       U and V, respectively
% MSEY, MSEU, MSEV - the same, but MSE
%
%Uses: 
% seq_frames.m
% yuv_import.m 
% iq_measures.m (Quality Assessment toolbox - computation of MSE and PSNR)
%
%Example:
% [PY, PU, PV]=yuv_compare('compressed.yuv','original.yuv',[352 288]);

numfrm1 = seq_frames(yuvfile1,dims);
numfrm2 = seq_frames(yuvfile2,dims);
if (nargin < 4)
    numfrm = min([numfrm1 numfrm2]);
    frames1 = 1:numfrm;
end;
if (nargin < 5)
    frames2 = frames1; %assumed that the sequence are temporally coincident
end;
numfrm = length(frames1);
numfrm2 = length(frames2);
if (numfrm ~= numfrm2)
    error('Different number of frames selected.');
end;
PSNRY = zeros(numfrm,1);PSNRU = zeros(numfrm,1);PSNRV = zeros(numfrm,1);
MSEY = zeros(numfrm,1);MSEU = zeros(numfrm,1);MSEV = zeros(numfrm,1);
for i=1:numfrm 

    [Y1, U1, V1] = yuv_import(yuvfile1,dims,1,frames1(i)-1);
    %if (numel(Y1{1}) ~= prod(frm)) 
    %    break;
    %end; %there's no more frames in the sequence 1    
    [Y2, U2, V2] = yuv_import(yuvfile2,dims,1,frames2(i)-1);
    %if (numel(Y2{1}) ~= prod(frm)) 
    %    break;
    %end; %there's no more frames in the sequence 2 
    [MSEY(i),PSNRY(i)] = iq_measures(Y1{1},Y2{1});
    [MSEU(i),PSNRU(i)] = iq_measures(U1{1},U2{1});
    [MSEV(i),PSNRV(i)] = iq_measures(V1{1},V2{1});    
end;
