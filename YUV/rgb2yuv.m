function [Y,U,V]=rgb2yuv(R,G,B,yuvformat,convmtrx)
%Converts RGB to YUV
%[Y,U,V]=rgb2yuv(R,G,B,yuvformat)
%
%Input:
% R,G,B - R,G and B components of the frame
% yuvformat - YUV format [optional, default = 'YUV444_8']. Supported YUV 
%             formats are: 
%             'YUV444_8' = 4:4:4 sampling, 8-bit precision (default)
%             'YUV420_8' = 4:2:0 sampling, 8-bit precision
% convmtrx - Conversion matrix [optional, default = 'BT709_l']. The 
%            following conversions ase defined (see in Notes for more 
%            details):
%            'BT601_f' = ITU-R BT.601, RGB full [0...255] (in BT601_f.mat)
%            'BT601_219' = ITU-R BT.601, RGB limited [0...219] (in
%                           BT601_219.mat)
%            'BT601_l' = ITU-R BT.601, RGB limited [16...235] (in BT601_l.mat)
%            'BT709_f' = ITU-R BT.709, RGB limited [0...255] (in BT709_f.mat)
%            'BT709_l' = ITU-R BT.709, RGB limited [16...235] (in BT709_l.mat)
%            'SMPTE_240M' = SMPTE 240M (almost the same as Rec.709)
%             
%Output:
% Y,U,V - Y,U and V components of the frame
%
%Uses:
% imresize.m - Matlab Image Processing Toolbox (when formats other than
%              4:4:4 used)
%
%Note:
% Note that a more correct term for what is here called YUV would be YCbCr, 
% since it is used for YUV representation in digital domain. Also, the R, G
% and B components are actually non-linear because of gamma correction, and
% are more correctly denoted as R', G' and B'. YCbCr is expected to be in 
% the range (below that is "footroom" range and above is "headroom"):
%  Y = [16...235]
%  Cb,Cr = [16...240]
%
% Some more details on the defined conversions follow.
% ITU-R BT.601 - for SD (720x576) and lower resolutions. Three versions are
% available: 
% 1) RGB in full range [0...255], rgb2yuvT matrix:
%   0.257   0.504   0.098
%  -0.148  -0.291   0.439
%   0.439  -0.368  -0.071
%  yuvoffset = [16; 128; 128]
% (Resulting output range is Y=[16...235];Cb=[16...240];Cr=[16...240]
% (Coefficients taken from [3],[4],[5],[6]. Integer implementation in [7])
%
% 2) RGB limited to [0...219], rgb2yuvT matrix:
%   0.299    0.587    0.114
%  -0.173   -0.339    0.511
%   0.511   -0.428   -0.083
%  yuvoffset = [16; 128; 128]
% (Resulting output range is Y=[16...235];Cb=[16...240];Cr=[16...240])
% (Note that in [1] the coeffcients are rounded to the nearest integer, 
%  while the coefficients here are from [4] and [6]. If original signal is in 
%  range [16...235] then offset of 16 for Y signal is not necessary, e.g. 
%  definition from [6])
% 3) RGB limited to [16...235], rgb2yuvT matrix:
%   0.299   0.587   0.114
%  -0.169  -0.331   0.500
%   0.500  -0.419  -0.081
%  yuvoffset = [0; 128; 128]
% (Resulting output range is Y=[16...235];Cb=[18.5...237.5];Cr=[18.5...237.5])
% (This conversion is also used in JPEG, which allows the input to be in the 
%  full [0...255] range, where the output is in range Y=[0...255];
%  Cb=[0.5...255.5];Cr=[0.5...255.5])
% (Coefficients taken from [1],[3])
%
% ITU-R BT.709 - for HD resolutions (i.e. higher than SD). Two versions are
% available:  
% 1) RGB in full range [0...255], rgb2yuvT matrix:
%   0.1826   0.6142   0.0620
%  -0.1006  -0.3386   0.4392
%   0.4392  -0.3989  -0.0403
%  yuvoffset = [16; 128; 128]
% (Resulting output range is Y=[16...235];Cb=[16...240];Cr=[16...240])
% (Coefficients taken from [5], less precise version in [6]. Appears to be a 
%  scaled version of the next one, where RGB is limited.)
%
% 2) RGB limited to [16...235], rgb2yuvT matrix:
%   0.2126   0.7152   0.0722
%  -0.1146  -0.3854   0.5000
%   0.5000  -0.4542  -0.0468
%  yuvoffset = [0; 128; 128]
% (Resulting output range is Y=[16...235];Cb=[18.5...237.5];Cr=[18.5...237.5])
% (Coefficients taken from [2]. The ones in [6] are slightly different, for no 
%  obvious reason)
%
% References: 
%  [1] Rec. ITU-R BT.601-6
%  [2] Rec. ITU-R BT.709-5
%  [3] http://en.wikipedia.org/wiki/YCbCr
%  [4] http://www.poynton.com/ColorFAQ.html
%  [5] http://www.mathworks.com/access/helpdesk/help/toolbox/vipblks/ref/colorspaceconversion.html
%  [6] Keith Jack, Video Demystified, Chapter 3, http://www.compression.ru/download/articles/color_space/ch03.pdf
%  [7] http://msdn.microsoft.com/library/default.asp?url=/library/en-us/wceddraw/html/_dxce_converting_between_yuv_and_rgb.asp
%
%Example:
% yuv = rgb2yuv(R,G,B,'YUV420_8','BT709_f');

