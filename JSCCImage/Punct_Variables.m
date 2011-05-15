function [PunctIndFull,PacketData,DepunctLen]=Punct_Variables(Memory,Ib,Kb,PN,P,PunctInd,packet_siz,CRC_siz)

%paket=paket+Kb-rem(paket,Kb);
%fprintf('First possible packet size: %d\n',paket);
%PacketData=Ib*paket/Kb-Memory-CRC_size;
KbP=Kb*(P/Ib);
N=PN/P;
PunctPeriods=floor(packet_siz/KbP);
PacketData=P*PunctPeriods-Memory-CRC_siz; %Packet size restriction (few extra bits available in packet) 
PunctIndFull=[];
for i=1:PunctPeriods
    PunctIndFull=[PunctIndFull PN*(i-1)+PunctInd];
end;
extra_bits=packet_siz-length(PunctIndFull);
additional_data_bits=0;
if extra_bits
additional_data_bits=ceil(PunctInd(extra_bits)/N);
%Adding extra symbols to fill up packet size    
PacketData=PacketData+additional_data_bits;
end;
PunctIndFull=[PunctIndFull PN*PunctPeriods+PunctInd(1:extra_bits)];
DepunctLen=PN*PunctPeriods+additional_data_bits*N;
%IndErased=setdiff(1:DepunctLen,PunctIndFull);
%fprintf('Extra bits: %d\n');
% if ~isempty(IndErased)
%     Erm=IndErased(round(end/2));
%     [S,IndS]=sort(abs(IndErased-Erm));
%     extra=min(extra_bits,length(IndS));
%     ExtraSymbols=IndErased(IndS(1:extra));
%     PunctIndFull=[PunctIndFull ExtraSymbols];
%     extra_bits=packet_siz-length(PunctIndFull);
% end;
% if extra_bits %there's still some unused bits
%     PunctIndFull=[PunctIndFull PunctIndFull(1:extra_bits)];
% %     fprintf('Extra bits for repeating symbols: %d\n');
% end;