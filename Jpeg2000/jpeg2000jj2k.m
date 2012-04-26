function [Arec,PSNR]=jpeg2000jj2k(A,bpp,outf)
%Wrapper for running the JJ2000 java byte code
%[Arec,PSNR]=jpeg2000jj2k(A,bpp,outf)
%
%Input: 
% A - array containing the original image or its filename
% bpp - vector of target decoding bitrates (bpp=bits per pixel) 
% outf - [optional, default = 0] if outf is not 0 the results will be 
%        saved into files
%
%Output:
% Arec - reconstructed images as a cell variable 
%
%Note: 
% *WARNING* Place the required jar file in this toolbox directory!
% Colour images are supported. 
% VJVM has to be installed on the machine, see e.g.: 
% http://www.java.com/en/download/manual.jsp
%
%Uses: 
% -The only implementation of JJ2000 that currently can be found on the web 
% is at http://anabuilder.free.fr/jj2000-5.1.jar
% However this is not the original location, as the authors' location for 
% dowload is not online any more:  http://jj2000.epfl.ch/jj_download/index.html
% -iq_measures.m (Quality Assessment Toolbox)
%
%Example:
% Arec=jpeg2000jj2k(A,0.1,0); 
% [Arec,PSNR]=jpeg2000jj2k('Lena256.png',[0.1 0.5 1],1);
%
%Java calling examples:
% javaaddpath(fullfile(pwd,'jj2000-4.1.jar'))
% javaclasspath
% methods JJ2KEncoder -full
% methodsview JJ2KEncoder 
% javaMethod('JJ2KEncoder.main')
% JJ2KEncoder.main({'-i','pict.pgm','-o','out.j2k','-rate','2'})

Arec = {[]};
jj2000jar = 'jj2000-5.1.jar'; %replace with the jar file available
if (exist(jj2000jar) ~=2)
 disp(sprintf(['Error: The file ' jj2000jar ' is not on the path, the program cannot be performed!']));
 disp(sprintf('JJ2000 can be downloaded from http://jj2000.epfl.ch'));
 return
end;
if (exist('iq_measures.m') ~= 2)
 disp(sprintf('Warning: The function iq_measures.m is not on the path, the PSNR computation will not be performed!'));
 disp(sprintf('Function iq_measures.m is a part of Quality Assessment Toolbox'));
end;
if nargin<3
    outf=0;
end;    
%init java
p=javaclasspath;
jjpath = fullfile(pwd,jj2000jar);
jjex = 0;
for i=1:length(p) 
    jjex = jjex || strcmp(jjpath,p{i});
end
if (~jjex)
    javaaddpath(jjpath);
end;
%init the rest
n=size(bpp,2);
maxbpp=max(bpp);
direktorij=fileparts(which(mfilename));
compclr=1;
if ~isstr(A)
    A=uint8(A);
    ext='.pgm';
else  
    imf=imfinfo(A);
    if imf.BitDepth==8
        ext='.pgm';
    elseif imf.BitDepth==24
        ext='.ppm';
        compclr = 3; 
    end; 
    %fprintf('        Original image bitrate: %d bpp\n',imf.BitDepth);  
    A=imread(A);    
end;
PSNR = zeros(n,compclr);
imedat='pict';
fullimedat=[imedat ext];
imwrite(A,fullimedat);
%compression
imekod=[imedat '_JJ2_' num2str(maxbpp) '.j2k'];
JJ2KEncoder.main({'-i',fullimedat,'-o',imekod,'-rate',num2str(maxbpp)});
%delete temporay image
delete(fullimedat);
%decompression loop
for i=1:n
    strbpp=strrep(num2str(bpp(i)),'.','');
    imeprvo=imedat(1);
    imevan=[imeprvo '_' strbpp];
    if size(imevan,2)>8
        imevan=imevan(1:8);
    end;
    fullimevan=[imevan ext];
    JJ2KDecoder.main({'-i',imekod,'-o',fullimevan,'-rate',num2str(bpp(i))});
    if outf
        Arec{i}=fullimevan;
    else
        Arec{i}=imread(fullimevan);
        delete(fullimevan);
    end;
    [MSE,PSNR(i,:)]=iq_measures(A,Arec{i});
end;
%delete(imekod); %for some reason the file cannot be closed nor deleted
    