function [OutputStream,parametar]=GE_awgn(InputStream,parametar)
%[OutputStream,parametar]=GE_awgn(InputStream,parametar)
%Version: 1.00, Date: 2003, author: Nikola Sprljan
%Simulation of the Gilbert-Elliot (GE) channel, using two AWGN channels
%
%Input: 
% InputStream - input stream of symbols (1 and -1)
% parametar - a complete definition of the channel, see in get_channel.m
%
%Output:
% OutputStream - output stream of symbols with added noise
% parametar - a complete definition of the channel, with the current state
%             of the channel 
%
%Note:
% BPSK modulation is assumed, the power of the signal can be set with the 
% variable 'SignalPower'.
%
%Example:
% [ch_handle,parametar]=get_channel('GE1');
% [OutputStream,parametar]=GE_awgn(randsrc(1,1024,[-1 1]),parametar)

%CONSTANTS
SignalPower=1; %power of the input signal in Watts
%
n=length(InputStream);
SNR=zeros(1,n);
if parametar.state==-1
    r=rand;
    parametar.state=r>(parametar.PGB/parametar.PBG);
    %parametar.numbad=r;
end; 
% SNRg=2*(erfcinv(2*parametar.BERg)^2 * 10^(parametar.gain/10));
% SNRb=2*(erfcinv(2*parametar.BERb)^2 * 10^(parametar.gain/10));   
SNRg=2*10^((20*log10(erfcinv(2*parametar.BERg)) + parametar.gain)/10);
SNRb=2*10^((20*log10(erfcinv(2*parametar.BERb)) + parametar.gain)/10);
for i=1:n
    r=rand;
    if parametar.state==0
        if r<parametar.PBG
            parametar.state=1;
            SNR(i)=SNRg;
        else
            SNR(i)=SNRb;
        end;
    else
        if r<parametar.PGB
            parametar.state=0;
            SNR(i)=SNRb;
        else
            SNR(i)=SNRg;
        end;
    end;
end;
NoisePower=SignalPower./SNR;
%randn generates normally distributed random numbers with sigma=1 (Power=1)
Noise=sqrt(NoisePower).*randn(1,n); 
OutputStream=InputStream+Noise;