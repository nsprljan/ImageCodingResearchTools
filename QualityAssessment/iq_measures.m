function [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE,PQS]=iq_measures(A,B,disp)
%Image Quality Measures - various measures of reconstructed image quality
%[MSE,PSNR,AD,SC,NK,MD,LMSE,NAE,PQS] = iq_measures(A,B,disp)
%
%Input: 
% A - array containing the original image or its filename
% B - array containing the compressed image or its filename
% disp - [optional, default = do not display] specifies whether the results 
%        are displayed
%         if (disp == 'disp') all results are displayed on a command prompt
%         if (disp ~= 'disp') results are not displayed
%
%Note: 
% Number of specified outputs will defined what is actually computed.
% if (nargout == 2) only MSE and PSNR are computed
% if (nargout == 8) the PQS is not computed
% if (nargout == 9) all measures are computed
%
%Output: 
% MSE - Mean Squared Error
% PSNR - Peak Signal to Noise Ratio
% AD - Average Difference
% SC - Structural Content
% NK - Normalized Cross-Correlation
% MD - Maximum Difference
% LMSE - Laplacian Mean Squared Error
% NAE - Normalized Absolute Error
% PQS - Picture Quality Scale 
%
%Uses:
% pqs.m (for computation of PQS)
%
%Example:
% [MSE,PSNR]=iq_measures(A,B);
% [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE]=iq_measures('Lena1.png','Lena2.png');
% [MSE,PSNR]=iq_measures(A,'Lena2.png','disp');

if nargin<3 
    disp=0;
else
    disp = strcmp(disp,'disp');
end;
if isstr(A)
    A=imread(A);
end;
if isstr(B)
    B=imread(B);
end;
if ~isa(A,'double')
    A=double(A);
end;
if ~isa(B,'double')
    B=double(B);
end;
 if (nargout <= 2)
    numout = 1;
elseif (nargout <= 8)
    numout = 2;
else
    numout = 3;
end;
clrcomp = size(A,3); 
MSE = zeros(1,clrcomp);
PSNR = zeros(1,clrcomp);
AD = zeros(1,clrcomp);
SC = zeros(1,clrcomp);
NK = zeros(1,clrcomp);
MD = zeros(1,clrcomp);
LMSE = zeros(1,clrcomp);
NAE = zeros(1,clrcomp);
PQS = zeros(1,clrcomp);
for i=1:size(A,3)
 if (disp && (clrcomp > 1)) fprintf('Component %d\n',i);end;
 [MSE(i),PSNR(i),AD(i),SC(i),NK(i),MD(i),LMSE(i),NAE(i),PQS(i)]=measureQ(A(:,:,i),B(:,:,i),disp,numout);
end;

function [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE,PQS]=measureQ(A,B,disp,numout)
x=size(A,2);
y=size(A,1);
R=A-B;
Pk=sum(sum(A.^2));
MSE=sum(sum(R.^2))/(x*y); % MSE
if disp~=0 fprintf('MSE (Mean Squared Error) = %f\n',MSE);end;
% PSNR
if MSE>0 
    PSNR=10*log10(255^2/MSE); 
else 
    PSNR=Inf;
end;
if disp~=0 fprintf('PSNR (Peak Signal / Noise Ratio) = %f dB\n',PSNR);end;

if numout>1
    AD=sum(sum(R))/(x*y); % AD
    if disp~=0 fprintf('AD (Average Difference) = %f\n',AD);end;
    Bs = sum(sum(B.^2));
    if (Bs == 0)
        SC = Inf;
    else
        SC=Pk/sum(sum(B.^2)); % SC
    end;
    if disp~=0 fprintf('SC (Structural Content) = %f\n',SC);end;
    NK=sum(sum(A.*B))/Pk; % NK
    if disp~=0 fprintf('NK (Normalised Cross-Correlation) = %f\n',NK);end;
    MD=max(max(abs(R))); % MD
    if disp~=0 fprintf('MD (Maximum Difference) = %f\n',MD);end;
    % LMSE
    OP=4*del2(A);
    LMSE=sum(sum((OP-4*del2(B)).^2))/sum(sum(OP.^2));
    if disp~=0 fprintf('LMSE (Laplacian Mean Squared Error) = %f\n',LMSE);end;
    NAE=sum(sum(abs(R)))/sum(sum(abs(A))); % NAE
    if disp~=0 fprintf('NAE (Normalised Absolute Error) = %f\n',NAE);end;
else 
    AD=0;
    SC=0;
    NK=0;
    MD=0;
    LMSE=0;
    NAE=0;
end;
if (numout>2)&(x==y) 
    % PQS
    PQS=pqs(A,B,x);
    if disp~=0 fprintf('PQS (Picture Quality Scale) = %f\n',PQS);end;
else 
    PQS=0;
end;