function Drec_opt=pdf_opt(Drec,quantstep)
% Drec_opt=pdf_opt(Drec,quantstep)
% Version: 1.00, Date: 2004/01/01, author: Nikola Sprljan
% Optimisation (pdf) of reconstructed values of quantised wavelet coefficients
% 
%Input: 
% Drec - array of quantised wavelet coefficients
% quantstep - quantisation step
%
%Output:
% Drec_opt - array of wavelet coefficients with optimised reconstructed values
%
%Note:
% The 'optimisation' is performed in regard to the probability density function
% (pdf) of the waveelet coefficients, which posseses a Laplacian distribution.
% The optimisation can be tweaked by varying the constants 'pdfq' and 'pdfn'.
% Function takes into account that some of the coefficients can be quantised 
% to 2*quantstep.
% The quantisation is assumed to be dead-zone quantisation.
%
%Example:
% (This example demonstrates that using the pdf-optimised reconstruction of 
% quantised wavelet coefficients a meagre improvement of ~0.02 dB can be 
% expected on high bit-rates.)
% D=dwt_dyadic_decomp('Lena256.png','CDF_9x7',6);
% qstep = 4; %quantisation step is 4
% Dq = dead_zone_q(D,qstep); 
% Drec_opt = pdf_opt(Dq,qstep);
% iq_measures(idwt_dyadic_recon(Dq,'CDF_9x7',6),'Lena256.png'); 
% iq_measures(idwt_dyadic_recon(Drec_opt,'CDF_9x7',6),'Lena256.png');

%CONSTANTS
%values pdfq=0.38 and pdfn=2 are as in the original SPIHT 
pdfq=0.38;
pdfn=2; 

pass=ceil(log2(max(max(abs(Drec)))) - log2(quantstep)); %number of bit-planes
t=1:pass-1;
bias(t+1)=0.5*(1-0.5*ones(1,pass-1)./((t+1).^pdfn));
bias(1)=pdfq;
biasold(t+1)=bias(t);
bias=quantstep*(0.5-bias); 
biasold=2*quantstep*(0.5-biasold);

[Inx,Iny,DIn]=find(abs(Drec)); %indices of non-zero elements

if ~isempty(DIn)
    DInq=DIn./quantstep;
    In_halfquant=find(round(DInq)~=DInq); %indices of elements quantized at half-quantstep (final pass) 
    In_quant=setdiff(1:size(DIn,1),In_halfquant); %indices of elements quantized at quantstep (prev. pass) 
    
    optc=bias(ceil(log2(DInq(In_halfquant)))).';
    if size(optc,2)>size(optc,1) %to prevent errors when pass==1
        optc=optc.';
    end; 
    if ~isempty(In_halfquant) 
        DIn(In_halfquant)=DIn(In_halfquant)-optc;
    end;
    if ~isempty(In_quant)
        DIn(In_quant)=DIn(In_quant)-biasold(ceil(log2(DInq(In_quant)))).';
    end;
    Drec_opt=zeros(size(Drec));
    In=Inx+(Iny-1).*size(Drec,1);
    Drec_opt(In)=sign(Drec(In)).*DIn;
else
 Drec_opt=Drec;
end; 