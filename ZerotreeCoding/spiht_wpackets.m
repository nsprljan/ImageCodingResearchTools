function [Arec,bitstream,PSNR,MSE,D,Drec,s,p_stream]=spiht_wpackets(A,bpp,wavelet,no_decomp,pkt_depth,dec_type,varargin)
%[Arec,bitstream,PSNR,MSE,D,Drec,s,p_stream]=spiht_wpackets(A,bpp,wavelet,no_decomp,pkt_depth,dec_type,varargin)
%Version: 3.13, Date: 2006/04/10, author: Nikola Sprljan
%SPIHT image compression using Wavelet Packets (WP) decomposition
%
%Input: 
% A - array containing the original image or its filename
% bpp - vector of target decoding bitrates (bpp=bits per pixel) 
% wavelet - wavelet identification string
% no_decomp - [optional, default = max] the number of levels of dyadic 
%             decomposition. Default value is the maximum possible, e.g.
%             down
%             to the LL subband of size 1x1 if the dimensions of an image are
%             powers of 2.
% pkt_depth - [optional, default = 0] maximum number of additional decomposition
%             levels for subbands; "packet decomposition depth"
% dec_type - type of the wavelet packets deconposition
%            if (dec_type == 'full') builds the full packets tree
%            if (dec_type == 'greedy') sub-optimal in terms of finding the 
%            minimal entropy, but faster
% varargin - parameters for entropy computation (see in decomp_packets.m)
%
%Output: 
% Arec - reconstructed image (if more than one decode bitrate is specified than
%        Arec contains the result of decoding at the highest bitrate)
% bitstream - output bitstream and side information; is of size (3,): 
%             (1,bitstream size) the bitstream 
%             (2,bitstream size) pass number of the SPIHT algorithm  
%             (3,bitstream size) bit class: 
%               {0 - header,1 - position bit,2 - sign bit,3 - refine bit}
% PSNR - PSNR of the reconstructed images (for all bpps)
% MSE - MSE of the reconstructed images
% D - wavelet coefficients after decomposition
% Drec - reconstructed wavelet coefficients 
% s - structure containing info on parent-children relationship between subbands
%     given by wavelet packets decomposition
% p_stream - stream of bits representing information on splitting decisions of
%            wavelet packets decomposition 
%
%Note: 
% spiht_wpackets.m calls the following external function (in this order):          
%   1. decomp_packets2D.m (wavelet packets decomposition),
%   2. pdf_opt.m (probability density function optimisation of the quantised 
%                 wavelet coefficient values; Laplace pdf),
%   3. recon_packets2D.m (wavelet packets reconstruction).    
% Output file SPIHTlog.txt contains statistics collected during the encoding 
% process.
%
%Uses: 
% pdf_opt.m 
% load_wavelet.m (Wavelet Toolbox)
% decomp_packets2D.m (Wavelet Toolbox)
% recon_packets2D.m (Wavelet Toolbox)
% iq_measures.m (Quality Assessment Toolbox)
%
%Example:
% [Arec,bitstream,PSNR]=spiht_wpackets('Lena512.png',1,'CDF_9x7',6); %as original binary-coded SPIHT
% [Arec,bitstream,PSNR]=spiht_wpackets(A,1,'haar');
% [Arec,bitstream,PSNR]=spiht_wpackets('Lena.bmp',[0.1 0.2 0.5 1],'CDF_9x7',5,4,'full','shannon');
% [Arec,bitstream,PSNR,MSE,D,Drec,s,p_stream]=spiht_wpackets('lena256.png',0.1,'CDF_9x7',5,4,'greedy','shannon',1.5);

if isstr(A)
    A=imread(A);
end;
if (ndims(A)>2) 
    error('Only indexed images are supported!');
end;
if (exist('decomp_packets2D.m') ~= 2)
    disp(sprintf('Warning: The function decomp_packets2D.m is not on the path, wavelet decomposition cannot be performed!'));
    disp(sprintf('Function decomp_packets2D.m is a part of Wavelet Toolbox'));
    return;