if (nargin < 4)
    yuvformat = 'YUV444_8';
end;
if (nargin < 5)
    convmtrx = 'BT709_l';
end;
if (strcmp(yuvformat,'YUV420_8') && (exist('imresize','file') ~= 2))
    error('For YUV420 subsampling rgb2yuv requires Image Processing Toolbox (TM) function imresize!');
end;

if strcmp(convmtrx,'BT601_f')
   load('BT601_f.mat','-mat');
elseif strcmp(convmtrx,'BT601_l')
   load('BT601_l.mat','-mat');
elseif strcmp(convmtrx,'BT601_219')
   load('BT601_219.mat','-mat');
elseif strcmp(convmtrx,'BT709_f')
   load('BT709_f.mat','-mat');
elseif strcmp(convmtrx,'BT709_l')
   load('BT709_l.mat','-mat');
elseif strcmp(convmtrx,'SMPTE_240M')
   load('SMPTE_240M.mat','-mat');
end;

T = rgb2yuvT;
R = double(R);
G = double(G);
B = double(B);
Y = T(1,1) * R + T(1,2) * G + T(1,3) * B + yuvoffset(1);
U = T(2,1) * R + T(2,2) * G + T(2,3) * B + yuvoffset(2);
V = T(3,1) * R + T(3,2) * G + T(3,3) * B + yuvoffset(3);
if (strcmp(yuvformat,'YUV420_8'))
    U = imresize(U,0.5,'bicubic');
    V = imresize(V,0.5,'bicubic');
elseif (strcmp(yuvformat,'YUV444_8'))
%do nothing, already in the correct subsampling format
end;
Y = uint8(round(Y));
U = uint8(round(U));
V = uint8(round(V));

%Alternative conversion, as in [7], defined with:
% C = Y - 16
% D = U - 127
% E = V - 128
% R = clip(( 298 * C           + 409 * E + 128) >> 8)
% G = clip(( 298 * C - 100 * D - 208 * E + 128) >> 8)
% B = clip(( 298 * C + 516 * D           + 128) >> 8)
%yuv(:,:,1) = yuv(:,:,1) - 16;
%yuv(:,:,2) = yuv(:,:,2) - 128;
%yuv(:,:,3) = yuv(:,:,3) - 128;
%rgb(:,:,1) = uint8(floor((298*yuv(:,:,1) + 409*yuv(:,:,3) + 128)/256));
%rgb(:,:,2) = uint8(floor((298*yuv(:,:,1) - 100*yuv(:,:,3) - 208*yuv(:,:,2))/256));
%rgb(:,:,3) = uint8(floor((298*yuv(:,:,1) + 516*yuv(:,:,2) + 128)/256));