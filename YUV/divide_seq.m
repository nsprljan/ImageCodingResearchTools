function divide_seq(filename,dims,frstep)
%Divides YUV sequence into segments
%divide_seq(filename,dims,frstep)
%
%Input:
% filename - YUV sequence file
% dims - dimensions of the frame [width height]
% frstep - number of frames in one segment
%
%Uses: 
% seq_frames.m
% yuv_import.m 
% yuv_export.m 
%
%Examples:
% divide_seq('football.yuv',[352 288],8);

[pathstr,name,ext] = fileparts(filename);
numframes = seq_frames(filename,dims);
part = 1;
for i=1:frstep:numframes
    firstfr = i;
    lastfr = min(i + frstep - 1, numframes);
    frs = lastfr - firstfr + 1; 
    [Y,U,V] = yuv_import(filename,dims,frs,i-1);
    partname = [pathstr '\' name '_GOP' num2str(part,'%02d') ext];
    yuv_export(Y,U,V,partname,frs);
    part = part + 1;
end;