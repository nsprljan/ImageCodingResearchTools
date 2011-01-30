function write_floatframe(filename,A)
%Stores matrix in a file as a stream of float numbers
%write_floatframe(filename,A)
%
%Input:
% filename - file in which the matrix will be saved
% A - array to be saved
%
%Example:
% write_floatframe('Afloat',A);

fid=fopen(filename,'w');
if (fid < 0) 
    error('Cannot create file!');
end;
fwrite(fid,A(:),'float32');
fclose(fid);