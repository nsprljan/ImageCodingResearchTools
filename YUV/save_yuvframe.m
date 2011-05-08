function [C,Y,U,V]=save_yuvframe(yuvfile,dims,frm,outimage)
%Saves selected frame from yuv sequence to image file
%[C,Y,U,V]=save_yuvframe(yuvfile,dims,frm,outimage)
%
%Input:
% yuvfile - YUV sequence file
% dims - dimensions of the frame [width height]
% frm - frame to be converted, with the convention that the first frame of 
%       the sequence is denoted with 0
% outimage - output image file, the extension specifies the format. If
%            extension is not specified, save as raw, each componenet
%            independently using 8 bits per pixel.
%
%Output:
% C - 3D RGB matrix, see help in yuv2rgb.m
% Y, U, V - each component
%
%Uses:
% yuv_import.m (for reading a frame from the yuv file)
% yuv2rgb.m (for converting to RGB color system)
%
%Example:
% C = save_yuvframe('foreman.yuv',[352 288],1,'foreman_1stframe.png');

[Y, U, V] = yuv_import(yuvfile,dims,1,frm);
[t1,t2,ext] = fileparts(outimage);
C = [];
if (isempty(ext))
    fid=fopen([outimage 'Y.raw'],'w');
    fwrite(fid,Y{1}','uint8');
    fclose(fid);
    fid=fopen([outimage 'U.raw'],'w');
    fwrite(fid,U{1}','uint8');
    fclose(fid);
    fid=fopen([outimage 'V.raw'],'w');
    fwrite(fid,V{1}','uint8');
    fclose(fid);    
    %yuv_export(Y,U,V,[outimage '.raw'], 1);
else %save as image, using the specified extension to determine the format
    C=yuv2rgb(Y{1},U{1},V{1});
    imwrite(C,outimage);
end;
