function OutputStream=RCPC_decode(InputStream,Memory,t,PunctInd,DepunctLen,PacketData)

if Memory==0
    OutputStream=InputStream<0; %from bipolar to {0,1}
    return;
end;
InPunctStream=zeros(1,DepunctLen);
retrans=ceil(length(PunctInd)/DepunctLen);
if retrans>1
    repetition=zeros(1,DepunctLen);
    for i=1:retrans
        if i==retrans
            add_indices=(i-1)*DepunctLen+1:length(PunctInd);
        else
            add_indices=(i-1)*DepunctLen+1:i*DepunctLen;
        end;  
        addSymbols=PunctInd(add_indices);
        repetition(addSymbols)=repetition(addSymbols)+1;
        InPunctStream(addSymbols)=InPunctStream(addSymbols)+InputStream(add_indices); 
    end;
    InPunctStream=InPunctStream./repetition;
else
    InPunctStream(PunctInd)=InputStream;
end;
% Rounding for BSC channel through unquant decision 
% InPunctStream(InPunctStream>0)=1;
% InPunctStream(InPunctStream<0)=-1;
% OutputStream=vitdec(InPunctStream,t,nOut,'term','unquant');
%Quantization for the soft decision
nsdec=8; %8
steppart=2^(1-nsdec);
range=2^nsdec-1;
InPunctStreamQ=range-floor((InPunctStream+1)./steppart);
InPunctStreamQ(InPunctStreamQ<0)=0;
InPunctStreamQ(InPunctStreamQ>range)=range;
try
OutputStream=vitdec(InPunctStreamQ,t,PacketData+Memory,'term','soft',nsdec); %soft decision
catch
    pause;
end;
OutputStream=OutputStream(1:PacketData);