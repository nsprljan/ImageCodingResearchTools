function [Arec,PSNR]=ezw(A,bpp,N,wavelet);
%[Arec,PSNR]=ezw(A,bpp,N,wavelet) 
%Version: 1.02, Date: 2005/04/30, author: Nikola Sprljan, Andrej Skenderovic
%EZW (Embedded Zerotree Wavelet) image compression
%
% A - array containing the original image or its filename, or a test data
%     saved in a mat file with a prefix 'ezw'
% bpp - target decoding bitrate (bpp=bits per pixel) 
% N - number of levels of wavelet dyadic decomposition.
% wavelet - wavelet identification string
%
%Output:
% Arec - reconstructed image
% PSNR - PSNR of the reconstructed images (for all bpps)
%
%Note: 
% Entropy coding is not used, so the output stream is composed of symbols
% ('pmzt'). When the test data files are loaded instead of image, then the 
% output symbols are displayed.
% Apologies for comments in Croatian :)
% 
%Uses:
% ..\Wavelet\load_wavelet.m (Wavelet Toolbox)
% ..\Wavelet\dwt_dyadic_decomp.m (Wavelet Toolbox)
% ..\Wavelet\idwt_dyadic_recon.m (Wavelet Toolbox)
% ..\QualityAssesment\iq_measures.m (Quality Assessment Toolbox)
%
%Example:
% [Arec,PSNR]=ezw('Lena.png',0.1,2,'CDF_9x7');
% ezw('ezw_testdata1.mat',8,2,'CDF_9x7');

fprintf('Image %s, %d decompositions, %s wavelet, bitrate %f bpp\n',...
    A,N,wavelet,bpp);
output=0;
if isstr(A)
    if strcmp(A(1:3),'ezw') %ezw test matrix in a .mat file
     load(A);
     fprintf('\nExample matrix:\n');
     disp(A);
     output=1;
    else 
     A=imread(A);
    end;
end;
if (ndims(A)>2) 
    error('Only indexed images are supported!');
end;

D=dwt_dyadic_decomp(A,wavelet,N);
brojbit=bpp*prod(size(D)); %number of output bitov
tic;
[Drec,countbit]=ezwalg(D,N,brojbit,output);%EZW algorithm
fprintf('\nEZW algorithm executed in %f seconds\n',toc);
fprintf('\nNumber of output bits: %d\n',countbit); 
Arec=idwt_dyadic_recon(Drec,wavelet,N);
[mse,PSNR]=iq_measures(A,Arec,'disp'); %compute PSNR

function [Drec,countbit]=ezwalg(D,N,brojbit,output)
%EZW algorithm - produces the decoded image (joint coding/decoding and
%reconstruction)

%definition of symbols codes 
% Pos=0;    % 00
% Neg=1;    % 01
% zTree=2;  % 10
% Zero=3;   % 11

%the lowest threshold - the encoding is restricted up to a certain bitplane,
%so you the target bitrate that is to high, the encoding will stop at some point 
%before reaching that bitrate. 
lwsthresh = 2^(-3);

