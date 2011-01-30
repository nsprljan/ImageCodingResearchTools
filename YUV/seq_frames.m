function frames=seq_frames(filename,dims,yuvformat)
%Returns the number of frames in YUV sequence file
%frames=seq_frames(filename,dims,format)
%
%Input:
% filename - YUV sequence file
% dims - dimensions of the frame [width height]
% yuvformat - YUV format [optional, default = 'YUV420_8']. Supported YUV
%             formats are: 
%             'YUV444_8' = 4:4:4 sampling, 8-bit precision 
%             'YUV420_8' = 4:2:0 sampling, 8-bit precision (default)
%
%Examples:
% frames = seq_frames('football.yuv',[352 288],'420');

if (nargin < 3)
    yuvformat = 'YUV420_8';
end;

Ysiz = prod(dims);
if strcmp(yuvformat,'YUV420_8')
    UVsiz = Ysiz / 4;
    frelem = Ysiz + 2*UVsiz;
elseif strcmp(yuvformat,'YUV444_8')
    frelem = 3*Ysiz;
else
    error(['Format ' format ' not supported or unknown!']);
end;
fid=fopen(filename,'r');
if (fid == -1) 
    error('Cannot open file');
end;
fseek(fid, 0, 'eof');
yuvbytes = ftell(fid);
frames = floor(yuvbytes / frelem);
fclose(fid);
