function scale_seq(filename,dims,numfrm,startfrm,outfilename,type,outdims,tstep,crop)
%Scales YUV sequence
%scale_seq(filename,dims,numfrm,outfilename,scale,type)
%
%Input:
% filename - YUV sequence file
% dims - dimensions of the frame [width height]
% numfrm - number of frames to process, if 0 then all frames
% startfrm - specifies from which frame to start reading with the 
%            convention that the first frame of the sequence is 0-numbered
% outfilename - filename of the output YUV sequence
% type - type of scaling
%         if (type == 'fir') uses fir_downscale function
%         if (type == 'wav') uses wavelet_downscale function
%         if (type == 'imresize') uses imresize function of Image 
%         Processing Toolbox   
% outdims - output frame dimensions
% tstep - temporal subsampling step, i.e. preserves every tstep frame
% crop - [optional, default = no cropping] specifies the coordinates of the
%        cropping window - [xstart ystart width height] 
%
%Note: numfrm is the number of frames from the sequence that will be 
%      considered, not the resulting number of frames given by the temporal
%      downsampling. If type 'imresize' is used then upsampling can
%      be performed also (see in the examples!).
%
%Uses: 
% wavelet_downscale.m (Wavelet Toolbox)
% fir_downscale.m
% yuv_import.m
% yuv_export.m
%
%Example:
% scale_seq('city4CIF.yuv',[704 576],10,0,'cityCIF.yuv','imresize',[352 
%  288],1);
% scale_seq('bbcjr.yuv',[960 512],10, 10, 'test.yuv','imresize',[704 384],
%  1,[11 1 940 512]);
% scale_seq('foreman.yuv',[176 144],0, 0, 'test.yuv','imresize',[352 288],
%  1); %upsampling

scale = 0;
cropwin = [1 dims(2);1 dims(1)];
Ycrop{1} = [];
Ucrop{1} = [];
Vcrop{1} = [];
Y{1} = [];
U{1} = [];
V{1} = [];

if (nargin < 9)
    crop = -1;
else
    cropwin = [crop(2) (crop(2) + crop(4) - 1);crop(1) (crop(1) + crop(3) - 1)];
end;
if ((cropwin(1,2) > dims(2)) || (cropwin(2,2) > dims(1)))
    error('Croppping window exceeds the original frame dimensions!');
end;
if (crop > -1)
    if ((mod(crop(3),2) ~= 0) || (mod(crop(4),2) ~= 0))
        error('Croppping window must be of even dimensions (due to subsampled chroma)!');
    end;
    if ((mod(crop(1)-1,2) ~= 0) || (mod(crop(2)-1,2) ~= 0))
        error('The number of cropped pixels must be even (due to subsampled chroma)!');
    end;
end;

if (strcmp(type,'wav'))
    if (exist('wavelet_downscale','file') ~= 2))
        error('Type wav requires Wavelet toolbox function wavelet_downscale!');
    end;
    wavelet_type = 'CDF_9x7'; %wavelet to be used for downscaling
    if (crop > -1)   
        yscale = crop(3) / outdims(1);
        xscale = crop(4) / outdims(2);
    else
        yscale = dims(1) / outdims(1);
        xscale = dims(2) / outdims(2);
    end;
   
    if (xscale ~= yscale)
            error('For wavelet scaling, the aspect ratio must be preserved!');
    else
        scale = log2(xscale);
        if (round(scale) ~= scale)
            error('Wavelet scaling must be dyadic!');
        end;
    end;
elseif (strcmp(type,'fir'))
    if (exist('fir1','file') ~= 2))
        error('Type fir requires Signal Processing Toolbox (TM) function fir1!');
    end;
elseif (strcmp(type,'imresize'))
    if (exist('imresize','file') ~= 2))
        error('Type imresize requires Image Processing Toolbox (TM) function imresize!');
    end;    
else
    error('Unsupported type of scaling');
end;

if (crop ~= -1)
    cropwinchroma = zeros(2);
    cropwinchroma(:,1) = (cropwin(:,1) - 1)/ 2 + 1;
    cropwinchroma(:,2) = cropwin(:,2) / 2;
    Ycrop{1} = zeros(crop(4),crop(3));
    Ucrop{1} = zeros(crop(4)/2,crop(3)/2);
    Vcrop{1} = zeros(crop(4)/2,crop(3)/2);
