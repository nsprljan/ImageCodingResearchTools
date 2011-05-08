function varargout =jpeg2000gui(varargin)
%GUI callbacks for the Jpeg 2000 demo
%jpeg2000gui

if nargin == 0  % LAUNCH GUI

    fig = openfig(mfilename,'reuse');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);

    if nargout > 0
        varargout{1} = fig;
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    % Generate a structure of handles to pass to callbacks, and store it.

    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end

end

function varargout = Fig1_CreateFcn(h, eventdata, handles, varargin)
%postavljanje figure u srediste

scrsiz=get(0,'ScreenSize');
fig=gcbo;
figsiz=get(fig,'Position');
set(fig,'Position',[(scrsiz(3)-figsiz(3))/2 (scrsiz(4)-figsiz(4))/2 figsiz(3) figsiz(4)]);

function varargout = Fileuimenu1_Open(h, eventdata, handles, varargin)
%ucitavanje slike uz postavljena ogranicenja

bitmap=0;A=0;map=0;siz=0;
while (~bitmap)
    [file,path]=uigetfile([{'*.png'};{'*.bmp'};{'*.mat'}],'Get image');
    if file==0 break;end;
    filep=strcat(path,file);
    [path,name,ext]=fileparts(filep);
    if strcmp(ext,'.mat')
        A=load(filep);
        fnames=fieldnames(A);
        A=getfield(A,fnames{1});
        map=gray(256);
        siz=size(A,1);
        bitmap=1; %indicator that image is loaded
    else
        lasterr('');
        try,[A,map]=imread(filep);catch,end;
        if isempty(lasterr)
            info=imfinfo(filep);
            Asiz=size(A);siz=Asiz(1);
            lgsiz=log2(Asiz(1));
            if (strcmp(info.ColorType,'truecolor'))
                warndlg('Truecolor images not supported!','Warning!');
                uiwait;
            elseif (Asiz(1)~=Asiz(2) | lgsiz~=uint8(lgsiz))
                warndlg('Not a 2^n x 2^n picture!','Warning!');
                uiwait;
            elseif ((strcmp(info.ColorType,'grayscale')) | (ndims(A) == 2))
                map=gray(256);
                bitmap=1;
            else
                if ~all(all(map==gray(size(map,1))))
                    if ~(all(map(:,1)==map(:,2)) & all(map(:,1)==map(:,3)))
                        warndlg('Converting to grayscale!','Warning!');
                        uiwait;
                    end;
                    A=round(255.*ind2gray(A,map));
                    map=gray(256);
                end;
                bitmap=1;
            end;
        end;
    end;
end;

if file==0 return;end;
set(gcbo,'UserData',siz);

h=guidata(gcbo);
B=findobj(h.Result_Axes,'Tag','Compressed');
if ~isempty(B)
    delete(B); %brise staru sliku
end;
set(h.Fig1,'CurrentAxes',h.Axes1);
stara=findobj(h.Axes1,'Tag','Original');
if ~isempty(stara)
    delete(stara); %brise staru sliku
end;
%slika
set(h.text5,'String',file);
colormap(gray(256));
image('CData',A,'Tag','Original','xdata',[1 siz],'ydata',[1 siz],...
    'EraseMode','none','ButtonDownFcn','jpeg2000gui moveblock');
set(h.Axes1,'XLim',[0 siz+1],'YLim',[0 siz+1]);
drawnow;
%uimenu
ui1=uicontextmenu('Tag','menuslike1','HandleVisibility','off');
item1=uimenu(ui1,'Label','Display in real size','Callback','jpeg2000gui display_real');
item2=uimenu(ui1,'Label','Save','Callback','jpeg2000gui save_slika');
item3=uimenu(ui1,'Label','Assign to workspace','Callback','jpeg2000gui save_matrix');
set(findobj(h.Fig1,'Tag','Original'),'UIContextMenu',ui1);
%a sad, prikaz vrijednosti prvog blocka u axe3
delete(findobj(h.Axes1,'Type','line'));
x=[0 0 9 9 0];y=[0 9 9 0 0];Ud(1,1:5)=x;Ud(2,1:5)=y;
slina=line('XData',x,'YData',y,'UserData',Ud,'Tag','kockica',...
    'Color','red','EraseMode','xor','LineWidth',2,'ButtonDownFcn','jpeg2000gui moveblock');
