function [S,Sind,Sdim]=subband(D,N,band)
%[S,Sind,Sdim]=subband(D,N,band)
%Version: 3.01, Date: 2005/01/01, author: Nikola Sprljan
%
%Input: 
% D - array of wavelet coefficients
% N - specifies the decomposition level
% band - specifies the subband ('ll', 'hl', 'lh' or 'hh')
%
%Output: 
% S - array of the subband wavelet coefficients
% Sind - indices of elements of the selected subband
% Sdim - dimensions of the selected subband 
%
%Note: 
% ('ll', 'hl', 'lh', 'hh') corresponds to ('a', 'h', 'v' ,'d')
%
%Uses:
% subband_dim.m
%
%Example:
% D=dwt_dyadic_decomp(A,'CDF_9x7',4);
% S=subband(D,4,'hl');
% S=subband(D,6,'ll');
 
if (ndims(D) ~= 2)
    error('Wavelet coefficients array of other dimensions than 2D!');
end;

[sizrow,sizcol] = size(D);
[ldr,hdr]= subband_dim(sizrow, N);
[ldc,hdc]= subband_dim(sizcol, N);
Sind = [];
switch band
    case 'll'
        Sind{1} = 1:ldr;
        Sind{2} = 1:ldc;
        Sdim = [ldr ldc];
    case 'hl'
        Sind{1} = 1:ldr;
        Sind{2} = ldc+1:ldc+hdc;
        Sdim = [ldr hdc];
    case 'lh'
        Sind{1} = ldr+1:ldr+hdr;
        Sind{2} = 1:ldc;
        Sdim = [hdr ldc];
    case 'hh'
        Sind{1} = ldr+1:ldr+hdr;
        Sind{2} = ldc+1:ldc+hdc;
        Sdim = [hdr hdc];
end;
S = D(Sind{:});