end;
outdimschroma = outdims / 2;
Yr{1} = zeros(outdims);
Ur{1} = zeros(outdimschroma);
Vr{1} = zeros(outdimschroma);
if (numfrm == 0)
    numfrm = seq_frames(filename,dims);
    startfrm = 0;
end;
totframes = floor(numfrm / tstep);
frmcnt = 0;
for i = startfrm:tstep:(startfrm + numfrm - 1)
    if (crop ~= -1)
        [Y, U, V] = yuv_import(filename,dims,1,i);
        Ycrop{1} = Y{1}(cropwin(1,1):cropwin(1,2),cropwin(2,1):cropwin(2,2));
        Ucrop{1} = U{1}(cropwinchroma(1,1):cropwinchroma(1,2),cropwinchroma(2,1):cropwinchroma(2,2));
        Vcrop{1} = V{1}(cropwinchroma(1,1):cropwinchroma(1,2),cropwinchroma(2,1):cropwinchroma(2,2));
    else
        [Ycrop, Ucrop, Vcrop] = yuv_import(filename,dims,1,i);
    end;
    
    if strcmp(type,'wav')
        Yr{1} = wavelet_downscale(Ycrop{1},wavelet_type,scale);
        Ur{1} = wavelet_downscale(Ucrop{1},wavelet_type,scale);
        Vr{1} = wavelet_downscale(Vcrop{1},wavelet_type,scale);
    elseif strcmp(type,'fir')
        Yr{1} = fir_downscale(Ycrop{1},scale);
        Ur{1} = fir_downscale(Ucrop{1},scale);
        Vr{1} = fir_downscale(Vcrop{1},scale);
    elseif strcmp(type,'imresize')        
        Yr{1} = imresize(Ycrop{1},[outdims(2) outdims(1)]);
        Ur{1} = imresize(Ucrop{1},[outdimschroma(2) outdimschroma(1)]);
        Vr{1} = imresize(Vcrop{1},[outdimschroma(2) outdimschroma(1)]);
    end;
    yuv_export(Yr,Ur,Vr,outfilename,1);           
    frmcnt = frmcnt + 1;
    fprintf('Frame %d (%d/%d)\n',i+1,frmcnt,totframes);
end;

function B=fir_downscale(A,scale)
%B = fir_downscale(A,scale)
%Downscaling by employing a designed FIR (Hamming) filter
%
%Input: 
% A - array containing an image (can be Y, U or V)
% scale - the scale the image is resized to (e.q. scale=1 halves the image 
%         dimensions)
%      
%Output: 
% B - resized image
%
%Note: 
% Filter order can be changed by modifying the variable 'nn'. The filter is 
% designed with function 'fir1' as a Hamming-window based, linear-phase filter 
% with cutoff frequency that corresponds to the desired reduction in resolution. 
%
%Uses: 
% fir1.m (Signal Processing Toolbox) 
%
%Example:
% B=fir_downscale(A,3);

% sub_pos - defines the subsampling pattern (e.g. if sub_pos=1 
%           the pattern is 1,3,5..)
sub_pos = 1;

nn = 20; %filter order
step=2^scale;
h = fir1(nn,1/step);
%h = gremez(20,[0 0.5 0.55 1],[1 1 0 0]);
lext=length(h);
Aext=zeros(size(A)+2*lext);
Aext(lext+1:lext+size(A,1),lext+1:lext+size(A,2))=A;

Aext(lext:-1:1,:)=Aext(lext+1:2*lext,:);
Aext(lext+size(A,1)+1:size(Aext,1),:)=Aext(lext+size(A,1):-1:lext+size(A,1)-lext+1,:);
Aext(:,lext:-1:1)=Aext(:,lext+1:2*lext);
Aext(:,lext+size(A,2)+1:size(Aext,2))=Aext(:,lext+size(A,2):-1:lext+size(A,2)-lext+1);

B = filter2(h',filter2(h,Aext));
B=B(lext+1:lext+size(A,1),lext+1:lext+size(A,2));

B=B(sub_pos:step:size(B,1),sub_pos:step:size(B,2));
B(B>255)=255;
B(B<0)=0;
B=uint8(round(B));
