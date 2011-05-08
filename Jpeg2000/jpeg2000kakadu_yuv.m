function PSNR = jpeg2000kakadu_yuv(yuvfile,dims,fps,brates,numfrm)
%Frontend for the Kakadu JPEG 2000 compression of video sequences in YUV format 
%PSNR = jpeg2000kakadu_yuv(yuvfile,dims,fps,brates,numfrm)
%
%Input:
% yuvfile - YUV sequence file
% dims - dimensions of the frame [width height]
% fps - frames per second
% brates - vector of target bitrates 
% numfrm - number of frames to read from a YUV file
%
%Output:
% PSNR - 3D matrix with PSNR of the compressed YUV sequence, where the 
%        distribution between dimensions is as follows:
%         PSNR(frame,target_layer,component)
%
%Note:
% The location of the JPEG-2000 binaries is specified with the variable
% 'binpath'. The other variables specify the binaries' filenames.
% The expected YUV subsampling format is 4:2:0. 
%
%Uses:
% kdu_compress.exe, kdu_transcode.exe, kdu_expand.exe
% ((c) David Taubman http://www.kakadusoftware.com/)
% iq_measures.m (Quality Assessment toolbox)
% yuv_export.m (YUV Toolbox)
% save_yuvframe.m (YUV Toolbox)
%
%Examples:
% PSNR=jpeg2000kakadu_yuv('CITY_704x576_60_orig_01.yuv',[704 576],60,[2048],2);
% PSNR=jpeg2000kakadu_yuv('RaceHorses_416x240_30.yuv',[416 240],30,[1024 2048],10);

scriptpath=fileparts(which(mfilename)); %in which directory is this m-file
%%%SWITCHES%%%
binpath = [scriptpath '\kakadu'];
KDUenc = [binpath '\kdu_compress.exe'];
KDUtrans = [binpath '\kdu_transcode.exe'];
KDUdec = [binpath '\kdu_expand.exe'];
KDUenc=['"' KDUenc '"'];
KDUtrans=['"' KDUtrans '"'];
KDUdec=['"' KDUdec '"'];
outfileY = 'imageY.pgm';
outfileU = 'imageU.pgm';
outfileV = 'imageV.pgm';
j2cheaderbytes = 149; %to take into account header bytes from FF4F (start of
%code-stream) and FF93 (start of data) markers
%%%%%%%%%%%%%
if (nargin < 5) %go to the starting frame
    numfrm = Inf;
end;
bpp = (brates * 1000 + j2cheaderbytes * 8)/(fps*prod(dims));
bppstrs = cell(numel(bpp),1);
bppstr = [];
for j = 1:numel(bpp)
    bppstrs{j} = num2str(bpp(j));
    bppstr = [bppstr bppstrs{j} ','];
end;
bppstr(end)=[];
YdimH = num2str(dims(1));
YdimW = num2str(dims(2));
UVdimH = num2str(floor(dims(1)/2));
UVdimW = num2str(floor(dims(2)/2));
dimstr = ['{' YdimW ',' YdimH '},{' UVdimW ',' UVdimH '},{' UVdimW ',' UVdimH '}'];
i = 0;
PSNR = zeros(numfrm,numel(bpp),3);
MSE = zeros(numfrm,numel(bpp),3);
while (i < numfrm)
    [s,Yo,Uo,Vo] = save_yuvframe(yuvfile,dims,i,'image');
    i = i + 1;
    fprintf('Processing frame %d\n',i); 
    command = [KDUenc ' -no_info -i imageY.raw,imageU.raw,imageV.raw -o image_compressed.jp2 -rate ',...
        bppstr ' -jp2_space sYCC Scomponents=3 Ssigned=no,no,no Sprecision=8,8,8 Sdims=',...
        dimstr ' Cycc=no CRGoffset={0,0},{0.25,0.25},{0.25,0.25}'];
    [c,w]=dos(command);
    if (c == -1)
        error(['Error while encoding:' w]);
    end;
    delete('imageY.raw');delete('imageU.raw');delete('imageV.raw'); 
    for j=1:numel(bpp)
        outyuvfilename = ['j2k_' bppstrs{j} 'bpp_' yuvfile];
        fprintf('.');
        command = [KDUdec ' -i image_compressed.jp2 -o ' outfileY ',' outfileU ',' outfileV,...
            ' -rate ' bppstrs{j} ' -simulate_parsing -raw_components'];
        [c,w]=dos(command);
        if (c == -1)
            error(['Error while decoding:' w]);
        end;
        ArecY = imread(outfileY);
        ArecU = imread(outfileU);
        ArecV = imread(outfileV);
        delete(outfileY);delete(outfileU);delete(outfileV);
        [MSE(i,j,1), PSNR(i,j,1)] = iq_measures(Yo{1},ArecY);
        [MSE(i,j,2), PSNR(i,j,2)] = iq_measures(Uo{1},ArecU);
        [MSE(i,j,3), PSNR(i,j,3)] = iq_measures(Vo{1},ArecV);
        %if (i == 1) %delete the output yuv file if it exists
        %    fopen(outyuvfilename,'w');
        %end;
        yuv_export({ArecY},{ArecU},{ArecV},outyuvfilename,1);
        fprintf(' Rate = %s bpp, PSNR_Y = %.2f, PSNR_U = %.2f, PSNR_V = %.2f\n', bppstrs{j}, PSNR(i,j,1), PSNR(i,j,2), PSNR(i,j,3));          
    end;
    delete('image_compressed.jp2');
end;