[Drows,Dcols]=size(D);
Drec=zeros(Drows,Dcols);
countbit=0;
subrN=Drows/2;    %dimensions of the highest subbands
subcN=Dcols/2;
subr=Drows/(2^N); %dimensions of the lowest subbands
subc=Dcols/(2^N);
%initialisation of the FIFO structure
i=1:subr;
j=1:subc;
LLc=repmat(j,[1 subr]);
HLc=repmat(j+subc,[1 subr]);
LLr=reshape(repmat(i,[subc 1]),1,subr*subc);
LHr=reshape(repmat(i+subr,[subc 1]),1,subr*subc);
%FIFO struktura ustvari sadrzi koordinate koeficijenata (ali kazemo da sadrzi koeficijente)
%u fifo prvo postavljamo koeficijente najnizih subbanda
FIFO=zeros(4*subr*subc,2);
FIFO(:,1)=[LLr LLr LHr LHr]'; % FIFO(:,1) sadrzi koordinate retka
FIFO(:,2)=[LLc HLc LLc HLc]'; % FIFO(:,2) sadrzi koordinate stupca
fifosize=size(FIFO,1);
FIFObackup=FIFO;
%SGNF ce sadrzavati koeficijente koji su veci od praga     
SGNF=0;
sgnfsize=0;
sgnfsizeold=0;
nbit=floor(log2(max(max(abs(D)))));
prag=2^nbit;
prolaz=1; 
while prag>lwsthresh
    if output
        fprintf('%d. pass\n',prolaz);
    end;
    init=prag*3/2; 
    fifocnt=1;
    while fifocnt<=fifosize
        i=FIFO(fifocnt,1);
        j=FIFO(fifocnt,2);
        if abs(D(i,j))>=prag %ako je veci tada se radi o P ili N
            if D(i,j)>0
                Drec(i,j)=init; %Instant rekonstrukcija
                if output
                    fprintf('p '); %kontrolni izlaz 
                end;
            else
                Drec(i,j)=-init; %Instant rekonstrukcija
                if output
                    fprintf('n '); %kontrolni izlaz
                end;
            end;
            %apsolutna vrijednost koeficijenta ide u SGNF
            sgnfsize=sgnfsize+1;
            SGNF(sgnfsize,1)=abs(D(i,j))-prag; %za koeficijenta ostaje bitno samo koliko je veci od praga
            SGNF(sgnfsize,2:3)=[i,j];
            D(i,j)=0; % koeficijent se postavlja u nulu
            %ako se ne nalazi u najvisem ili najnizem subbandu, tj. ima djecu onda treba i njih provjeriti
            if ~((i>subrN | j>subcN) | (i<=subr & j<=subc)) 
                id=i*2-1;
                jd=j*2-1; 
                FIFO(fifosize+1:fifosize+4,1)=[id id id+1 id+1]'; % FIFO(:,1) sadrzi koordinate retka
                FIFO(fifosize+1:fifosize+4,2)=[jd jd+1 jd jd+1]'; % FIFO(:,2) sadrzi koordinate stupca
                fifosize=fifosize+4;
            end; 
        else %inace je T ili Z
            %provjera da li je rijec o T ili Z
            if i<=subr & j<=subc
                if output
                    fprintf('z '); %kontrolni izlaz
                end; 
            else    
                s=search_children_ezw(2*i-1,2*j-1,2*subrN,2*subcN,D,prag);
                if s %ako je ijedan potomak veci od praga tada je rijec o Z
                    if output
                        fprintf('z '); %kontrolni izlaz
                    end;
                    %ako se ne nalazi u najvisem subbandu, tj. ima djecu onda treba i njih provjeriti
                    if ~(i>subrN | j>subcN)
                        id=i*2-1;
                        jd=j*2-1; 
                        FIFO(fifosize+1:fifosize+4,1)=[id id id+1 id+1]'; % FIFO(:,1) sadrzi koordinate retka
                        FIFO(fifosize+1:fifosize+4,2)=[jd jd+1 jd jd+1]'; % FIFO(:,2) sadrzi koordinate stupca
                        fifosize=fifosize+4;
                    end; 
                else %inace, rijec je o T
                    if output
                        fprintf('t '); %kontrolni izlaz
                    end;
                end;    
            end; 
        end; 
        countbit=countbit+2;
        if countbit>=brojbit
            return
        end;
        fifocnt=fifocnt+1;
    end;
    FIFO=FIFObackup; %
    fifosize=size(FIFO,1);
    if output
        fprintf('\n'); %kontrolni izlaz
    end;
    % 2. subordinate prolaz
    refine=prag/4;
    for k=1:sgnfsize
        koef=SGNF(k,1);
        i=SGNF(k,2);
        j=SGNF(k,3);
        if koef>=prag/2  
            if output
                fprintf('1'); %kontrolni izlaz
            end;
            SGNF(k,1)=SGNF(k,1)-prag/2;   
            Drec(i,j)=sign(Drec(i,j))*(abs(Drec(i,j))+refine); %Instant rekonstrukcija
        else      
            if output
                fprintf('0'); %kontrolni izlaz
            end;
            Drec(i,j)=sign(Drec(i,j))*(abs(Drec(i,j))-refine); %Instant rekonstrukcija
        end;
        countbit=countbit+1;
        if countbit>=brojbit
            return
        end;
    end;
    if output
        fprintf('\n'); %kontrolni izlaz
    end;
    sgnfsizeold=sgnfsize;
    prolaz=prolaz+1;
    prag=prag/2;
end; %end of the main loop 

function s=search_children_ezw(i1,j1,subrN,subcN,D,prag)
%funkcija pretrazuje potomke koeficijenta c(i1,j1) i provjerava ima li ikoji veci od praga
s=0;
i2=i1+1;
j2=j1+1;
while i1<=subrN & j1<=subcN   
    Dm=abs(D(i1:i2,j1:j2));
    if max(Dm(:))>=prag
        s=1;
        return;
    end; 
    i1=i1*2-1;
    j1=j1*2-1;
    i2=i2*2;
    j2=j2*2;
end;
return;