end;
if (exist('iq_measures.m') ~= 2)
    disp(sprintf('Warning: The function iq_measures.m is not on the path, the PSNR computation will not be performed!'));
    disp(sprintf('Function iq_measures.m is a part of Quality Assessment Toolbox'));
end;

if nargin<6
    dec_type='';
    if nargin<5
        pkt_depth=0;
        if nargin<4
            [Drows,Dcols]=size(A);
            rpow2=length(find(factor(Drows)==2));
            cpow2=length(find(factor(Dcols)==2));
            no_decomp=min(rpow2,cpow2);
            if 2^no_decomp==min(Drows,Dcols)
                no_decomp=no_decomp-1;   
            end;    
        end;
    end;
end;
fprintf('%d decompositions, %d packet depth, %s wavelet, highest bitrate %f bpp\n',...
    no_decomp,pkt_depth,wavelet,max(bpp));     

param = struct('N',no_decomp,'pdep',pkt_depth,'wvf',wavelet,'dec',dec_type);

ent_param = struct('ent',[],'opt',[]);
%loading wavelet
%load the wavelet here
if (isstr(wavelet))
    if (exist('load_wavelet.m') ~= 2)
        disp(sprintf('Warning: The function load_wavelet.m is not on the path, the specified wavelet cannot be loaded!'));
        disp(sprintf('Function load_wavelet.m is a part of Wavelet Toolbox'));
        return;
    end;
    param.wvf = load_wavelet(wavelet);
else
    param.wvf = wavelet;
end;

if nargin>6
    ent_param.ent=varargin{1};
    if nargin==8
        ent_param.opt=varargin{2};
    end;
else
    ent_param.ent='shannon';
end; 
param.meanvalue=round(mean(A(:)));
Am=double(A)-param.meanvalue;
%Am=A;param.meanvalue=0; %mean value shifting as in original SPIHT
tic;
[D,p_stream,s,E]=decomp_packets2D(Am,param,ent_param);
%global Dcmap; %enable this to load a decomposition matrix from the main environment
%D = Dcmap;

%mean value shifting as in original SPIHT /begin
%DLLr=size(A,1)/2^param.N;DLLc=size(A,2)/2^param.N;
%Dmean=mean(mean(D(1:DLLr,1:DLLc)));
%shift=0;
%while Dmean>1024 Dmean=Dmean/4;shift=shift+1;end;
%param.Dmean=ceil(Dmean);param.shift=shift;
%D(1:DLLr,1:DLLc)=D(1:DLLr,1:DLLc)-param.Dmean*4^param.shift;
%mean value shifting as in original SPIHT /end

fprintf('Image transformed in %.2f seconds\n',toc);
tic;
%fprintf('Entropy-  %f\n',E);
[M,s]=maximum_magnitudes(D,s);
fprintf('Maximum magnitudes computed in %.2f seconds\n',toc);
numbits=round(prod(size(A)).*bpp);
%SPIHT algorithm, coding&decoding at once (without output to a file!)
if pkt_depth>0
    %4 bits for depth of packet decomposition, 16 for the length of p_stream; not implemented
    header_size=51+4+16+length(p_stream);  
else
    header_size=51; %51 bits as in original SPIHT
