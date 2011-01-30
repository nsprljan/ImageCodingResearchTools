function X=read_floatframe(filename,dims,disp)
%Reads and displays frame values stored as a stream of float numbers  
%X=read_floatframe(filename,dims,disp)
%
%Input:
% filename - file that contains the frame
% dims - dimensions of the frame [height width]
% disp  - [optional, default = 1] specifies whether to display the output  
%            if (disp ~= 0) then display
%            if (disp == 0) then do not display
%
%Output:
% X - array of numbers containing the frame elements
%
%Uses:
% image_show.m (Quality Assessment Toolbox)
%
%Example:
% X = read_floatframe('GOP000_TFrame_0_01_L_Y',[576 704]);

if nargin<3 %display by default  
    disp=1;
end;

fid=fopen(filename,'r');
if (fid < 0) 
    error('File does not exist!');
end;
X = fread(fid,[dims(2) dims(1)],'float32');
fclose(fid);
X=X';
if (disp == 1)
    image_show(X,256,1,filename); %comment out this to disable displaying
    %imwrite(I,gray(256),[filename '.png'],'png'); %uncomment this line to save as png image
end;