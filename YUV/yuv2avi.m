function numfrm=yuv2avi(yuvfilename,dims,avifilename,compression,fps,yuvformat)
%Imports YUV sequence and saves it as an AVI
%numfrm=yuv2avi(yuvfilename,dims,avifilename,compression,fps)
%
%Input:
% yuvfilename - YUV sequence file
% dims - dimensions of the frame [width height]
% avifilename - name of the output AVI file
% compression - specifies compression for AVI, see help of the Matlab 
%               function 'avifile'
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
% numfrm = yuv2avi('city_CIF.yuv',[352 288],'test.avi','none',15,'YUV444_8');

if (nargin < 6)
    yuvformat = 'YUV420_8';
end;
if (strcmp(yuvformat,'YUV420_8') && (exist('imresize','file') ~= 2))
    error('For YUV420 subsampling yuv2avi requires Image Processing Toolbox (TM) function imresize!');
end;

numfrm = seq_frames(yuvfilename,dims);
%sizfrm = prod(dims);
avi = avifile(avifilename,'fps',fps,'quality',100,'colormap',gray(256),'compression',compression);
for i=1:numfrm
    [Y, U, V] = yuv_import(yuvfilename,dims,1,i-1,yuvformat);
    yuv(:,:,1) = Y{1};
    if (strcmp(yuvformat,'YUV420_8'))
        yuv(:,:,2) = imresize(U{1},2,'bicubic');
        yuv(:,:,3) = imresize(V{1},2,'bicubic');
    else
        yuv(:,:,2) = U{1};
        yuv(:,:,3) = V{1};
    end;
    rgb = yuv2rgb(Y{1},U{1},V{1},yuvformat);
    avi = addframe(avi,rgb);
    fprintf('Frame %d/%d\n',i,numfrm);
end;
close(avi);
