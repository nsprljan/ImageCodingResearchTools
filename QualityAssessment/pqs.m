function PQS=pqs(A,B,blok)
%Script that runs PQS (Picture Quality Scale) image quality measure 
%PQS = pqs(A,B,blok)
%
%Input: 
% A - array containing the original image or its filename
% B - array containing the compressed image or its filename
% blok - [optional, default = size(A,1)] size of the block that 
%        the compression algorithm uses. In a default case, when the function 
%        is called without the 'blok' parameter, the dimension of the input 
%        image is used instead (the whole image is treated as a block).
%
%Output: 
% PQS - Picture Quality Scale; number from range 0-5 specifying the quality of 
%       the compressed image (note that it can fall out of range 0-5!) 
%
%Note:
% This function is based in on CIPIC PQS version 1 software. The DOS program 
% pqs.exe must be located in the subdirectory \Pqs. For more information refer 
% to \Pqs\README; just one important excerpt:
%  "PQS was designed and tested on 256 x 256 images...its use with other than 
%  256 x 256 images at 4 times picture height is shaky." 
% PQS works only for square images!
%
%Uses: 
% .\Pqs\pqs.exe (c) 1996, Robert R. Estes, Jr. and V. Ralph Algazi
%
%Example:  
% PQS=pqs(A,B,8);
% PQS=pqs('Lena256.png','LenaSPIHT0.1bpp.bmp'); 

if isstr(A)
  A=imread(A);   
 end;
 if isstr(B)
  B=imread(B);   
 end; 
 PQS = -1;
 if (size(A,1) ~= size(A,2))
   error('Works only for square images!');   
 end;
 siz=size(A,1);
 if nargin==2
  blok=siz;    
 end;
 if ~((size(A,1) == size(B,1)) & (size(A,2) == size(B,2)))
   error('Images must have the same dimensions!');   
 end;
 where=[fileparts(which(mfilename)) '\Pqs'];
 pic1=[where '\pic1.pqs '];
 fid1=fopen(pic1,'w');
 Ad=double(A);
 fwrite(fid1,Ad,'uint8');
 fclose(fid1);
 pic2=[where '\pic2.pqs '];
 fid2=fopen(pic2,'w');
 Bd=double(B);
 fwrite(fid2,Bd,'uint8');
 fclose(fid2);
 rez=[where '\rez.txt'];
 naredba=[where '\pqs.exe -b ' num2str(blok) ' -s ' num2str(siz) ' ' pic1 pic2 ' > ' rez];
 [c,w]=dos(naredba);
 disp(w);
 fid=fopen(rez);
 st=fscanf(fid,'%s');
 PQS=str2num(st(5:size(st,2)));
 fclose(fid);
 delete(pic1);
 delete(pic2);
 delete(rez);