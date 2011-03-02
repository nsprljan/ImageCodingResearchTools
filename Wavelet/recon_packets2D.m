function A=recon_packets2D(D,param,packet_stream)
%2D wavelet packets reconstruction
%A=recon_packets2D(D,param,packet_stream)
%
%Input: 
% D - array of wavelet coefficients
% param - structure containing decomposition parameters (see in 
%         decomp_packets.m)
% packet_stream - stream of bits representing information on splitting decisions
%                 of wavelet packets decomposition 
%
%Output: 
% A - reconstructed array
%
%Uses:
% idwt_2D.m
%
%Example:
% [D,packet_stream]=decomp_packets2D(Y,par,ent_par);%see decomp_packets2D.m
% A=recon_packets2D(D,par,packet_stream);

param.pdep=param.pdep-param.N+1; %e.g. if N=5 and pdep=2 -> param.pdep=-2
if size(packet_stream,2)>1
 packet_stream=fliplr(packet_stream);
 entropy=1;
else
 entropy=0;   
end;    
cnt=0;
siz=size(D)/(2^param.N);
for i=1:param.N     
 D1=D(1:siz(1),1:siz(2));
 DH1=D(1:siz(1),siz(2)+1:2*siz(2));  
 DV1=D(siz(1)+1:2*siz(1),1:siz(2));
 DD1=D(siz(1)+1:2*siz(1),siz(2)+1:2*siz(2));   
 if (i > 1) && (param.pdep > 0) && entropy
  [DD1,cnt]=recon_entropy(DD1,param,packet_stream,cnt);
  [DV1,cnt]=recon_entropy(DV1,param,packet_stream,cnt);
  [DH1,cnt]=recon_entropy(DH1,param,packet_stream,cnt);    
 end;
 A=idwt_2D(D1,DH1,DV1,DD1,param.wvf);
 siz=siz*2;
 D(1:siz(1),1:siz(2))=A;
 param.pdep=param.pdep+1;
end;

function [band,cnt]=recon_entropy(band,param,packet_stream,cnt)
 cnt=cnt+1;
 if packet_stream(cnt)
  param.pdep=param.pdep-1;   
  siz=size(band)/2;
  D1=band(1:siz(1),1:siz(2));
  DH1=band(1:siz(1),siz(2)+1:2*siz(2));  
  DV1=band(siz(1)+1:2*siz(1),1:siz(2));
  DD1=band(siz(1)+1:2*siz(1),siz(2)+1:2*siz(2));   
  if param.pdep>0
   [DD1,cnt]=recon_entropy(DD1,param,packet_stream,cnt);
   [DV1,cnt]=recon_entropy(DV1,param,packet_stream,cnt);
   [DH1,cnt]=recon_entropy(DH1,param,packet_stream,cnt);    
   [D1,cnt]=recon_entropy(D1,param,packet_stream,cnt);    
  end;
  band=idwt_2D(D1,DH1,DV1,DD1,param.wvf);
 end;