end;
header=zeros(1,header_size);
header(1:8)=str2num(dec2bin(param.meanvalue,8)')';
header(9:22)=str2num(dec2bin(size(A,1),14)')';
header(23:36)=str2num(dec2bin(size(A,1),14)')';
header(37:41)=str2num(dec2bin(floor(log2(max(max(M(:,:,1))))),5)')';
header(42:45)=str2num(dec2bin(no_decomp,4)')';
if pkt_depth>0
    header(46)=1; %next five bits for the type of wavelet
    header(72:header_size)=p_stream;   
end;
fprintf('\nSPIHT algorithm...\n');
tic;
[Drec,Arec,bitstream,PSNR,MSE]=spihtalg(A,D,s,M,numbits,header_size,param,p_stream);%

bitstream(1,1:header_size)=header;
fprintf(' - completed in %.2f seconds\n',toc); 

function [Drec,Arec,bitstream,PSNR,MSE]=spihtalg(A,D,s,M,numbits,header_size,param,p_stream)
%Input: 
% A - array containing the original image or its filename
% D - wavelet coefficients of the original image
% s - structure containing info on parent-children relationship between
%     subbands (see in decomp_packets2D.m and in the function
%     maximum_magnitudes defined below) 
% M - sorted coefficients trees (see in maximum_magnitudes below)
% numbits - vector containing bit budgets for each of the specified bits
%           per pixel values
% header_size - header size in bits to be taken into account
% param - structure specifying the decomposition parametres (see
%         decomp_packets2D.m)
% p_stream - information necessary for reconstruction of wavelet packets
%            subbands (see decomp_packets2D.m)

N=param.N;
[Drows,Dcols]=size(D);
%fileout=fopen('fileout.bin','w');%f
maxcoeff=max(max(abs(D))); %maximum absolute coefficient 
if maxcoeff>0 
    nbit=floor(log2(maxcoeff)); %bits for first threshold
else %in case that image contains only DC component (which is previously substracted) 
    quantstep=0;
    return %the whole coding process is skipped
end;
%Energy=sum(sum(D.^2));
%RecEnergy=0;
%initialize all lists & variables
[LIP,endLIP,LIS,endLIS,LSP,endLSP]=initialize_lists(D,N);
LISnew=zeros(size(LIS));
LIStemp=zeros(64,3);
oldendLSP=0;
duzina=numel(D);
sizrow=Drows/2^N;
sizcol=Dcols/2^N;
Dqrows=Drows/4;
Dqcols=Dcols/4;
MagnL=M(:,:,1);
MagnD=M(:,:,2);
L_S=M(:,:,3); %matrix that links coefficient and the index of its subband
Drec=zeros(Drows,Dcols); %initialize matrix of reconstructed coefficients
bitstream=zeros(3,numbits(end),'uint8');
quantstep=2^nbit; %first threshold (threshold is equal to quantization step)
Dtype=1; %indicates D type of LIS element
pass=1; %first coding pass
%**STATS**
nowcd=fileparts(which('spiht_wpackets'));
namelog=fullfile(nowcd,'SPIHTlog.txt');
fid=fopen(namelog,'w');
count1=header_size; %bits reserved for header
[stats,fid]=show_stats(fid,'init',pass,count1);
cntbitout=1;
while numbits(cntbitout)<=header_size
    [MSE(cntbitout),PSNR(cntbitout)]=iq_measures(A,127*ones(size(A)));
    cntbitout=cntbitout+1;
end;
%2.SORTING PASS 
while 1
    %fprintf(fid,'Threshold = %.2f\n   ',quantstep);  %**STATS**
    fprintf(fid,'%2d.(%8d)   ',pass,count1+1);  %**STATS**
    %fprintf(fid,'%2d LIP\n',pass); %NS!
    %2.1. testing the significance of elements in LIP
    lipcnt=0;
    cntbit=count1;
    init=quantstep*3/2; 
    %RecEadd=init^2;
    for mlip=1:endLIP %LIP loop
        i=LIP(mlip,1);
        j=LIP(mlip,2);
        count1=count1+1;
        bitstream(1,count1)=(abs(D(i,j))>=quantstep);
        bitstream(2,count1)=pass;
        bitstream(3,count1)=1; %position bit
        if bitstream(1,count1) %significant goes to LSP
            %fprintf(fid,'%5.2f\n',D(i,j));  %**STATS**
            count1=count1+1;
            bitstream(1,count1)=(sign(D(i,j))==1);
            bitstream(2,count1)=pass;
            bitstream(3,count1)=2; %sign bit
            Drec(i,j)=sign(double(bitstream(1,count1))-0.5)*init;
            %RecEnergy=RecEnergy+RecEadd;
            endLSP=endLSP+1;
            LSP(endLSP,:)=[i j];
            %fwrite(fileout,1,'ubit1');%f
            %fwrite(fileout,sign(D(i,j)),'ubit1');%f
        else %otherwise stays in LIP
            lipcnt=lipcnt+1;
            LIP(lipcnt,:)=LIP(mlip,:);
            %fwrite(fileout,0,'ubit1');%f
        end;
        if count1+1>=numbits(cntbitout) %this limit is equivalent in terms of distortion (1 addidional bit wouldn't help)
            [Arec,PSNR(cntbitout),MSE(cntbitout)]=reconstruct(A,Drec,cntbitout,count1,quantstep,pass,param,p_stream);
            cntbitout=cntbitout+1;
        end;
        if cntbitout>length(numbits) %| abs(RecEnergy-Energy)/Energy<10^-7
            [stats,fid]=show_stats(fid,'LIP',pass,count1,stats,endLSP); %**STATS**
            [stats,fid]=show_stats(fid,'LIS',pass,count1,stats,endLSP);
            [stats,fid]=show_stats(fid,'LSP',pass,stats(pass,1).LSP-1,stats,endLSP);
            [stats,fid]=show_stats(fid,'total',pass,count1,stats,endLSP);
            fprintf('\n...LIP loop out');
            %fclose(fileout);
            return
        end;    
    end; %end of LIP loop
    endLIP=lipcnt;
    [stats,fid]=show_stats(fid,'LIP',pass,count1,stats,endLSP); %**STATS**
    %fprintf(fid,'%2d LIS\n',pass); %NS!
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
        subband_index=L_S(i,j);
        row=s(subband_index).band_abs(2);
        col=s(subband_index).band_abs(1);
        scalediff=s(subband_index).scalediff;
        rowrel=i-row;
        colrel=j-col;
        id=row+s(subband_index).addrows+(rowrel-1)*2.^scalediff+1;
        jd=col+s(subband_index).addcols+(colrel-1)*2.^scalediff+1;
        %2.2.1. for L type elements
        if ~LISel(3)
            polje=MagnL(id+(jd-1)*Drows); %children
            count1=count1+1;
            bitstream(1,count1)=any(polje>=quantstep);
            bitstream(2,count1)=pass;
            bitstream(3,count1)=1; %position bit
            %fwrite(fileout,sn,'ubit1');%f
            if bitstream(1,count1) %tree is significant 
                polje=D(id+(jd-1)*Drows);
                checkbit=0; %indicates if significant coefficients is found between children
                for k=1:length(polje); 
                    count1=count1+1;
                    bitstream(1,count1)=(abs(polje(k))>=quantstep);
                    bitstream(2,count1)=pass;
                    bitstream(3,count1)=1; %position bit
                    if bitstream(1,count1)
                        %fwrite(fileout,1,'ubit1');%f
                        %fwrite(fileout,sign(polje(k)),'ubit1');%f
                        if ~checkbit checkbit=1;end;
                        count1=count1+1;
                        bitstream(1,count1)=(sign(polje(k))==1);
                        bitstream(2,count1)=pass;
                        bitstream(3,count1)=2; %sign bit
                        Drec(id(k),jd(k))=sign(double(bitstream(1,count1))-0.5)*init;
                        %RecEnergy=RecEnergy+RecEadd;
                        endLSP=endLSP+1;
                        LSP(endLSP,:)=[id(k) jd(k)];
                        %fprintf(fid,'%5.2f\n',D(id(k),jd(k)));  %**STATS**
                    else
                        %fwrite(fileout,0,'ubit1');%f
                        endLIP=endLIP+1;
                        LIP(endLIP,:)=[id(k) jd(k)];
                    end;
                    if count1+1>=numbits(cntbitout) %this limit is equivalent in terms of distortion (1 addidional bit wouldn't help)
                        [Arec,PSNR(cntbitout),MSE(cntbitout)]=reconstruct(A,Drec,cntbitout,count1,quantstep,pass,param,p_stream);
                        cntbitout=cntbitout+1;
                    end;
                    if cntbitout>length(numbits) %| abs(RecEnergy-Energy)/Energy<10^-7
                        [stats,fid]=show_stats(fid,'LIS',pass,count1,stats,endLSP); %**STATS**
                        [stats,fid]=show_stats(fid,'LSP',pass,stats(pass,1).LSP-1,stats,endLSP);
                        [stats,fid]=show_stats(fid,'total',pass,count1,stats,endLSP);
                        fprintf('\n...LIS (checking children) loop out');
                        %fclose(fileout);
                        return;
                    end;
                end; 
                if (i<=Dqrows) & (j<=Dqcols)  %if L(i,j) (grandchildren) exist, (i,j) goes at the end of LIS as type D
                    if checkbit
                        endLIS=endLIS+1;
                        LIS(endLIS,:)=[i j Dtype];
                    else %if no child is found significant then some of descendents must be significant
                        tn=length(polje);
                        LIS(endLIS+1:endLIS+tn,1:3)=[id',jd',zeros(tn,1)];
                        endLIS=endLIS+tn;
                    end;  
                end;    
            else  %back to the LIS goes insignificant element  
                liscnt=liscnt+1;
                LISnew(liscnt,:)=LISel; 
            end;
        else %2.2.2. for D type elements
            polje=MagnD(id+(jd-1)*Drows); %children
            count1=count1+1; 
            bitstream(1,count1)=any(polje>=quantstep);
            bitstream(2,count1)=pass;
            bitstream(3,count1)=1; %position bit
            %fwrite(fileout,bitstream(1,count1),'ubit1');%f
            if bitstream(1,count1) %if D(id,jd) is significant then elements O(id,jd) go to LIS as type L    
                endLIStemp=length(polje);
                LIStemp(1:endLIStemp,1:3)=[id',jd',zeros(endLIStemp,1)];
            else %if it's not it stays in LIS  
                liscnt=liscnt+1;
                LISnew(liscnt,:)=LISel; 
            end;  
        end; 
        if count1+1>=numbits(cntbitout) %this limit is equivalent in terms of distortion (1 addidional bit wouldn't help)
            [Arec,PSNR(cntbitout),MSE(cntbitout)]=reconstruct(A,Drec,cntbitout,count1,quantstep,pass,param,p_stream);
            cntbitout=cntbitout+1;
        end;
        if cntbitout>length(numbits) %| abs(RecEnergy-Energy)/Energy<10^-7
            [stats,fid]=show_stats(fid,'LIS',pass,count1,stats,endLSP); %**STATS**
            [stats,fid]=show_stats(fid,'LSP',pass,stats(pass,1).LSP-1,stats,endLSP);
            [stats,fid]=show_stats(fid,'total',pass,count1,stats,endLSP);
            fprintf('\n...LIS loop out');
            %fclose(fileout);
            return;
        end;
    end; %end of LIS loop
    endLIS=liscnt; 
    LIS(1:endLIS,:)=LISnew(1:endLIS,:);
    [stats,fid]=show_stats(fid,'LIS',pass,count1,stats,endLSP); %**STATS**
    %3. REFINEMENT PASS
    if pass>1
        refine=quantstep/2;
        for mls=1:oldendLSP
            i=LSP(mls,1);
            j=LSP(mls,2);
            %RecEnergy=RecEnergy-Drec(i,j).^2;
            count1=count1+1; 
            bitstream(1,count1)=(D(i,j)>Drec(i,j));
            bitstream(2,count1)=pass;
            bitstream(3,count1)=3; %refine bit
            if bitstream(1,count1)  
                Drec(i,j)=Drec(i,j)+refine; 
            else
                Drec(i,j)=Drec(i,j)-refine; 
            end; 
            %RecEnergy=RecEnergy+Drec(i,j).^2;
            if count1>=numbits(cntbitout) 
                [Arec,PSNR(cntbitout),MSE(cntbitout)]=reconstruct(A,Drec,cntbitout,count1,quantstep,pass,param,p_stream);
                cntbitout=cntbitout+1;
            end;
            if cntbitout>length(numbits) %| abs(RecEnergy-Energy)/Energy<10^-7
                [stats,fid]=show_stats(fid,'LSP',pass,count1,stats,endLSP); %**STATS**
                [stats,fid]=show_stats(fid,'total',pass,count1,stats,endLSP);
                fprintf('Refinement pass out...\n');
                return;
            end;
        end;
    end;
    
    [stats,fid]=show_stats(fid,'LSP',pass,count1,stats,endLSP); %**STATS**
    %4. UPDATE
    oldendLSP=endLSP;
    quantstep=quantstep/2;
    pass=pass+1;
end; %end of the main loop
fprintf('Smallest quantization step reached!!\n');

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

function [stats,fid]=show_stats(fid,looptype,pass,count1,stats,endLSP)
stats_index=pass+1;
addstr=' ';
switch looptype
    case 'LIP'    
        stats(stats_index,1).LIP=endLSP-stats(pass,1).LSP;
        stats(stats_index,2).LIP=count1-stats(pass,2).LSP;
        if stats(stats_index,1).LIP
            bpc=stats(stats_index,2).LIP/stats(stats_index,1).LIP;
            if bpc>9 addstr='';end;
        else 
            bpc=Inf;
            addstr='  ';
        end; 
        fprintf(fid,'%6d/%-6d=%s%2.2f bpc',stats(stats_index,2).LIP,stats(stats_index,1).LIP,addstr,bpc);
    case 'LIS'
        stats(stats_index,1).LIS=endLSP-stats(stats_index,1).LIP-stats(pass,1).LSP;
        stats(stats_index,2).LIS=count1-stats(stats_index,2).LIP-stats(pass,2).LSP;
        if stats(stats_index,1).LIS
            bpc=stats(stats_index,2).LIS/stats(stats_index,1).LIS;
            if bpc>9 addstr='';end;
        else
            bpc=Inf;

            addstr='  ';
        end;
        fprintf(fid,'%7d/%-6d=%s%2.2f bpc',stats(stats_index,2).LIS,stats(stats_index,1).LIS,addstr,bpc);
    case 'LSP'
        stats(stats_index,1).LSP=endLSP;
        stats(stats_index,2).LSP=count1;
%       pass_bits=stats(stats_index,2).LSP-stats(pass,2).LSP;
        fprintf(fid,'%12d(%8d)\n',endLSP,count1- stats(pass,1).LSP+1);
    case 'init'
        stats(1,1).LIP=0;      %elements added to LSP list
        stats(1,2).LIP=0;      %bits used
        stats(1,1).LIS=0;
        stats(1,2).LIS=0;
        stats(1,1).LSP=0;      %elements added to LSP list 
        stats(1,2).LSP=count1; %bits used
        %fprintf(fid,'*bpc=bits per significant coefficient\n');
        fprintf(fid,'                   LIP loop                LIS loop              Total significant\n');
        fprintf(fid,'pass(start bit)   bits/coeffs.            bits/coeffs.              coeffs.(LSP start bit)\n');
    case 'total'
        fprintf(fid,'Total:\n');
        totLIPbits=0;
        totLIPcoeffs=0;
        totLISbits=0;
        totLIScoeffs=0;
        for i=1:stats_index
            totLIPbits=totLIPbits+stats(i,2).LIP;
            totLIPcoeffs=totLIPcoeffs+stats(i,1).LIP;
            totLISbits=totLISbits+stats(i,2).LIS;
            totLIScoeffs=totLIScoeffs+stats(i,1).LIS;
        end; 
        if totLIPcoeffs
            bpc=totLIPbits/totLIPcoeffs;
            if bpc>9 addstr='';end;
        else
            bpc=Inf;
            addstr='  ';
        end;
        fprintf(fid,'                %6d/%-6d=%s%2.2f bpc',totLISbits,totLIScoeffs,addstr,bpc);    
        if totLIScoeffs
            bpc=totLISbits/totLIScoeffs;
            if bpc>9 addstr='';end;
        else
            bpc=Inf;
            addstr='  ';
        end;
        fprintf(fid,'%7d/%-6d=%s%2.2f bpc',totLIPbits,totLIScoeffs,addstr,bpc);
        fprintf(fid,'%12d\n',endLSP);
        fclose(fid);
end;


function [Arec,PSNR,MSE]=reconstruct(A,Drec,i,counts,quantsteps,passes,param,p_stream)
Asiz=prod(size(Drec));
fprintf('\n%d. bitrate - %f bpp\n',i,counts/Asiz);
% optimization in regard to probability density function (pdf) of coefficients 
Drec=pdf_opt(Drec,quantsteps); %
%mean value shifting as in original SPIHT /begin
%DLLr=size(A,1)/2^param.N;DLLc=size(A,2)/2^param.N;
%Drec(1:DLLr,1:DLLc)=Drec(1:DLLr,1:DLLc)+param.Dmean*4^param.shift;
%mean value shifting as in original SPIHT /end
%perform reconstruction
Arec=recon_packets2D(Drec,param,p_stream);
Arec=Arec+param.meanvalue;
Arec(Arec>255)=255;
Arec(Arec<0)=0;
Arec=uint8(round(Arec));
%imwrite(Arec,['RecImage_' num2str(i) '.bmp']);
%display some statistics
filebits=8*ceil(counts/8);
fprintf('No. output bits - %d(%d bytes; %d excess bits)-> %f bpp\n',...
    filebits,filebits/8,filebits-counts,filebits/Asiz);
%compute PSNR
[MSE,PSNR]=iq_measures(A,Arec,'disp');

function [M,s]=maximum_magnitudes(D,s)
%Input:
% D - wavelet coefficients of the original image
% s - structure containing info on parent-children relationship between
% subbands (see in decomp_packets2D.m)
%
%Output:
% M - contains maximal values within the set composed of a coefficient 
%     and all of its descendants. M(:,:,2) contains subband index.
% s - modified input structure s. The following fields are added: addrows, 
%     addcols and scalediff.
%
%Note:
% This function sorts coefficients trees by amplitudes. Modifies the
% structure by adding additional info used by the SPIHT algorithm.

[Drows,Dcols]=size(D);
M=zeros(Drows,Dcols,3);
M(:,:,1:2)=repmat(abs(D),[1 1 2]);
M(1:s(1).band_abs(4),1:s(1).band_abs(3),3)=1; %the lowest subband coefficients are in subband no.1 (in 's') 
s(1).addrows=[]; %add field addrows
s(1).addcols=[]; %add field addcols
s(1).scalediff=[]; %add field scalediff
[M,s]=sort_subbands(1,s,M);

function [M,s]=sort_subbands(index,s,M)
node=s(index);
col=node.band_abs(1);
row=node.band_abs(2);
cw=node.band_abs(3);
rw=node.band_abs(4);
magn_band=zeros(rw,cw);%
children=node.children;
for i=1:size(children,2)
    child=s(children(i));
    col_c=child.band_abs(1);
    row_c=child.band_abs(2);
    cw_c=child.band_abs(3);
    rw_c=child.band_abs(4);
    M(row_c+1:row_c+rw_c,col_c+1:col_c+cw_c,3)=children(i); %index of the subband
    if child.children(1)>0
        [M,s]=sort_subbands(children(i),s,M);   
    end;    
    scalediff=child.scale-node.scale;
    chdim=2^scalediff;
    mr=repmat(1:chdim,[chdim 1]);
    mc=mr';
    diffrow=row_c-row;
    diffcol=col_c-col;
    s(index).addrows=[s(index).addrows (mr(:)+diffrow-1)'];
    s(index).addcols=[s(index).addcols (mc(:)+diffcol-1)'];
    s(index).scalediff=[s(index).scalediff scalediff*ones(1,numel(mr))];
    subbandM=reshape(M(row_c+1:row_c+rw_c,col_c+1:col_c+cw_c,1),[chdim rw_c/chdim chdim cw_c/chdim]);
    subbandM=permute(subbandM,[2 4 3 1]);
    subbandM=reshape(subbandM,[rw_c/chdim cw_c/chdim chdim^2]);
    subbandM=max(subbandM,[],3);
    magn_band=max(magn_band,subbandM);
end;   
M(row+1:row+rw,col+1:col+cw,2)=magn_band;
M(row+1:row+rw,col+1:col+cw,1)=max(M(row+1:row+rw,col+1:col+cw,1:2),[],3); %sort magnitudes for L