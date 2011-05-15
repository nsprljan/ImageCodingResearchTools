function [ch_handle,parametar]=get_channel(chnlname)
%[ch_handle,parametar]=get_channel(chnlname)
%Version: 1.00, Date: 2003, author: Nikola Sprljan
%Loads a predefined channel (saved in a txt file)
%
%Input: 
% chnlname - the file name of the channel definition, without the mandatory 
%            extension '.txt'
%
%Output:
% ch_handle - function handle that simulates the channel
% parametar - a complete definition of the channel, for an example see in 
%             the channel definitions provided.
%
%Note:
% The predefined location of the channels is the directory '\channels'.
% The common part of all channel descriptions is the function handler that 
% simulates it, and the following parameters:
%  state - state(?) of the channel
%  Bch - bandwidth of the channel in bps
%  Nch - packet size in bits defined on the channel
%  gain - defintion of power gain (attenuation) of the channel.
%Specific parameters, for the provided channels include:
% BSC channel:
%  BER - bit error rate
% AWGN channel: 
%  EsN0 - signal to noise ratio (Es/N0)
% GE channel:
%  EsN0 - signal to noise ratio (Es/N0)
%  PGB - probability of switching from good to bad state of the channel
%  PBG - probability of switching from bad to good state of the channel
%  BERg - BER when the channel is in its good state
%  BERb - BER when the channel is in its bad state
%
%Example:
% [ch_handle,parametar]=get_channel('GE1');

fid=fopen(['.\channels\' chnlname '.txt'],'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline) break; end;
    eval(tline);
end;
fclose(fid);