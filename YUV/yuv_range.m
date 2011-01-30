function [Yrange,Urange,Vrange]=yuv_range(yuvfile,dims)
%Computes the range of samples in YUV sequence
%[Yrange,Urange,Vrange]=yuv_range(yuvfile,dims)
%
%Input:
% filename - YUV sequence file
% dims - dimensions of the frame [width height]
%
%Output:
% Yrange, Urange, Vrange - ranges of the components values
%
%Note:
% Supports only the YUV420_8 format.
%
%Example:
% [Yrange, Urange, Vrange] = yuv_range('FOREMAN_352x288_30_orig_01.yuv',[352 288]);

numfrm = seq_frames(yuvfile,dims);
Ymin = Inf; Ymax = -Inf;
Umin = Inf; Umax = -Inf;
Vmin = Inf; Vmax = -Inf;
for i=1:numfrm
    [Y, U, V] = yuv_import(yuvfile,dims,1,i-1);
    %minimum
    Ymin = min(Ymin, min(Y{1}(:)));
    Umin = min(Umin, min(U{1}(:)));
    Vmin = min(Vmin, min(V{1}(:)));
    %maximum
    Ymax = max(Ymax, max(Y{1}(:)));
    Umax = max(Umax, max(U{1}(:)));
    Vmax = max(Vmax, max(V{1}(:)));
end;
Yrange = [Ymin Ymax];
Urange = [Umin Umax];
Vrange = [Vmin Vmax];