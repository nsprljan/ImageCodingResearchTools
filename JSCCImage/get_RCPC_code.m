function [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(PunctRate)
%[Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code(PunctRate)
%Version: 1.00, Date: 2003, author: Nikola Sprljan
%Loads a predefined RCPC code from a default code family ('Punct_codes.txt') 
%
%Input:
% PunctRate - string specifyng the code rate, e.g. '1/2' or '13'
%
%Output:
% Memory - length of the shifting registers
% Ib - numerator of the code rate
% Kb - denominator of the code rate 
% t - trellis to be used
% PN - puncturing period of the output stream
% P - puncturing period of the input stream 
% TotRate - code rate
% PunctInd - indices of the output symbols NOT to be removed in one
%            puncturing period
%Example:
% [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd]=get_RCPC_code('1/3');

%[s,f,tokens] = regexp(PunctRate,'(\w*)/(\w*)');
%Ib=str2num(PunctRate(tokens{1}(1,1):tokens{1}(1,2)));
%Kb=str2num(PunctRate(tokens{1}(2,1):tokens{1}(2,2)));
slashind=findstr(PunctRate,'/');
Ib=str2num(PunctRate(1:slashind-1));
Kb=str2num(PunctRate(slashind+1:end));

fid=fopen('Punct_codes.txt','r');
flag=0;
%expression=['^\<' PunctRate];
while 1
    tline = fgetl(fid);
    if ~ischar(tline) break; end;
    switch flag
        case 0
            if findstr(tline,PunctRate) %regexp(tline,expression)
                flag=1;    
            end;
        case 1
            flag=2;
        case 2
            Memory=str2num(tline(8:end));
            flag=3;
        case 3
            CodeGenerator=str2num(tline(15:end));
            flag=4;
        case 4
            PunctCode=tline(11:end);
            flag=5;
        case 5
            cd=str2num(tline(4:end));
            break;
    end;
end;
fclose(fid);

N=length(CodeGenerator); %N of 1/N "mother" code
PunctBin=dec2bin(hex2dec(PunctCode));
P=length(PunctBin)/N; %InputStream period of puncturing
PN=P*N; %OutputStream period of puncturing
PunctSiz=sum(PunctBin=='1'); %number of bits in one period that gets transmitted after puncturing
TotRate=Ib/Kb;
t=poly2trellis(Memory+1,CodeGenerator); %create trellis structure
PunctCodeRs=reshape(reshape(str2num(PunctBin')',[P N])',[1 PN]);
PunctInd=find(PunctCodeRs);
% RCPC_err_fhandle=@RCPC_err;
% 
% function Pb=RCPC_err(cd,P,EsN0)
% EsN0=10^(EsN0/10);
% Pb=0;
% d=1:length(cd);
% Pb=sum(cd(d).*0.5.*erfc(sqrt(d.*EsN0)))/P;