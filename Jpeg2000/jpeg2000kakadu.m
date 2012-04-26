function [Arec,PSNR,bpp_out] = jpeg2000kakadu(image,bpp,decbpp,res,mode,inchead,varargin)
%Wrappper for running the Kakadu JPEG 2000 binaries
%[Arec,PSNR,bpp_out]=jpeg2000kakadu(image,bpp,decbpp,res,mode,inchead,varargin)
%
%Input: 
% image - matrix or name of the input image
% bpp - vector of target bitrates
% decbpp - vector of bitrates for decompression 
% res - defines reduction of resolution (0 for the original resolution)
% mode - selects mode of compression/decompression: 'truncate', 'parse' or 
%       'transcode'
% inchead - include header size or not (1 for yes, 0 for no). What is meant is 
%           whether some parts of the header are included in the input bitrate 
%           or not. Kakadu specifies the rates that correspond to the resulting 
%           .j2c complete file sizes, but in some cases we might be interested 
%           only in the pure non-header part of the bit-stream.  
%           -if inchead == 1 then the fixed part of the header (total length 
%            minus the lenght of the header comment) is included in the input 
%            bit-rate. In other words, the bit-rate corresponding to the length 
%            of the comment (110 bytes) is added to the input bit-rate since it 
%            is the only part of the header that I did not want to be included.
%           -if inchead == 1 then the bit-rate includes only the image data part
%            of the bit-stream. The whole header is added to the bit-rate, so 
%            the Kakadu does not include it in the bit-rate of the image data 
%            part of the bit-stream.
% varargin - aditional parameters
%
%Output: 
% Arec - output image (only for the maximum bitrate)
% PSNR - vector of PSNR values for decode bitrates
% bpp_out - output bpp (when lower quality/resolution part is extracted 
%           from the compressed bit stream) 
%Note:
% *WARNING* Place the required binaries under ./kakadu directory!
% The location of the JPEG-2000 binaries is specified with the variable
% 'binpath'. The other variables specify the binaries' filenames.
% The expected YUV subsampling format is 4:2:0. 
% I am not sure though if the constants used for inchead are still valid as I 
% have switched to the new version of Kakadu at some point but have not changed 
% that part of the code.
%                   
%Uses: 
% kdu_compress.exe, kdu_transcode.exe, kdu_expand.exe, kdu_v(version).dll
% ((c) David Taubman http://www.kakadusoftware.com/) Version 4.0.3 required
%  for selecting the option 'parse'.
%
% iq_measures.m (Quality Assessment toolbox)
% wavelet_downscale.m (Wavelet toolbox)
% 
%Examples:
% [Arec,PSNR,bpp_out] = jpeg2000kakadu('Lena512.png',1,1,0,'parse',1);  
% [Arec,PSNR,bpp_out] = jpeg2000kakadu('Lena512.png',4,0.25:0.25:1.25,1,'parse',1);  
% [Arec,PSNR,bpp_out] = jpeg2000kakadu('Lena512.png',1,0.1:0.1:1,0,'transcode',0);

scriptpath=fileparts(which(mfilename)); %in which directory is this m-file
%%%SWITCHES%%%
binpath = [scriptpath '\kakadu'];
KDUenc = [binpath '\kdu_compress.exe'];
KDUtrans = [binpath '\kdu_transcode.exe'];
KDUdec = [binpath '\kdu_expand.exe'];
%%%%%%%%%%%%%
fid = fopen(KDUenc);
if (fid == -1) error('Kakadu encoder executable not found!');end;
fclose(fid);
fid = fopen(KDUdec);
if (fid == -1) error('Kakadu decoder executable not found!');end;
fclose(fid);
fid = fopen(KDUtrans);
if (fid == -1) error('Kakadu transcoder executable not found!');end;
fclose(fid);
KDUenc=['"' KDUenc '"'];
KDUtrans=['"' KDUtrans '"'];
KDUdec=['"' KDUdec '"'];

if isstr(image) %if variable image is a string then it refers to the image file
    A=imread(image);   
else %otherwise variable image is a matrix
    if strcmp(class(image),'double') 
        A=uint8(round(image));
    else
        A=image;
    end;
end; 
imwrite(A,'image.bmp');
s=size(A);numpix=s(1)*s(2);
if ~inchead
    header_size=288*8; %bits
else %exclude only the comment segment
    header_size=110*8; %bits
end;
    addbpp=header_size/numpix;
    bpp=bpp+addbpp;
    hddecbpp=decbpp+addbpp;
if ~isempty(varargin)
    adit=varargin{1};
else
    adit=[];
end;
%computing the reference image
compclr = size(A,3);
if res>0
    if compclr>1
        Aref(:,:,1)=wavelet_downscale(A(:,:,1),'CDF_9x7',res);
        Aref(:,:,2)=wavelet_downscale(A(:,:,2),'CDF_9x7',res);
        Aref(:,:,3)=wavelet_downscale(A(:,:,3),'CDF_9x7',res);
    else
        Aref=wavelet_downscale(A,'CDF_9x7',res);
    end;
else
    Aref=A;
end;


bppstr=num2str(bpp,'%0.6f,');bppstr(end)=[]; %remove the trailing ','
ratestr=[' -rate ' bppstr];
command=[KDUenc ' -i image.bmp -o image_compressed.j2c' ratestr ' -record compress_record.txt ' adit];
[c,w]=dos(command);
% fid=fopen('image_compressed.j2c','r');
% [bitstream,byte_count] = fread(fid,'ubit8');
% fclose(fid);

if strcmp(mode,'transcode')
    hddecbpp=hddecbpp*4^res; %to keep decoding bitrate consistent with the original image size
end;
for j=1:length(hddecbpp)
    outfilename=['image_decompressed' num2str(decbpp(j)) '.bmp'];
    switch mode
    case 'truncate'
        command=[KDUdec ' -i image_compressed.j2c -o ' outfilename ' -rate ' num2str(hddecbpp(j)) ' -reduce ' num2str(res)];
    case 'parse'
        command=[KDUdec ' -i image_compressed.j2c -o ' outfilename ' -rate ' num2str(hddecbpp(j)) ' -simulate_parsing -reduce ' num2str(res)];
    case 'transcode'
        command=[KDUtrans ' -i image_compressed.j2c -o image_transreduced.j2c -reduce ' num2str(res) ' -rate ' num2str(hddecbpp(j))];
    end;
    [c,w]=dos(command);
    if c==-1
        error(['Error while decoding:' w]);
    end;
    strrows=strread(w,'%s','delimiter','\n'); %parse the message to find the size of extracted portion of the file
    switch mode
    case 'transcode' 
        [bytes,bpp_realk]=strread(strrows{9},'Total bytes written = %d = %f bits/pel.');
        command=[KDUdec ' -i image_transreduced.j2c -o '  outfilename];
        [c,w]=dos(command);
        if c==-1
            error(['Error while decoding:' w]);
        end; 
    otherwise
        [bytes,bpp_realk]=strread(strrows{3},'Code-stream bytes (excluding any file format) = %d = %f bits/pel.');
    end;
    bpp_out(j)=8/(numpix/bytes); %original image is supposedly 8bpp
    if ~strcmp(mode,'transcode')
        fprintf('%d. bitrate %f bpp (%f bpp):\n',j,hddecbpp(j),bpp_out(j));
    else
        fprintf('%d. bitrate %f bpp (%f bpp):\n',j,hddecbpp(j)/4^res,bpp_out(j));  
    end;
    Arec=imread(outfilename);
    [MSE(j,:),PSNR(j,:)]=iq_measures(Aref,Arec,'disp');  
    delete(outfilename);
end;
%comment these out to disable deleting
delete('image.bmp');
delete('compress_record.txt');
delete('image_compressed.j2c');