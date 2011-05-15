function [OutputStream,parametar]=BSC_BER(InputStream,parametar)
%[OutputStream,parametar]=BSC_BER(InputStream,parametar)
%Simulation of the Binary Symemtric Channel (BSC)
%
%Input: 
% InputStream - input stream of bits (1 and -1)
% parametar - bit error rate (ber) of the channel or a complete definition 
%            of the channel, see in get_channel.m
%
%Output:
% OutputStream - output stream of bits, after transmission through the 
%                channel 
% parametar - the same as the input variable, here due to API compatibility
% with other channels
%
%Uses:
% randsrc (MATLAB Communication Toolbox)
%
%Example:
% out=BSC_BER(randsrc(1,1024,[-1 1]),0.5);

if isstruct(parametar)
    BER=parametar.BER;
else
    BER=parametar;
end;
InputStream=InputStream<0; %converting from bipolar
error_pattern=randsrc(1,length(InputStream),[0 1;BER 1-BER]);
OutputStream=~xor(InputStream,error_pattern);
OutputStream=-2*OutputStream+1; %back to bipolar