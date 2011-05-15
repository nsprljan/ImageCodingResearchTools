function [OutputStreamPunct,OutputStream]=RCPC_encode(InputStream,Memory,t,P,PunctInd)

if length(InputStream)>1
    if Memory==0
     OutputStream=InputStream;
     OutputStreamPunct=-2*OutputStream+1;
     return;
    end; 
    InputStream=[InputStream zeros(1,Memory)]; % add zeros to terminate trellis 
    n=length(InputStream); %length of extended input bitstream    
    %Convolutional coding
    OutputStream=-2*convenc(InputStream,t,0)+1; % output bitstream without puncturing
    %Puncturing
    OutputStreamPunct=OutputStream(PunctInd); %add extra symbols and make signal bipolar (1->-1; 0->1)
end;