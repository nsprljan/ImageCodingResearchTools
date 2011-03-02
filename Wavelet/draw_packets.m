function draw_packets(D,N,pdep,s,packet_stream)
%Visualises the wavelet packets decomposition  
%draw_packets(D,N,pdep,s,packet_stream)
%
%Input:
% D - array of wavelet coefficients
% N - number of dyadic (pre-packet) decompositions
% pdep - "packet decomposition depth"
% s - structure containing info on parent-children relationship between subbands
%     (see in decomp_packets.m)
% packet_stream - stream of bits representing information on splitting decisions
%                 of wavelet packets decomposition 
%
%Note:
% Draws 4 plots.
%
%Example:
% par=struct('N',5,'pdep',2,'wvf',load_wavelet('CDF_9x7'),'dec','greedy');
% ent_par=struct('ent','shannon','opt',0);
% [D,packet_stream,s,E]=decomp_packets2D('lena256.png',par,ent_par);
% draw_packets(D,par.N,par.pdep,s,packet_stream);

scrsz = get(0,'ScreenSize');
figure('Name','Wavelet packet structure drawn by bit information');
pdep=pdep-N+1;
if size(packet_stream,2)>1
 packet_stream=fliplr(packet_stream);
end;    
cnt=0;
set(gca,'YDir','reverse','PlotBoxAspectRatio',[1 1 1],'XTick',[],'YTick',[]);
siz=1/(2^N);
for i=1:N     
 rectangle('Position',[0,0,siz,siz]);
 rectangle('Position',[0,siz,siz,siz]);
 rectangle('Position',[siz,0,siz,siz]);
 rectangle('Position',[siz,siz,siz,siz]);
 if pdep>0
  cnt=draw_subband(siz,siz,packet_stream,cnt,siz,pdep);
  cnt=draw_subband(0,siz,packet_stream,cnt,siz,pdep);
  cnt=draw_subband(siz,0,packet_stream,cnt,siz,pdep);    
 end;
 siz=siz*2;
 pdep=pdep+1;
end;
%second plot - drawn by subband structure s (small - convinient for copy/paste)
figure('Position',[300 200 200 200],'Name','Wavelet packet structure drawn by ''s'' subband structure');
set(gca,'YDir','reverse','PlotBoxAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Position',[0.005 0.005 0.99 0.99]);
axis([0 size(D,2) 0 size(D,1)]);
wavelet_dec_bands=N*3+1;
for i=1:size(s,2)
 if i<=wavelet_dec_bands
  lw=2;   
 else
  lw=1;   
 end;    
 rectangle('Position',s(i).band_abs,'LineWidth',lw);   
end;
%third plot - drawn by subband structure s, with linked subbands 
%figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
figure('Position',[scrsz(3)/2-3*scrsz(4)/8 scrsz(4)/2-3*scrsz(4)/8 6*scrsz(4)/8 6*scrsz(4)/8],...
    'Name','Wavelet packet structure drawn by s - subabnd structure');
set(gca,'YDir','reverse','PlotBoxAspectRatio',[1 1 1],'XTick',[],'YTick',[],'Position',[0.005 0.005 0.99 0.99]);
axis([0 size(D,2) 0 size(D,1)]);
wavelet_dec_bands=N*3+1;
for i=1:size(s,2)
 if i<=wavelet_dec_bands
  lw=2;   
 else
  lw=1;   
 end;    
 rectangle('Position',s(i).band_abs,'LineWidth',lw);   
end;
cmap=colormap('prism');
lv=1;
link_subbands(s(1),s,cmap,lv);
%and finally draw decomposed subbands
figure('Name','Wavelet packet transform coefficients');
set(gca,'YDir','reverse','PlotBoxAspectRatio',[1 1 1],'XTick',[],'YTick',[]);
axis([0 size(D,2) 0 size(D,1)]);
image('CData',100*log10(abs(D)));colormap(gray(256));
for i=1:size(s,2)
 if i<=wavelet_dec_bands
  lw=2;   
 else
  lw=1;   
 end;    
 rectangle('Position',s(i).band_abs,'LineWidth',lw,'EdgeColor','white');   
end;

function cnt=draw_subband(sx,sy,packet_stream,cnt,siz,pdep)
 cnt=cnt+1;
 if packet_stream(cnt)
  pdep=pdep-1;  
  siz=siz/2;
  rectangle('Position',[sx,sy,siz,siz]);
  rectangle('Position',[sx+siz,sy,siz,siz]);
  rectangle('Position',[sx,sy+siz,siz,siz]);
  rectangle('Position',[sx+siz,sy+siz,siz,siz]);
  if pdep>0
   cnt=draw_subband(sx+siz,sy+siz,packet_stream,cnt,siz,pdep);
   cnt=draw_subband(sx,sy+siz,packet_stream,cnt,siz,pdep);
   cnt=draw_subband(sx+siz,sy,packet_stream,cnt,siz,pdep);    
   cnt=draw_subband(sx,sy,packet_stream,cnt,siz,pdep);    
  end;
  %siz=siz*2;
 end;
 
 function link_subbands(node,s,cmap,lv)
  n=node.children;
  if n(1)>0
   for i=1:size(n,2)
    child=s(n(i));
    link_subbands(child,s,cmap,lv+1);   
    %krc0=floor(lv/2)/lv;
    %krc1=floor((lv+1)/2)/(lv+1);
    childcoordx=child.band_abs(1)+child.band_abs(3)/4;
    childcoordy=child.band_abs(2)+child.band_abs(4)/4;
    parentcoordx=node.band_abs(1)+node.band_abs(3)/2;
    parentcoordy=node.band_abs(2)+node.band_abs(4)/2;
    line([parentcoordx childcoordx],[parentcoordy childcoordy],'Color',cmap(lv,:));
    text(childcoordx,childcoordy,int2str(n(i)));
    %next line for use with arrow.m by F. Golnaraghi et al.
    %arrow([parentcoordx parentcoordy],[childcoordx childcoordy],'Length',10); 
   end;  
  end;