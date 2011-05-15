function [OutputStream,parametar]=awgn_EsN0(InputStream,parametar)
%[OutputStream,parametar]=awgn_EsN0(InputStream,parametar)
%Simulation of the Additive White Gaussian Noise (AWGN) channel
%
%Input: 
% InputStream - input stream of symbols (1 and -1)
% parametar - signal to noise ratio (Es/N0) of the channel or a complete 
%             definition of the channel, see in get_channel.m
%
%Output:
% OutputStream - output stream of symbols with added noise
% parametar - the same as the input variable, here due to API compatibility
% with other channels
%
%Note:
% BPSK modulation is assumed, the power of the signal can be set with the 
% variable 'SignalPower'.
%
%Example:
% out=awgn_EsN0(randsrc(1,1024,[-1 1]),10);

%CONSTANTS
SignalPower=1; %power of the input signal in Watts
%
if isstruct(parametar)
    SNR=10*log10(2)+parametar.EsN0+parametar.gain; %SNR is Es/sigma^2 = 0.5*(Es/N0)
else
    SNR=10*log10(2)+parametar;
end;
NoisePower=SignalPower*10^(-SNR/10);
%randn generates normally distributed random numbers with sigma=1 (Power=1)
Noise=sqrt(NoisePower)*randn(1,length(InputStream)); 
OutputStream=InputStream+Noise;