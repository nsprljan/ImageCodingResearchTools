function numfrm=yuv2seq_demosaic(yuvFilename, dims, imagesDir, varargin)
%Imports YUV sequence, performs demosaic of each frame and saves it as a
%sequence of images
%numfrm=yuv2avi_demosaic(yuvFilename, dims, imagesDir, imageNamePattern, sensorAlignment, yuvFormat)
%
%Input:
% yuvFilename - YUV sequence file
% dims - dimensions of the frame [width height]
% imagesDir - name of the directory for output images
% sensorAlignment - [optional, default = 'rggb'] Bayer pattern, see demosaic()
% imageNamePattern - [optional, default = 'Frame_%05d.png'] name pattern
%                    for images (default prints always five digits as an index)
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
% numfrm = yuv2avi_demosaic('yuv_file.yuv', [640, 480], 'C:\output');
% numfrm = yuv2avi_demosaic('yuv_file.yuv', [640, 480], 'C:\output', 'bggr', 'rgb_%03d.png', 'YUV444_8');

% Validate inputs
inputs = inputParser;
expectedPatterns = {'gbrg', 'grbg', 'bggr', 'rggb'};
expectedYuvFormats = {'YUV444_8', 'YUV420_8', 'YUV420_16'};

inputs.addRequired('yuvFilename');
inputs.addRequired('dims');
inputs.addRequired('imagesDir');
inputs.addOptional('imageNamePattern', 'Frame_%05d.png', @(pattern) not(isempty(pattern)));
inputs.addOptional('sensorAlignment', 'rggb', @(pattern) any(validatestring(pattern, expectedPatterns)));
inputs.addOptional('yuvFormat', 'YUV420_8', @(format) any(validatestring(format, expectedYuvFormats)));
inputs.parse(yuvFilename, dims, imagesDir, varargin{:});

% Get number of frames to process
numfrm = seq_frames(yuvFilename, dims);

for i = 1 : numfrm
    % Import YUV frame
    [Y, U, V] = yuv_import(yuvFilename, dims, 1, i - 1, inputs.Results.yuvFormat);
    % Convert YUV to RGB
    rgb = yuv2rgb(Y{1}, U{1}, V{1}, inputs.Results.yuvFormat);
    
    % Perform demosaic
    rgbGray = rgb2gray(rgb);
    rgbFrame = demosaic(rgbGray, inputs.Results.sensorAlignment);
    
    % Save frame
    dest = strcat(imagesDir, '\', sprintf(inputs.Results.imageNamePattern, i));
    imwrite(rgbFrame, dest);
    
    fprintf('Frame %d/%d\n', i, numfrm);
end;
