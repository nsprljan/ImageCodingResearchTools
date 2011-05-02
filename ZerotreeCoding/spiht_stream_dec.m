function [Arec,Drec]=spiht_stream_dec(bitstream);
% [Arec,Drec] = spiht_stream_dec(bitstream);
% Version: 1.02, Date: 2006/03/25, author: Nikola Sprljan
% Performs decoding of the bitstream produced by spiht_wpackets.m
% 
%Input: 
% bitstream - SPIHT compressed bitstream
%
%Output:
% Arec - reconstructed image
% Drec - reconstructed wavelet coefficients
%
%Note:
% Serves a purpose of determining whether the bit-stream produced by the
% function spiht_wpackets.m is decodable.
% Only CDF_9x7 wavelet supported, and no wavelet packets.
%
%Example:
% [Arec,bitstream]=spiht_wpackets('Lena512.png',1,'CDF_9x7',6);
% [Arec,Drec]=spiht_stream_dec(bitstream(1,:));

header_size=51; %wavelet packets not implemented
wavelet='CDF_9x7'; %ideally, should be determined from the five bits from the header
%wavelet='haar';
brojbit=length(bitstream);
meanvalue=bin2dec(num2str(bitstream(1:8)')');
sizA1=bin2dec(num2str(bitstream(9:22)')');
sizA2=bin2dec(num2str(bitstream(23:36)')');
nbit=bin2dec(num2str(bitstream(37:41)')');
no_decomp=bin2dec(num2str(bitstream(42:45)')');
if brojbit==header_size %only header is transmitted
    Arec=repmat(meanvalue,[sizA1 sizA2]);
    Drec=zeros(sizA1,sizA2);
    return;
end;
%RecEnergy=zeros(1,length(bitstream));
Eind=header_size;
count1=header_size; %bits reserved for header
Drows=sizA1;
Dcols=sizA2;
Drec=zeros(Drows,Dcols); %initialize matrix of reconstructed coefficients
%initialize all lists & variables
[LIP,endLIP,LIS,endLIS,LSP,endLSP]=initialize_lists(Drec,no_decomp);
LISnew=zeros(size(LIS));
LIStemp=zeros(64,3);
oldendLSP=0;
sizrow=Drows/2^no_decomp;
sizcol=Dcols/2^no_decomp;
Dqrows=Drows/4;
Dqcols=Dcols/4;
Drec=zeros(Drows,Dcols); %initialize matrix of reconstructed coefficients
quantstep=2^nbit; %first threshold (threshold is equal to quantization step)
Dtype=1; %indicates D type of LIS element
pass=1; %first coding pass
%2.SORTING PASS 
while 1
    %2.1. testing the significance of elements in LIP
    lipcnt=0;
    init=quantstep*3/2; 
    RecEadd=init^2;
    for mlip=1:endLIP %LIP loop
        i=LIP(mlip,1);
        j=LIP(mlip,2);
        count1=count1+1;
        if bitstream(count1) %significant goes to LSP
            count1=count1+1;
            if count1>=brojbit
               Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
               %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
               return;    
            end;
            Drec(i,j)=sign(bitstream(count1)-0.5)*init;
            %RecEnergy(Eind+1:count1)=RecEnergy(Eind)+RecEadd;
            Eind=count1;
            endLSP=endLSP+1;
            LSP(endLSP,:)=[i j];
        else %otherwise stays in LIP
            lipcnt=lipcnt+1;
            LIP(lipcnt,:)=LIP(mlip,:);
        end;
        if count1>=brojbit %it can happen that 2 bits are added inside LIP loop
            Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
            %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
            return;    
        end;
    end; %end of LIP loop
    endLIP=lipcnt;
    %2.2. testing the significance of elements in LIS 
    mlis=0;
    mlistemp=0;
    endLIStemp=0;
    liscnt=0; 
    while mlis<endLIS
        if endLIStemp
            mlistemp=mlistemp+1;
            LISel=LIStemp(mlistemp,:);
            if mlistemp==endLIStemp
                mlistemp=0;
                endLIStemp=0;   
            end;    
        else
            mlis=mlis+1;
            LISel=LIS(mlis,:);
        end;
        i=LISel(1);
        j=LISel(2);
        if i<=sizrow & j<=sizcol
            id=[i i+sizrow i+sizrow];
            jd=[j+sizcol j j+sizcol];
            length_child=3;
        else
            id=[2*i-1 2*i-1 2*i 2*i]; 
            jd=[2*j-1 2*j 2*j-1 2*j];
            length_child=4;
        end; 
        %2.2.1. for L type elements
        if ~LISel(3)
            count1=count1+1;   
            if count1>=brojbit
                Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
                %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
                return;    
            end;
            if bitstream(count1) %tree is significant 
                checkbit=0; %indicates if significant coefficients is found between children
                for k=1:length_child; 
                    count1=count1+1;
                    if count1>=brojbit
                        Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
                        %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
                        return;    
                    end;
                    if bitstream(count1)
                        if ~checkbit checkbit=1;end;
                        count1=count1+1;
                        Drec(id(k),jd(k))=sign(bitstream(count1)-0.5)*init;
                        %RecEnergy(Eind+1:count1)=RecEnergy(Eind)+RecEadd;
                        Eind=count1;
                        endLSP=endLSP+1;
                        LSP(endLSP,:)=[id(k) jd(k)];
                        if count1>=brojbit
                            Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
                            %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
                            return;    
                        end;
                    else
                        endLIP=endLIP+1;
                        LIP(endLIP,:)=[id(k) jd(k)];
                    end;
                end; 
                if (i<=Dqrows) & (j<=Dqcols)  %if L(i,j) (grandchildren) exist, (i,j) goes at the end of LIS as type D
                    if checkbit
                        endLIS=endLIS+1;
                        LIS(endLIS,:)=[i j Dtype];
                    else %if no child is found significant then some of descendents must be significant
                        LIS(endLIS+1:endLIS+length_child,1:3)=[id',jd',zeros(length_child,1)];
                        endLIS=endLIS+length_child;
                    end;  
                end;    
            else  %back to the LIS goes insignificant element  
                liscnt=liscnt+1;
                LISnew(liscnt,:)=LISel; 
            end;
            %2.2.2. for D type elements 
        else
            count1=count1+1; 
            if bitstream(count1) %if D(id,jd) is significant then elements O(id,jd) go to LIS as type L 
                endLIStemp=length_child;;
                LIStemp(1:endLIStemp,1:3)=[id',jd',zeros(endLIStemp,1)];
            else %if it's not it stays in LIS  
                liscnt=liscnt+1;
                LISnew(liscnt,:)=LISel; 
            end;  
        end; 
        if count1>=brojbit
            Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
            %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
            return;
        end;
    end; %end of LIS loop
    endLIS=liscnt; 
    LIS(1:endLIS,:)=LISnew(1:endLIS,:);
    %3. REFINEMENT PASS
    if pass>1
        refine=quantstep/2;
        for mls=1:oldendLSP
            i=LSP(mls,1);
            j=LSP(mls,2);
            Drec_old=Drec(i,j);
            count1=count1+1;
            if bitstream(count1)  
                Drec(i,j)=Drec(i,j)+refine; 
            else
                Drec(i,j)=Drec(i,j)-refine; 
            end; 
            %RecEnergy(Eind+1:count1)=RecEnergy(Eind)-Drec_old^2+Drec(i,j)^2;
            Eind=count1;
            if count1>=brojbit
                Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep);
                %RecEnergy(Eind+1:count1)=RecEnergy(Eind);
                return;    
            end;
        end;
    end;
    %4. UPDATE
    oldendLSP=endLSP;
    quantstep=quantstep/2;
    pass=pass+1;
end; %end of the main loop

function Arec=reconstruct(Drec,no_decomp,wavelet,meanvalue,quantstep)
Drec_opt=pdf_opt(Drec,quantstep);
Arec=idwt_dyadic_recon(Drec_opt,wavelet,no_decomp);
Arec=uint8(round(Arec+meanvalue));

function [LIP,endLIP,LIS,endLIS,LSP,endLSP]=initialize_lists(D,N)
[Drows,Dcols]=size(D);
sizrow=Drows/2^N;
sizcol=Dcols/2^N;
duzina=numel(D);
LIP=zeros(duzina,2);
LIS=zeros(duzina,3);
LSP=zeros(duzina,2); 
Dp=D(1:sizrow,1:sizcol).'; %lowest subband
endLIP=sizrow*sizcol; %LIP contains all lowest subband coefficients
%for EZW type trees, LIS will contain all LIP coefficients, raster scan
ii=repmat(1:sizrow,sizcol,1);
jj=repmat(1:sizcol,[1 sizrow],1);
LIP(1:endLIP,1)=ii(:);
LIP(1:endLIP,2)=jj.';
endLIS=endLIP;
LIS(1:endLIS,1:2)=LIP(1:endLIP,1:2);
endLSP=0; %LSP is initialized empty