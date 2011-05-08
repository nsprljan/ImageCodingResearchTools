function [Arec,bitstream,PSNR]=spspiht(A,bpp,type)
%[Arec,bitstream,PSNR]=spspiht(A,bpp,type)
%Script for batch execution of DOS SPIHT binaries 
%
%Input: 
% A - array containing the original image or its filename
% bpp - vector of target decoding bitrates (bpp=bits per pixel)
% type - [optional, default = ''] specifies in which mode to run SPIHT 
%         if (type == '') arithemtic coding  
%         if (type == 'fast') binary coding
%
%Output:
% Arec - reconstructed image
% bitstream - SPIHT output bitstream 
% PSNR - PSNR of the reconstructed images (for all bpps)
%
%Note: The required binaries have to reside in the \spihtexe directory. 
% This scripts deletes all the files created by the binaries.
% Arec output is for the last specified bit-rate in bpp. SPIHT binaries
% must be in the the folder specified with variable binpath.
%
%Uses: 
% fastcode.exe, fastdecd.exe, codetree.exe, decdtree.exe 
% ((c)1995, 1996 Amir Said & William A. Pearlman  
%  http://www.cipr.rpi.edu/research/SPIHT/spiht3.html)
% iq_measures.m (Quality Assessment toolbox)
%
%Example:
% [Arec,bitstream,PSNR]=spspiht('Lena512.png',1,'fast');
% [Arec,bitstream,PSNR]=spspiht(A,[0.1 1]); 

if nargin==2
    type='';
end;
scriptpath=fileparts(which(mfilename));
%%%SWITCHES%%%
binpath = [scriptpath '\spihtexe'];
SPIHTencfast = [binpath '\fastcode.exe'];
SPIHTenc = [binpath '\codetree.exe'];
SPIHTdecfast = [binpath '\fastdecd.exe'];
SPIHTdec = [binpath '\decdtree.exe'];
%%%%%%%%%%%%%
if strcmp(type,'fast')
    fid = fopen(SPIHTencfast);
    if (fid == -1) error('SPIHT binary encoder executable not found!');end;
    fclose(fid);
    fid = fopen(SPIHTdecfast);
    if (fid == -1) error('SPIHT binary decoder executable not found!');end;
    fclose(fid);    
else
    fid = fopen(SPIHTenc);
    if (fid == -1) error('SPIHT encoder executable not found!');end;
    fclose(fid);
    fid = fopen(SPIHTdec);
    if (fid == -1) error('SPIHT decoder executable not found!');end;
    fclose(fid);
end;
SPIHTencfast=['"' SPIHTencfast '"'];
SPIHTenc=['"' SPIHTenc '"'];
SPIHTdecfast=['"' SPIHTdecfast '"'];
SPIHTdec=['"' SPIHTdec '"'];

if isstr(A)
    A=imread(A);   
else
    if strcmp(class(A),'double') A=uint8(round(A));end;
end; 
s=size(A);
maxbpp=max(bpp);
fid=fopen('spiht.pic','w');
fwrite(fid,A(:),'uint8');
fclose(fid);
if strcmp(type,'fast')
    naredba=[SPIHTencfast ' spiht.pic spiht.sc ' num2str(s(2)) ' ' num2str(s(1)) ' 1 ' num2str(maxbpp)];
else
    naredba=[SPIHTenc ' spiht.pic spiht.sc ' num2str(s(2)) ' ' num2str(s(1)) ' 1 ' num2str(maxbpp)];
end;    
tic;
[c,w]=dos(naredba);
fid=fopen('spiht.sc','r');
[bitstream,count] = fread(fid,'ubit1');
fclose(fid);
fprintf('Number of bits = %d(%d bytes, %.4f bpp)\n',count,count/8,count/numel(A));
for i=1:length(bpp)
    if strcmp(type,'fast')
        naredba=[SPIHTdecfast ' -s spiht.sc despiht.pic ' num2str(bpp(i))]; 
    else
        naredba=[SPIHTdec ' -s spiht.sc despiht.pic ' num2str(bpp(i))]; 
    end;
    [c,w]=dos(naredba);   
    fid=fopen('despiht.pic','r');
    B=fread(fid,'uint8');
    Arec=reshape(uint8(B),s(1),s(2));
    fclose(fid);
    delete despiht.pic;
    fprintf('\n%d. bitrate - %.4f bpp\n',i,bpp(i));
    [MSE,PSNR(i)]=iq_measures(Arec,A,'disp');
end;
fprintf('\nTotal execution time - %.2f seconds\n',toc);
%comment these out to disable deleteing
delete spiht.pic;
delete spiht.sc;