show_values(h.Axes3,A(1:8,1:8));
% jpeg2000gui('compress_image');
%  B=get(findobj(h.Fig1,'Tag','Compressed'),'CData');
%  show_values(h.Axes4,B(1:8,1:8));

function show_values(axes,mtrx)
%funkcija prikazuje vrijednosti slike zahvacene kvadraticem

set(gcbf,'CurrentAxes',axes);cla;
korak=0.125;pocx=0.0625;pocy=0.9375;
for i=1:8
    for j=1:8
        num=double(mtrx(i,j));
        text(pocx,pocy,num2str(num,'%3d'),'Units','normalized','HorizontalAlignment','center',...
            'FontUnits','points','FontSize',7,'Color',[0 0 0]);
        pocx=pocx+korak;
    end;
    pocy=pocy-korak;
    pocx=0.0625;
end;
set(axes,'UserData',mtrx);

function compress_image

h=guidata(gcbo);
set(h.Fig1,'Pointer','watch');
%ucitavanje postavki
bpp=str2num(get(h.Bpp_input,'String'));
if ~isempty(bpp);
    A=get(findobj(h.Axes1,'Tag','Original'),'CData');
    C=jpeg2000jj2k(A,bpp,0);
    C=C{1};
end;
if ~isempty(C)
    %Prikaz u Result_Axes osima
    siz=size(A,1);
    set(h.Fig1,'CurrentAxes',h.Result_Axes);
    B=findobj(h.Result_Axes,'Tag','Compressed');
    if ~isempty(B)
        delete(B); %brise staru sliku
    end;
    %slika
    colormap(gray(256)); %%
    image('CData',C,'Tag','Compressed','EraseMode','none');
    set(h.Result_Axes,'XLim',[-1 siz+0.5],'YLim',[-1 siz+0.5]);
    drawnow;
    ui2=uicontextmenu('Tag','menuslike2','HandleVisibility','off');
    item1=uimenu(ui2,'Label','Display in real size','Callback','jpeg2000gui display_real');
    item2=uimenu(ui2,'Label','Save','Callback','jpeg2000gui save_slika');
    item3=uimenu(ui2,'Label','Assign to workspace','Callback','jpeg2000gui save_matrix');
    set(findobj(h.Fig1,'Tag','Compressed'),'UIContextMenu',ui2);
    CR=8/bpp; % assumes 8 bits per pixel
    stopise=sprintf('1:%3.1f',CR);
    set(h.text6,'String',stopise);

    MSE=sum(sum((double(A)-double(C)).^2))/(siz*siz); % MSE
    %fprintf('MSE (Mean Square Error)= %f\n',MSE);
    % PSNR
    if MSE>0
        PSNR=10*log10(255^2/MSE);
    else
        PSNR=Inf;
    end;
    stopise=sprintf('%3.1f',MSE);
    set(h.text8,'String',stopise);
    stopise=sprintf('%3.1f dB',PSNR);
    set(h.text7,'String',stopise);
    %prikaz elemenata rekonstruirane slike
    kockica=findobj(h.Fig1,'Tag','kockica');
    koo=get(kockica,'UserData');
    mtrx(1:8,1:8)=C(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
    show_values(h.Axes4,mtrx);
end;
set(h.Fig1,'Pointer','arrow');
      
function display_real
% za prikaz slike u punoj velicini

h=guidata(gcbo);
himage=findobj(h.Fig1,'UIContextMenu',get(gcbo,'Parent'));
Slika=get(himage,'CData');
siz=size(Slika,1);
scrsiz=get(0,'ScreenSize');
ff=figure('HandleVisibility','Callback','NumberTitle','off','MenuBar','none',...
    'Resize','on','Name',['Real size view - ' get(himage,'Tag')],'Units','pixels',...
    'Position',[(scrsiz(3)-siz)/2 (scrsiz(4)-siz)/2 siz+10 siz+10]);
fa=axes('Parent',ff);
image(Slika);
set(fa,'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[1 1 1],...
    'Box','on','XTickMode','manual','YTickMode','manual','XTick',[],'YTick',[],...
    'Units','pixels','Position',[5 5 siz siz],'YDir','reverse');
colormap(gray(256));

function save_slika
%sejvanje bmp slike

slika=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent'));
[file,path]=uiputfile('*.bmp','Save picture');
if file==0 return;end;
filep=strcat(path,file);
[path,name,ext]=fileparts(filep);
if isempty(ext)
    ext='.bmp'
    filep=strcat(filep,ext);
end;
if ~strcmp(ext,'.bmp')
    warndlg('Not a bmp file!','Warning!');
    uiwait;
    return;
end;
A=get(slika,'CData');
imwrite(A,gray(256),filep,'bmp');

function moveblock
%provjerava da li je mis pritisnut iznad selektiranog blocka (i +-2 okolo blocka)

currentPoint=get(gca,'CurrentPoint');
kockica=findobj(gcbf,'Tag','kockica');
koord=get(kockica,'UserData');
oldX(1:2)=koord(1,2:3);oldY(1:2)=koord(2,1:2);
newX=currentPoint(1);
newY=currentPoint(3);
if (newX>oldX(1)-2) & (newX<oldX(2)+2) & (newY>oldY(1)-2) & (newY<oldY(2)+2)
    koord(1,5)=newX-oldX(1);koord(2,5)=newY-oldY(1);
    set(kockica,'UserData',koord);
    set(gcbf,'WindowButtonMotionFcn','jpeg2000gui movedalje');
    set(gcbf,'WindowButtonUpFcn','jpeg2000gui stop');
end;

function movedalje
%mis je pritisnut iznad selektiranog blocka a 'movedalje' kontrolira daljnje ponasanje

currentPoint=get(gca,'CurrentPoint');
kockica=findobj(gcbf,'Tag','kockica');
koord=get(kockica,'UserData');
siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
siz=siz-8;
razX=koord(1,5);razY=koord(2,5);
newX=currentPoint(1)-razX;
newY=currentPoint(3)-razY;
if abs(newX-koord(1,1))>8 | abs(newY-koord(2,1))>8
    newX=floor((newX+1)/8)*8;
    newY=floor((newY+1)/8)*8;
    uvjet1=((newX>0) & (newX<siz));
    uvjet2=((newY>0) & (newY<siz));
    uvjet3=0;
    uvjet4=0;
    if ~uvjet1
        if (newX<1 & koord(1,1)>-1) newX=0;end;
        if koord(1,3)>siz newX=siz;end;
        uvjet3=1;
    end;
    if ~uvjet2
        if (newY<1 & koord(2,1)>-1) newY=0;end;
        if koord(2,2)>siz newY=siz;end;
        uvjet4=1;
    end;
    if  uvjet1 | uvjet2 | uvjet3 | uvjet4
        oldX=koord(1,1:4);oldX(5)=oldX(1);
        oldY=koord(2,1:4);oldY(5)=oldY(1);
        set(kockica,'XData',oldX,'YData',oldY);
        if uvjet1 | uvjet3 koord(1,:)=[newX newX newX+9 newX+9 newX]; else koord(1,5)=oldX(1);end;
        if uvjet2 | uvjet4 koord(2,:)=[newY newY+9 newY+9 newY newY]; else koord(2,5)=oldY(1);end;
        set(kockica,'XData',koord(1,:),'YData',koord(2,:));
        koord(1,5)=razX;koord(2,5)=razY;
        set(kockica,'UserData',koord);
    end;
end;

function stop
%ako mis stane ispisi block

h=guidata(gcbo);
set(h.Fig1,'WindowButtonMotionFcn','');
set(h.Fig1,'WindowButtonUpFcn','');
kockica=findobj(gcbf,'Tag','kockica');
koo=get(kockica,'UserData');
A=get(findobj(h.Fig1,'Tag','Original'),'CData');
mtrx(1:8,1:8)=A(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
show_values(h.Axes3,mtrx);
B=get(findobj(h.Fig1,'Tag','Compressed'),'CData');
if ~isempty(B)
    mtrx(1:8,1:8)=B(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
    show_values(h.Axes4,mtrx);
end;

function save_matrix

slika=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent'));
A=get(slika,'CData');
assignin('base','A',A);
fprintf('Picture assigned to workspace as matrix A!\n');