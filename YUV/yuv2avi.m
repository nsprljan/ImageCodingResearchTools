function numfrm=yuv2avi(yuvfilename,dims,avifilename,fps,yuvformat)
%Imports YUV sequence and saves it as an AVI
%numfrm=yuv2avi(yuvfilename,dims,avifilename,fps)
%
%Input:
% yuvfilename - YUV sequence file
% dims - dimensions of the frame [width height]
% avifilename - name of the output AVI file
% fps - frames per second
% yuvformat - [optional, default = 'YUV420_8']. YUV format, supported formats 
%             are defined in yuv_import.m. The default conversion matrix is
%             ITU-R BT.709, see in yuv2rgb.m and rgb2yuv.m
%
%Output:
% numfrm - number of frames processed
%
%Uses:
% yuv2rgb.m (for converting into RGB)
% yuv_import.m (for importing the YUV frames)
% imresize.m (Matlab Image Toolbox)
%
%Example:
% numfrm = yuv2avi('city_CIF.yuv',[352 288],'test.avi',15,'YUV444_8');

if (nargin < 6)
    yuvformat = 'YUV420_8';
end;
if (strcmp(yuvformat,'YUV420_8') && (exist('imresize','file') ~= 2))
    error('For YUV420 subsampling yuv2avi requires Image Processing Toolbox (TM) function imresize!');
end;

numfrm = seq_frames(yuvfilename,dims);

% Create AVI file
avi = VideoWriter(avifilename);
set(avi, 'FrameRate', fps);
set(avi, 'Quality', 100);

open(avi);
for i = 1 : 60
    % Import YUV frame
    [Y, U, V] = yuv_import(yuvfilename,dims,1,i-1,yuvformat);
    % Convert YUV to RGB
    rgb = yuv2rgb(Y{1},U{1},V{1},yuvformat);
    % Save frame to file
    writeVideo(avi, rgb);
    
    fprintf('Frame %d/%d\n',i,numfrm);
end;
close(avi);
