function numfrm=yuv2avi_demosaic(yuvFilename, dims, aviFilename, varargin)
%Imports YUV sequence, performs demosaic of each frame and saves it as an AVI
%numfrm=yuv2avi_demosaic(yuvFilename, dims, aviFilename, fps, sensorAlignment, yuvFormat)
%
%Input:
% yuvFilename - YUV sequence file
% dims - dimensions of the frame [width height]
% aviFilename - name of the output AVI file
% fps - [optional, default = 30] frames per second
% sensorAlignment - [optional, default = 'rggb'] Bayer pattern, see demosaic()
% yuvFormat - [optional, default = 'YUV420_8']. YUV format, supported formats 
%             are defined in yuv_import.m. The default conversion matrix is
%             ITU-R BT.709, see in yuv2rgb.m and rgb2yuv.m
%
%Output:
% numfrm - number of frames processed
%
%Uses:
% yuv2rgb.m (for converting into RGB)
% yuv_import.m (for importing the YUV frames)
%
%Example:
% numfrm = yuv2avi_demosaic('city_CIF.yuv', [352, 288], 'test.avi', 15, 'bggr', 'YUV444_8');
% numfrm = yuv2avi_demosaic('yuv_file.yuv', [640, 480], 'avi_file.avi');

% Validate inputs
inputs = inputParser;
expectedPatterns = {'gbrg', 'grbg', 'bggr', 'rggb'};
expectedYuvFormats = {'YUV444_8', 'YUV420_8', 'YUV420_16'};

inputs.addRequired('yuvFilename');
inputs.addRequired('dims');
inputs.addRequired('aviFilename');
inputs.addOptional('fps', 30);
inputs.addOptional('sensorAlignment', 'rggb', @(pattern) any(validatestring(pattern, expectedPatterns)));
inputs.addOptional('yuvFormat', 'YUV420_8', @(format) any(validatestring(format, expectedYuvFormats)));
inputs.parse(yuvFilename, dims, aviFilename, varargin{:});

% Get number of frames to process
numfrm = seq_frames(yuvFilename, dims);

% Create AVI file
avi = VideoWriter(aviFilename);
set(avi, 'FrameRate', inputs.Results.fps);
set(avi, 'Quality', 100);

open(avi);
for i = 1 : numfrm
    % Import YUV frame
    [Y, U, V] = yuv_import(yuvFilename, dims, 1, i - 1, inputs.Results.yuvFormat);
    % Convert YUV to RGB
    rgb = yuv2rgb(Y{1}, U{1}, V{1}, inputs.Results.yuvFormat);
    
    % Perform demosaic
    rgbGray = rgb2gray(rgb);
    rgbFrame = demosaic(rgbGray, inputs.Results.sensorAlignment);
    
    % Save frame
    writeVideo(avi, rgbFrame);
    
    fprintf('Frame %d/%d\n',i,numfrm);
end;
close(avi);
