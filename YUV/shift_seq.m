function shift_seq(filename,dims,frame,numfrm,startw,dimw,shiftw,outfilename)
%Artificially shifts a sequence in a defined direction by any displacement 
%shift_seq(filename,dims,frame,numfrm,startw,dimw,shiftw,outfilename)
%
%Input:
% filename - YUV sequence file
% dims - dimensions of the frame [width height]
% frame - which frame to take
% numfrm - number of frames to generate
% startw - left upper coordinate of the window to be shifted
% dimw - window dimension (part of the frame to be shifted) 
% shiftw - number of pixels to move the window per one frame
% outfilename - filename of the output YUV sequence
%
%Uses: 
% yuv_import.m (for reading a frame from the yuv file)
% yuv_export.m (for storing a frame to the yuv file)
%
%Example:
% shift_seq('CITY_704x576_30_orig_01.yuv',[704 576],1,16,[100 100],[352 288],[0.5 0.5],'shiftcity.yuv');

[Y, U, V] = yuv_import(filename,dims,1,frame);

scol = shiftw(1); %shift columns
srow = shiftw(2); %shift rows
wcolY = dimw(1); %window columns luma
wrowY = dimw(2); %window rows luma
wcolC = dimw(1)/2; %window columns chroma
wrowC = dimw(2)/2; %window rows chroma
wstr = startw(2);
wstc = startw(1);

%for interpolation 
[xY,yY] = meshgrid(1:dims(1),1:dims(2));
[xC,yC] = meshgrid(1:dims(1)/2,1:dims(2)/2);

for i=0:numfrm-1
    stepr = i*srow;
    stepc = i*scol;
    sr = stepr + wstr;
    sc = stepc + wstc;
    if ((floor(sr) == sr) && (floor(sc) == sc))
        Yr{1} = Y{1}(sr:wrowY+sr-1,sc:wcolY+sc-1);
    else
        [XI,YI] = meshgrid(sc:wcolY+sc-1,sr:wrowY+sr-1);
        Yr{1} = interp2(xY,yY,Y{1},XI,YI,'spline');
    end;
    sr = double(sr) / 2;
    sc = double(sc) / 2;
    if ((floor(sr) == sr) && (floor(sc) == sc))
        Ur{1} = U{1}(sr:wrowC+sr-1,sc:wcolC+sc-1);
        Vr{1} = V{1}(sr:wrowC+sr-1,sc:wcolC+sc-1);
    else
        [XI,YI] = meshgrid(sc:wcolC+sc-1,sr:wrowC+sr-1);
        Ur{1} = interp2(xC,yC,U{1},XI,YI,'spline');
        Vr{1} = interp2(xC,yC,V{1},XI,YI,'spline');
   end; 
   yuv_export(Yr,Ur,Vr,outfilename,1);
   fprintf('Frame %d/%d\n',i+1,numfrm);
end;

