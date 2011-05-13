function dctact(action)
%Callback functions for DCTlab
%
%Uses:
% blkdct2fft.m, blkidct2fft.m, blkdct2cos.m, blkidct2cos.m
% ..\QualityAssesment\iq_measures.m

figura=gcbf;
switch action
case 'getfile' %Load image
    [file,A,map,siz]=get_file; %call function get_file  
    if file==0 
        return;
    end;
    reset_gamma(figura);
    reset_treshold(figura);
    reset_reconstruct(figura);
    reset_quant(figura);
    reset_code(figura);
    set(findobj(figura,'Tag','Pushbutton2'),'String','Reconstruction >>');
    drawnow;
    set(gcbo,'UserData',siz);   
    maxcnt=log2(siz);ukupno='';%popup string
    if maxcnt>9 
        maxcnt=9;
    end;
    for cnt=2:maxcnt 
        sizcnt=2^cnt;
        Bs='       ';
        As=sprintf('%dx%d',sizcnt,sizcnt);
        Bs(1:length(As))=As(1:length(As));
        ukupno=[ukupno;Bs];
    end;
    set(findobj(figura,'Tag','PopupMenu1'),'String',ukupno);
    set(findobj(figura,'Tag','PopupMenu1'),'Value',maxcnt-1);
    ax1=findobj(figura,'Tag','Axes1');
    set(ax1,'UserData',upper(file));
    set(figura,'CurrentAxes',ax1);
    stara=findobj(ax1,'Tag','Slika');
    if ~isempty(stara) 
        delete(findobj(gcbf,'Tag','menuslike1'));%delete old uimenus
        delete(stara);
    end;
    %display image
    set(findobj(figura,'Tag','StaticText2'),'String',file);
%     Map=zeros(512,3);
%     Map=[map;map];
    image('CData',A,'UserData',mapuser(map,0,0),'Tag','Slika',...
        'EraseMode','none','ButtonDownFcn','dctact moveblock');
    colormap(map);
    set(ax1,'XLim',[-1 siz+2],'YLim',[-1 siz+2]);
    drawnow;
    %uimenu
    ui1=uicontextmenu('Tag','menuslike1','HandleVisibility','off');
    item1=uimenu(ui1,'Label','Zoom view','Callback','dctact full'); 
    item2=uimenu(ui1,'Label','Save','Callback','dctact save');
    item3=uimenu(ui1,'Label','Assign to workspace','Callback','dctact save_matrix');
    item4=uimenu(ui1,'Label','Frequency analysis (DFT)','Callback','dctact ffreqan',...
        'Separator','on'); 
    set(findobj(figura,'Tag','Slika'),'UIContextMenu',ui1);
    %a sad, prikaz vrijednosti prvog blocka u axe3
    delete(findobj(ax1,'Type','line'));
    x=[0 0 9 9 0];y=[0 9 9 0 0];Ud(1,1:5)=x;Ud(2,1:5)=y;
    slina=line('XData',x,'YData',y,'UserData',Ud,'Tag','kockica',...
        'Color','red','EraseMode','xor','LineWidth',2,'ButtonDownFcn','dctact moveblock');
    namjesti_tekst(Ud);
    show_values(findobj(figura,'Tag','Axes3'),A(1:8,1:8),0.065,'%3d');
    %1. korak gotov - omoguæi 2. korak
    set(findobj(figura,'UserData',2),'Enable','on');
case 'dajdct' %%%%%DAJDCT%%%%%%   
    set(figura,'Pointer','watch');
    reset_gamma(figura);
    reset_treshold(figura);
    reset_reconstruct(figura);
    reset_quant(figura);
    reset_code(figura);
    drawnow;
    block=2^(1+get(findobj(figura,'Tag','PopupMenu1'),'Value'));
    siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
    A=get(findobj(figura,'Tag','Slika'),'CData');
    if get(findobj(figura,'Tag','Checkbox2'),'Value')
        A=double(A)-128;end;   
    Y=blkprocnik(A,block,'dct');
    os=findobj(figura,'Tag','Axes2');
    set(os,'UserData','DCT coefficients');
    set(findobj(figura,'Tag','Frame2'),'UserData',Y);%koeficijenti idu na Frame2!!!
    koef=(abs(Y));
    koef(koef>255)=255;
    koef=uint8(koef);
    map=gray(256);
    stara=findobj(os,'Tag','Slikakoef');
    if ~isempty(stara) delete(stara);end;
    set(figura,'CurrentAxes',os);
    %uimenu
    delete(findobj(gcbf,'Tag','menuslike2'));
    ui2=uicontextmenu('Tag','menuslike2');
    item12=uimenu(ui2, 'Label', 'Zoom view','Callback','dctact full');
    item22=uimenu(ui2,'Label','Save','Callback','dctact save');
    item32=uimenu(ui2,'Label','Assign to workspace','Callback','dctact save_matrix');
    if block==siz
        item42=uimenu(ui2,'Label','Frequency analysis (DCT)','Callback','dctact freqan',...
            'Separator','on');
        pragized=findobj(figura,'Tag','StaticText8'); %i za pocetak pragizirani su isti oridjidji
        set(pragized,'UserData',Y);
    end;   
    %slikakoef - vrijednosti slike idu na Slikakoef!!!
    %colormap([map;mapx(map,0,0)]);
    %koef=double(koef)+257;
    colormap(mapx(map,0,0));
    image('CData',koef,'UserData',mapuser(map,0,0),'Tag','Slikakoef','UIContextMenu',ui2,'EraseMode','none');
    set(os,'XLim',[-2 siz+2],'YLim',[-2 siz+2]); 
    %slikakoef 
    %2. korak gotov - omogucen 3.25 i 3. i onemoguceni ostali 
    set(findobj(figura,'UserData',3),'Enable','on');
    set(findobj(figura,'UserData',3.25),'Enable','on');
    show_dct_block(figura);
    %i jos izmjena u Treshold frameu
    Yabs=abs(Y);
    str1=sprintf('%0.2g',min(min(Yabs)));
    str2=sprintf('%5.1f',max(max(Yabs)));
    set(findobj(figura,'Tag','StaticText9'),'String',['|coeff| in range  [',str1,'...',str2,']']);
    kolkonula=size(find(Y==0),1)/(siz^2);
    strng=sprintf('%2.1f%% (%2.1f%%)',0,kolkonula*100);  
    set(findobj(figura,'Tag','StaticText11'),'String',[strng ' coeff==0']);
    %
    set(figura,'Pointer','arrow');
    %
    %evo,samo da napravim frekvencijsku analizu
case 'ffreqan'
    set(0,'Units','pixels');
    scrsz=get(0,'Screensize');
    xsiz=scrsz(3);ysiz=scrsz(4);
    set(figura,'Pointer','watch');
    %Zx=abs(get(findobj(figura,'Tag','Frame2'),'UserData'));
    slika=get(findobj(figura,'Tag','Slika'),'CData');
    %naduzorkovanje slike
    %assignin('base','S',S);
    [SFM,Y]=activity(slika);
    %[Z,sz,maxY]=psd1D(Y,1);
    [Z,sz,maxY]=flatfreq2(Y,1,1);
    Z(:,1)=Z(:,1)*2;
    file=get(findobj(figura,'Tag','Axes1'),'UserData');
    ff=figure('NumberTitle','off','MenuBar','none',...
        'Resize','off','Name',['Power Spectral Density- ' file],'Units','pixels',...
        'Position',[xsiz/2-300 ysiz/2-200 600 400]);
    h1 = uimenu('Parent',ff,'Label','Save as image','Tag','uimenufreq','CallBack','dctact savegraph');
    h=axes('Position',[0.1 0.1 0.8 0.8]);
    plot(Z(:,1),Z(:,2),'Color','black','LineWidth',2,'Parent',h);
    set(h,'XLim',[0 Z(sz,1)],'YLim',[-2 maxY],'FontSize',12,...
        'FontWeight','Bold','XLabel',text('String','Frequency [periods / image size]',...
        'FontSize',12,'FontWeight','Bold'));
    ylabel('Amplitude (log10)');%),'String',,'FontSize',12,'FontWeight','Bold'
   
    %text(0.5,1.02,['Spectral Flatness Measure (SFM): ' SFM],...
    %   'Units','normalized','FontWeight','Bold','FontUnits','normalized');
    grid on;
    set(figura,'Pointer','arrow');
case 'freqan'
    set(0,'Units','pixels');
    scrsz=get(0,'Screensize');
    xsiz=scrsz(3);ysiz=scrsz(4);
    set(figura,'Pointer','watch');
    Zx=abs(get(findobj(figura,'Tag','Frame2'),'UserData'));
    [Z,sz,maxY]=flatfreq(Zx);%
    file=get(findobj(figura,'Tag','Axes1'),'UserData');
    ff=figure('NumberTitle','off','MenuBar','none',...
        'Resize','off','Name',['Frequency analysis - ' file],'Units','pixels',...
        'Position',[xsiz/2-300 ysiz/2-200 600 400]);
    h1 = uimenu('Parent',ff,'Label','Save as image','Tag','uimenufreq','CallBack','dctact savegraph');
    h=axes;
    plot(Z(:,1),Z(:,2),'Color','black','LineWidth',2,'Parent',h);
    set(h,'XLim',[1 Z(sz,1)],'YLim',[-2 maxY],'FontSize',12,...
        'FontWeight','Bold');
    xlabel('Frequency [periods / image size]');
    ylabel('Amplitude (log10)');
    grid on;
    set(figura,'Pointer','arrow');
    %
    %evo,samo da napravim frekvencijsku analizu rekonstruirane slike
case 'recfreqan'
    set(0,'Units','pixels');
    scrsz=get(0,'Screensize');
    xsiz=scrsz(3);ysiz=scrsz(4);
    set(figura,'Pointer','watch');
    pragized=abs(get(findobj(figura,'Tag','StaticText8'),'UserData'));   
    [Z,sz,maxY]=flatfreq(pragized); 
    file=get(findobj(figura,'Tag','Axes1'),'UserData');
    ff=figure('NumberTitle','off','MenuBar','none',...
        'Resize','off','Name',['Frequency analysis - ' file],'Units','pixels',...
        'Position',[xsiz/2-300 ysiz/2-200 600 400]);
    h1 = uimenu('Parent',ff,'Label','Save as image','Tag','uimenufreq','CallBack','dctact savegraph');
    h=axes;
    plot(Z(:,1),Z(:,2),'Color','black','LineWidth',2,'Parent',h);
    set(h,'XLim',[1 Z(sz,1)],'YLim',[-2 maxY],'FontSize',12,...
        'FontWeight','Bold','XLabel',text('String','Frequency [periods / image size]',...
        'FontSize',12,'FontWeight','Bold'));
    ylabel('Amplitude (log2)');
    % prag=str2num(get(findobj(figura,'Tag','EditText1'),'String'));
    % if prag 
    %  praglog=log2(prag); 
    %  if praglog>-2
    %    line(1:Z(sz,1),praglog,'Color','red');
    %    text('Position',[Z(sz,1)/2,praglog],'String','treshold','HorizontalAlignment','center',...
    %         'VerticalAlignment','bottom','Color',[0.5 0.5 0.5]); 
    %  end;   
    % end;   
    grid on;
    set(figura,'Pointer','arrow');
    % 
    %frekvencijaska analiza greske 
case 'erfreqan'   
    set(0,'Units','pixels');
    scrsz=get(0,'Screensize');
    xsiz=scrsz(3);ysiz=scrsz(4);
    set(figura,'Pointer','watch');
    naslov=findobj(figura,'Tag','reconstructed');
    switch get(findobj(figura,'Callback','dctact error_recon'),'Label')
    case 'Reconstructed image'
        razlika=get(findobj(figura,'Tag','Slikaerr'),'CData');
    otherwise razlika=get(naslov,'UserData');
    end;   
    block=2^(1+get(findobj(figura,'Tag','PopupMenu1'),'Value'));
    Y=abs(blkprocnik(razlika,block,'dct'));
    [Z,sz,maxY]=flatfreq(Y);
    file=get(findobj(figura,'Tag','Axes1'),'UserData');
    ff=figure('NumberTitle','off','MenuBar','none',...
        'Resize','off','Name',['Error Frequency analysis - ' file],'Units','pixels',...
        'Position',[xsiz/2-300 ysiz/2-200 600 400]);
    h1 = uimenu('Parent',ff,'Label','Save as image','Tag','uimenufreq','CallBack','dctact savegraph');
    h=axes;
    plot(Z(:,1),Z(:,2),'Color','black','LineWidth',2,'Parent',h);
    set(h,'XLim',[1 Z(sz,1)],'YLim',[-2 maxY],'FontSize',12,...
        'FontWeight','Bold','XLabel',text('String','Frequency [cycles / image size]',...
        'FontSize',12,'FontWeight','Bold'));
    ylabel('Amplitude (log10)');
    grid on;
    set(figura,'Pointer','arrow'); 
    %
    %rekonstrukcija - ako je 8x8 onda kvantizacija inace odmah rekonstrukcija
case 'reconstruction'
    objekt=gcbo;  
    set(figura,'Pointer','watch');
    reset_reconstruct(figura);
    drawnow;
    block=2^(1+get(findobj(figura,'Tag','PopupMenu1'),'Value'));
    siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
    koo=get(findobj(figura,'Tag','kockica'),'UserData');
    ifquanted=strcmp(get(objekt,'Tag'),'quant_button'); 
    if ~ifquanted
        reset_quant(figura);
        reset_code(figura);
        drawnow;
        trshld=get(findobj(figura,'Tag','EditText1'),'String');  
        if ~isempty(trshld)
            Z=get(findobj(figura,'Tag','StaticText8'),'UserData');
        else   
            Z=get(findobj(figura,'Tag','Frame2'),'UserData');
        end; 
    end; 
    if ~(block==8 & get(findobj(figura,'Tag','quant_check'),'Value')) | ifquanted
        if ifquanted 
            qZ=get(findobj(figura,'Tag','quant_Frame'),'UserData');
            expn=get(findobj(figura,'Tag','quant_slider'),'Value');expn2=2^expn;
            qmtrx=round(get(findobj(figura,'Tag','quant_axes'),'UserData').*expn2);
            qmtrx(qmtrx==0)=1;
            Qmtrx = repmat(qmtrx, size(qZ)./[8 8]);
            Z=round(qZ .* Qmtrx);
            %Z=blkproc(qZ,[8 8],'x.*P1',qmtrx);
        end;
        B=blkprocnik(double(Z),block,'idct');
        if get(findobj(figura,'Tag','Checkbox2'),'Value')
            B=B+128;
        end;   
        B(B>255)=255;
        B(B<0)=0;
        B=uint8(round(B));
        axerr=findobj(figura,'Tag','error_axes');
        set(axerr,'UserData','Reconstructed image'); 
        set(figura,'CurrentAxes',axerr);
        stara=findobj(axerr,'Tag','Slikaerr');
        if ~isempty(stara) delete(stara);end;
        delete(findobj(figura,'Tag','menuslike3'));
        %uimenu
        ui3=uicontextmenu('Tag','menuslike3');
        item43=uimenu(ui3,'Label','Error image','Callback','dctact error_recon');
        item13=uimenu(ui3,'Label','Zoom view','Callback','dctact full','Separator','on'); 
        item23=uimenu(ui3,'Label','Save','Callback','dctact save');
        item33=uimenu(ui3,'Label','Assign to workspace','Callback','dctact save_matrix');
        if block==siz
            item44=uimenu(ui3,'Label','Frequency analysis','Callback','dctact recfreqan',...
                'Separator','on');
            item45=uimenu(ui3,'Label','Error Frequency analysis','Callback','dctact erfreqan');
        end;  
        %slika
        map=gray(256);
        colormap(map);
        image('CData',B,'UserData',mapuser(map,0,0),'Tag','Slikaerr','UIContextMenu',ui3,...
            'EraseMode','none');
        set(axerr,'XLim',[-1 siz+2],'YLim',[-1 siz+2]);
        %sve ostalo
        set(findobj(figura,'UserData',4),'Enable','on');
        A=get(findobj(figura,'Tag','Slika'),'CData');
        razlika=abs(double(A)-double(B));
        razlika(razlika>255)=255; 
        set(findobj(figura,'Tag','reconstructed'),'UserData',uint8(razlika));
        %prikaz vrijednosti bloka u axe
        mtrx(1:8,1:8)=B(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','idct_block_axes'),mtrx,0.065,'%3d');
        if ~exist('iq_measures')
          h=msgbox('Function iq_measures.m not on the search path! The reconstruction quality measures will not be computed.','Message');   
        else    
         [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE]=iq_measures(A,B);
         if (MSE > 0) 
             PSNRs=sprintf('%.2f dB',PSNR);
         else 
             PSNRs='inf dB';
         end;
        set(findobj(figura,'Tag','QM_1'),'String',['MSE= ' sprintf('%.2f',MSE)]); 
        set(findobj(figura,'Tag','QM_2'),'String',['PSNR= ' PSNRs]);
        set(findobj(figura,'Tag','QM_3'),'String',['AD= ' sprintf('%.4f',AD)]);
        set(findobj(figura,'Tag','QM_4'),'String',['MD= ' sprintf('%.2f',MD)]);
        set(findobj(figura,'Tag','QM_5'),'String',['LMSE= ' sprintf('%.4f',LMSE)]);
        set(findobj(figura,'Tag','QM_6'),'String',['NAE= ' sprintf('%.4f',NAE)]);
        end;
    else 
        set(findobj(figura,'UserData',3.5),'Enable','on');
        qmtrx=get(findobj(figura,'Tag','quant_axes'),'UserData');
        Qmtrx=repmat(qmtrx, size(Z)./[8 8]);
        qZ=round(Z ./ Qmtrx);
        %qZ=round(blkproc(Z,[8 8],'x./P1',qmtrx));
        set(findobj(figura,'Tag','quant_Frame'),'UserData',qZ);
        mtrx(1:8,1:8)=qZ(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','quantised_axes'),mtrx,0.08,'%3d');
    end;  
    set(figura,'Pointer','arrow');

%mijenja gamma koeficijent slike 
case 'slidegamma'
    %BUG WITH COLORMAPS - NEED SOME TIME TO GET AROUND IT
    %http://www.mathworks.com/support/tech-notes/1200/1215.html
    gammaobj=gcbo;
    switch get(gammaobj,'UserData')
    case 3  
        texttag='StaticText5';
        slikatag='Slikakoef';
    case 4 
        texttag='err_text1';
        slikatag='Slikaerr';
    end;    
    gamma=get(gammaobj,'Value');
    n2st=sprintf(' %01.3g',gamma); 
    set(findobj(figura,'Tag',texttag),'String',['gamma:' n2st]);
    
    slika=findobj(figura,'Tag',slikatag);
    mapusr=get(slika,'UserData');
    staramapa=mapusr(2:257,1:3);
    map=mapusr(2:257,1:3);
    invert=mapusr(1,2);   
    set(figura,'CurrentAxes',get(slika,'Parent'));
   
    A=get(slika,'CData');
    %if min(min(A))<256 A=double(A)+256;end;
    set(slika,'CData',zeros(size(A))); %colormapa won't change unless CData is changed?
    set(slika,'CData',A,'UserData',mapuser(staramapa,gamma,invert));
    colormap(mapx(map,gamma,invert));
    
case 'invertkoef'
    gammaobj=gcbo;  
    switch get(gammaobj,'UserData')
    case 3  
        texttag='StaticText5';
        slikatag='Slikakoef';
    case 4 
        texttag='err_text1';
        slikatag='Slikaerr';
    end;
    invert=get(gammaobj,'Value');  
    slika=findobj(figura,'Tag',slikatag);
    usrmapa=get(slika,'UserData');
    staramapa=usrmapa(2:257,1:3);
    gamma=usrmapa(1,1);
    colormap(mapx(staramapa,gamma,invert));
    A=get(slika,'CData');
    set(slika,'CData',zeros(size(A))); %colormapa se nece promijeniti ako 'CData' ostane identican
    set(slika,'CData',A,'UserData',mapuser(staramapa,gamma,invert));
    
case 'linlog'  %eto, kolko muke samo za obicni lin/log prikaz
    set(figura,'Pointer','watch');
    os=findobj(figura,'Tag','Axes2');
    set(figura,'CurrentAxes',os);
    stara=findobj(os,'Tag','Slikakoef');
    mapusr=get(stara,'UserData');
    map=mapusr(2:257,1:3);
    gama=mapusr(1,1);
    invert=mapusr(1,2);
    koef=abs(get(findobj(figura,'Tag','Frame2'),'UserData'));
    prvi=findobj(figura,'Tag','Radiobutton2');
    drugi=findobj(figura,'Tag','Radiobutton1');
    val1=get(prvi,'Value');
    val2=get(drugi,'Value');
    if gcbo==prvi set(drugi,'Value',~val2); 
    else 
        val1=~val1;  
        set(prvi,'Value',val1);
    end;
    if val1 
        koef(koef>255)=255;
        koef=uint8(koef);
    else
        koef(koef==0)=0.0001;  
        maxi=max(max(koef));
        baza=10^(log10(1+maxi)/256);
        logbaza=log(baza);
        koef=log(1+koef)./logbaza;
        koef(koef>255)=255;
        koef(koef<0)=0;
        koef=uint8(koef);
    end; 
    set(stara,'CData',koef);
    colormap(mapx(map,gama,invert));
    set(figura,'Pointer','arrow');
    %
    %namjestanje praga
case 'dctlevel'  
    reset_gamma(figura);
    reset_treshold(figura);
    reset_reconstruct(figura);
    reset_quant(figura);
    reset_code(figura);  
case 'set_treshold' 
    reset_reconstruct(figura);
    reset_quant(figura);
    reset_code(figura);
    trshld=get(gcbo,'String');  
    siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
    pixels=siz^2;
    pragized=findobj(figura,'Tag','StaticText8');
    Y=get(findobj(figura,'Tag','Frame2'),'UserData');
    Z=Y;Y=abs(Y);
    slova=size(trshld,2);
    if trshld(slova)=='%'
        posto=str2num(trshld(1:slova-1));
        if ~isempty(posto)    
            if posto>100 posto=100;end;
            if posto<0 posto=0;end;
            post=round(pixels*posto/100);
            Ys=sort(Y(:));
            prag=Ys(post);
            set(gcbo,'String',num2str(prag));
        end; 
    elseif slova>1 & trshld(slova-1:slova)=='dB'
        PSNRz=str2num(trshld(1:slova-2));
        if ~isempty(PSNRz)    
            PSNRrac=0;donja=0;gornja=max(max(Y));
            prag=gornja/siz(1);
            Z1=Y;
            Z1(Y<=prag)=0;
            brojac=0;
            PSNRrac=10*log10(pixels*255^2/sum(sum((Z1-Y).^2)));
            while abs(PSNRz-PSNRrac)>1/20 & brojac<20
                Z1=Y;
                if PSNRrac>PSNRz   
                    donja=prag;
                    prag=(donja+gornja)/2;
                    Z1(Y<=prag)=0;
                    PSNRrac=10*log10(pixels*255^2/sum(sum((Z1-Y).^2)));
                else 
                    gornja=prag;
                    prag=(donja+gornja)/2;
                    Z1(Y<=prag)=0;
                    PSNRrac=10*log10(pixels*255^2/sum(sum((Z1-Y).^2)));
                end;   
                brojac=brojac+1;
            end;
            set(gcbo,'String',num2str(prag));
        end;  
    else   
        prag=str2num(trshld);
    end;
    if ~isempty(prag) & size(prag,2)==1
        Z(Y<=prag)=0;
        set(pragized,'UserData',Z);%pragizirani su na StaticText8!!!
        prije=size(find(Y==0),1)/(siz^2);
        poslije=size(find(Z==0),1)/(siz^2);
        strng=sprintf('%2.1f%% (%2.1f%%)',(poslije-prije)*100,poslije*100);  
        set(findobj(figura,'Tag','StaticText11'),'String',[strng ' coeff==0']);
        set(findobj(figura,'Tag','StaticText3'),'UserData',poslije);
        show_dct_block(figura); 
    else 
        set(gcbo,'String','');  
    end;   
    %
    %namjesta mnozenje kvantizacijskog blocka
case 'slidequant'  
    set(figura,'Pointer','watch');
    reset_reconstruct(figura);
    reset_code(figura);
    expn2=2^get(gcbo,'Value');  
    slidetext=findobj(figura,'Tag','quant_text3');
    qmtrx=get(findobj(figura,'Tag','quant_axes'),'UserData');
    qmtrx=round(qmtrx.*expn2);
    qmtrx(qmtrx==0)=1;
    quant_text(qmtrx,0.06,'quant',0.01,0.935,[0.5 0.5 0.5],'left');
    trshld=get(findobj(figura,'Tag','EditText1'),'String');  
    if ~isempty(trshld)
        Z=get(findobj(figura,'Tag','StaticText8'),'UserData');
    else   
        Z=get(findobj(figura,'Tag','Frame2'),'UserData');
    end; 
    Qmtrx = repmat(qmtrx, size(Z)./[8 8]);
    qZ=round(Z ./ Qmtrx);
    %qZ=round(blkproc(Z,[8 8],'x./P1',qmtrx));
    set(findobj(figura,'Tag','quant_Frame'),'UserData',qZ);
    koo=get(findobj(figura,'Tag','kockica'),'UserData');
    mtrx(1:8,1:8)=qZ(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
    show_values(findobj(figura,'Tag','quantised_axes'),mtrx,0.08,'%3d');
    set(slidetext,'String',['Multiplication factor: ' sprintf('%.2f',expn2)]);
    set(figura,'Pointer','arrow');
    %
    %zoom view preko UIcotextmenu-a
case 'full'
    if ~exist('image_show')
      h=msgbox('Function image_show.m not on the search path! The zoomed image will not be displayed.','Message');   
    else    
    himage=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent')); 
    file=get(get(himage,'Parent'),'UserData');
    siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
    Slika=get(himage,'CData');
    mapusr=get(himage,'UserData');
    
    map=mapusr(2:257,1:3);
    if mapusr(1,1)|mapusr(1,2) map=mapx(map,mapusr(1,1),mapusr(1,2));end;
    set(0,'Units','pixels');
    scrsz = get(0,'ScreenSize');
    set(0,'Units','normalized');
    ratio = round(0.8*min(scrsz(3:4)))/size(Slika,1);
    
    image_show(Slika,map,ratio,['Zoom View - ' file]);   
    end;
    %
    %zaduzeno za sejvanje slike preko UIcotextmenu-a
case 'save'
    slika=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent'));  
    [file,path]=uiputfile('*.bmp','Save picture');
    if file==0 return;end;
    filep=strcat(path,file);
    [path,name,ext]=fileparts(filep);
    if ~strcmp(ext,'.bmp') ext='.bmp';end;   
    A=get(slika,'CData');
    usrmapa=get(slika,'UserData');
    staramapa=usrmapa(2:257,1:3);
    map=mapx(staramapa,usrmapa(1,1),usrmapa(1,2));
    imwrite(A,map,[path '\' name ext],'bmp');
    %
    %zaduzeno za sejvanje slike preko UIcotextmenu-a
case 'savegraph'
    %slika=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent'));  
    [file,path]=uiputfile('*.bmp','Save as image');
    if file==0 return;end;
    filep=strcat(path,file);
    [path,name,ext]=fileparts(filep);
    if ~strcmp(ext,'.bmp') ext='.bmp';end;   
    filep=[path '\' name ext];
    eval(['print ',filep,' -dbitmap']);
    %
    %spremi kao matricu
case 'save_matrix'
    slika=findobj(gcbf,'UIContextMenu',get(gcbo,'Parent'));  
    whatis=get(get(slika,'Parent'),'UserData');
    odakle='CData';
    switch get(slika,'Tag')
    case 'Slika' 
        ime='A';
    case 'Slikaerr'
        ime='B';
    case 'Slikakoef'
        ime='Y';
        slika=findobj(gcbf,'Tag','Frame2');
        odakle='UserData';
    end;     
    mtrx=get(slika,odakle);
    siz=int2str(get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData'));
    assignin('base',ime,mtrx);
    msgbox([whatis ' assigned to variable ''' ime ''' -> ' siz ' x ' siz ' array of ' class(mtrx)],...
        'Assign to workspace','none'); 
    %
    %mijenja sadrzaj error <-> reconstruction
case 'error_recon'  
    naslov=findobj(figura,'Tag','reconstructed');
    cllbck=findobj(figura,'Callback','dctact error_recon');
    slika=findobj(figura,'Tag','Slikaerr');  
    if ~isempty(slika)
        slikadata=get(slika,'CData');
        razlika=get(naslov,'UserData');
        colormap(gray(256));
        set(slika,'CData',razlika,'UserData',mapuser(gray(256),0,0));
        set(naslov,'UserData',slikadata);
        slikaparent=get(slika,'Parent');
        koo=get(findobj(gcbf,'Tag','kockica'),'UserData');
        mtrx(1:8,1:8)=razlika(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','idct_block_axes'),mtrx,0.065,'%3d');
    end;
    switch get(cllbck,'Label')
    case 'Error image'
        set(cllbck,'Label','Reconstructed image');
        set(naslov,'String','Error Image');
        set(slikaparent,'UserData','Error image');
    case 'Reconstructed image'   
        set(cllbck,'Label','Error image');     
        set(naslov,'String','Reconstructed Image'); 
        set(slikaparent,'UserData','Reconstructed image');
        set(findobj(figura,'Tag','err_text1'),'String','gamma: 0');
        set(findobj(figura,'Tag','err_slider'),'Value',0); 
        set(findobj(figura,'Tag','err_checkbox'),'Value',0);
    end;    
    djeca=findobj(figura,'UserData',4); 
    vidljiva_djeca=findobj(djeca,'Visible','on');
    nevidljiva_djeca=findobj(djeca,'Visible','off');
    set(vidljiva_djeca,'Visible','off');
    set(nevidljiva_djeca,'Visible','on');
    %
    %provjerava da li je mis pritisnut iznad selektiranog blocka (i +-2 okolo blocka) 
case 'moveblock'
    currentPoint=get(gca,'CurrentPoint');
    kockica=findobj(gcbf,'Tag','kockica');
    koord=get(kockica,'UserData'); 
    oldX(1:2)=koord(1,2:3);oldY(1:2)=koord(2,1:2);
    newX=currentPoint(1);
    newY=currentPoint(3);
    if (newX>oldX(1)-2) & (newX<oldX(2)+2) & (newY>oldY(1)-2) & (newY<oldY(2)+2) 
        koord(1,5)=newX-oldX(1);koord(2,5)=newY-oldY(1);  
        set(kockica,'UserData',koord);
        set(gcbf,'WindowButtonMotionFcn','dctact movedalje');
        set(gcbf,'WindowButtonUpFcn','dctact stop');
    end; 
    %
    %mis je pritisnut iznad selektiranog blocka a 'movedalje' kontrolira daljnje ponasanje
case 'movedalje'
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
            namjesti_tekst(koord);
        end;
    end; 
    %
    %ako mis stane ispisi block 
case 'stop'  
    set(figura,'WindowButtonMotionFcn','');
    set(figura,'WindowButtonUpFcn','');
    kockica=findobj(gcbf,'Tag','kockica');
    koo=get(kockica,'UserData');
    A=get(findobj(figura,'Tag','Slika'),'CData');
    mtrx(1:8,1:8)=A(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
    show_values(findobj(figura,'Tag','Axes3'),mtrx,0.065,'%3d');
    if strcmp(get(findobj(figura,'UserData',3),'Enable'),'on')
        Y=get(findobj(figura,'Tag','Frame2'),'UserData');
        dmtrx=Y(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','dctaxes'),dmtrx,0.09,'%4.1f');
    end; 
    if strcmp(get(findobj(figura,'UserData',4),'Enable'),'on')
        B=get(findobj(figura,'Tag','Slikaerr'),'CData');
        mtrx(1:8,1:8)=B(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','idct_block_axes'),mtrx,0.065,'%3d');
    end;
    if strcmp(get(findobj(figura,'UserData',3.5),'Enable'),'on')
        qZ=get(findobj(figura,'Tag','quant_Frame'),'UserData');
        qmtrx(1:8,1:8)=qZ(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
        show_values(findobj(figura,'Tag','quantised_axes'),qmtrx,0.08,'%3d');
    end;
    set(findobj(figura,'Tag','code_list'),'String','');
    %
    %
case 'set_rec_button'
    if gcbo==findobj(figura,'Tag','PopupMenu1')
        reset_gamma(figura);
        reset_treshold(figura);
        reset_reconstruct(figura);
        reset_quant(figura);
        reset_code(figura);
    end;
    pushbutt=findobj(figura,'Tag','Pushbutton2');
    block=2^(1+get(findobj(figura,'Tag','PopupMenu1'),'Value'));
    if (block==8)
        jenije=get(findobj(figura,'Tag','quant_check'),'Value');
        if jenije naslov='Quantisation >>'; else naslov='Reconstruction >>';end;
        set(pushbutt,'String',naslov);
    else
        naslov=get(pushbutt,'String');
        if strcmp(naslov,'Quantisation >>') 
            naslov='Reconstruction >>';    
            set(pushbutt,'String',naslov);
        end;  
    end;
case 'load_defaults'    
    %
    %sejva se : save 'imedat.txt' imevar -ascii
    cdnow=fileparts(which('dctlab.m'));
    figura=gcf;
    fid=fopen([cdnow '\DCTlabDefaults.txt']);
    for i=1:3
        rijec=fscanf(fid,'%s/n');
        [token,rem]=strtok(rijec,'=');
        rem=strrep(rem,'=','');
        switch token
        case 'quantization'
            imeq=rem;%'Qdefault.txt';
        case 'zig-zag'
            imez=rem;%'Zdefault.txt';
        case 'Huffman'
            imehuff=rem;%'Hdefault.txt';
        end; 
    end;
    imehuffd=[cdnow '\' imehuff]; 
    imeqd=[cdnow '\' imeq];
    imezd=[cdnow '\' imez];
    fclose(fid);
    set(findobj(figura,'Tag','code_text0'),'String',imehuff);
    fid=fopen(imehuffd);
    dc=fscanf(fid,'%s %d/n');
    for cnt=1:dc(3)
        dcstr=fscanf(fid,'%s/n');  
        [token,rem]=strtok(dcstr,',');
        dccode(cnt).symbol=token;
        [token,rem]=strtok(rem,',');
        dccode(cnt).length=str2num(token);
        dccode(cnt).code=rem;
    end; 
    ac=fscanf(fid,'%s %d/n');
    for cnt=1:ac(3)
        acstr=fscanf(fid,'%s/n');    
        [token,rem]=strtok(acstr,'/');
        accode(cnt).run=hex2dec(token);
        rem=strrep(rem,'/','');
        [token,rem]=strtok(rem,',');
        accode(cnt).ssize=hex2dec(token);
        [token,rem]=strtok(rem,',');
        accode(cnt).length=str2num(token);
        rem=strrep(rem,',','');
        accode(cnt).code=rem;
    end; 
    set(findobj(figura,'Tag','StaticText7'),'UserData',dccode);
    set(findobj(figura,'Tag','Frame5'),'UserData',accode);
    fclose(fid);
    h=msgbox('Huffman table loaded','Message'); 
    drawnow;
    %tic;
    %while toc<1;end;
    delete(h);
    %kvantizacijaska tablica
    qaxes=findobj(figura,'Tag','quant_axes');
    mtrx=load(imeqd,'-ascii');     
    if all(all(mtrx==abs(round(mtrx)))) %stavit jos da ne moze biti 0 !!!!
        qaxes=findobj(figura,'Tag','quant_axes');
        quant_text(mtrx,0.06,'quant',0.01,0.935,[0.5 0.5 0.5],'left');
        set(findobj(figura,'Tag','quant_text1'),'String',imeq);
        poruka='Quantisation table loaded';
        set(qaxes,'UserData',mtrx);
    else poruka='Not a quantisation table!';end; 
    h=msgbox(poruka,'Message'); 
    drawnow;
    %tic;
    %while toc<1;end;
    delete(h);
    %zig-zag tablica
    mtrx=load(imezd,'-ascii');     
    mtrxs=0:63;
    if all(all(mtrxs==sort(mtrx(:)')))
        quant_text(mtrx,0.055,'zig_zag',0.11,0.99,[0 0 0],'right');
        set(findobj(figura,'Tag','quant_text2'),'String',imez);
        poruka='Zig-zag pattern table loaded';
        set(findobj(figura,'Tag','code_Frame'),'UserData',mtrx);
    else poruka='Not a Zig-zag sequence table!';end; 
    h=msgbox(poruka,'Message'); 
    drawnow;
    %tic;
    %while toc<1;end;
    delete(h);
case 'coding'   
    set(figura,'Pointer','watch');
    qZ=get(findobj(figura,'Tag','quant_Frame'),'UserData');
    zigzag=get(findobj(figura,'Tag','code_Frame'),'UserData');
    siz=get(findobj(gcbf,'Tag','Fileuimenu1'),'UserData');
    dccode=get(findobj(figura,'Tag','StaticText7'),'UserData');
    accode=get(findobj(figura,'Tag','Frame5'),'UserData');
    for i = 1:size(accode,2)
        run(i)=getfield(accode,{i},'run');
        ssize(i)=getfield(accode,{i},'ssize');
    end;
    %DC kodiranje
    block=8;
    i=1:block:siz-block+1;j=0:block:siz-block;I=ones(size(i))'*i;J=j'*ones(size(j));
    IJ=(I+siz*J);
    qDZ=qZ(IJ(:));
    diff(1)=qDZ(1);
    qdsize=size(qDZ,1);
    i=2:qdsize;
    diff(i)=qDZ(i)-qDZ(i-1);
    logdiff=ceil(log2(abs(diff')+1));
    dcsize=0;
    for i=1:qdsize
        dcsize=dcsize+dccode(logdiff(i)+1).length+logdiff(i);
    end;
    set(findobj(figura,'Tag','code_text1'),'String',['total DC bits= ' int2str(dcsize)]);
    %AC kodiranje
    zig=zeros(64,2);
    for n=1:64
        [zig(n,1),zig(n,2)]=find(zigzag==n-1);  
    end;
    A=find(run==15);
    ZRL=A(find(ssize(A)==0));%index od zero run length simbola
    A=find(run==0);
    EOB=A(find(ssize(A)==0));%index od end of block simbola
    rowscols = 1:block; 
    [rr,cc] = meshgrid(0:(siz/block-1), 0:(siz/block-1));
    rr = rr(:);cc = cc(:);stream=zeros(length(rr),63);acsize=0;
    for k = 1:length(rr)  
        x=qZ(rr(k)*block+rowscols,cc(k)*block+rowscols);
        for j=2:64
            stream(k,j-1)=x(zig(j,1),zig(j,2));
        end; 
        cnt=0;
        for j=1:63
            if stream(k,j)==0 cnt=cnt+1;  
            else 
                a=cnt;
                b=ceil(log2(abs(stream(k,j))+1));
                while a>=16
                    acsize=acsize+accode(ZRL).length; 
                    a=a-16;
                end;   
                A=find(run==a);
                index=A(find(ssize(A)==b));
                acsize=acsize+accode(index).length+b;
                cnt=0;
            end; 
        end;   
    end;
    acsize=acsize+k*accode(EOB).length;
    CR = 8*siz^2/(acsize+dcsize);
    bpp = 8 / CR;
    set(findobj(figura,'Tag','code_text2'),'String',['total AC bits= ' int2str(acsize)]);
    set(findobj(figura,'Tag','code_text3'),'String',...
        ['bit-rate= ' num2str(bpp,'%.2f') 'bpp (CR=1:' num2str(CR,'%.1f') ')']);
    set(figura,'Pointer','arrow');
    
case 'code_block'  
    qZ=get(findobj(figura,'Tag','quant_Frame'),'UserData');
    koo=get(findobj(figura,'Tag','kockica'),'UserData');
    zigzag=get(findobj(figura,'Tag','code_Frame'),'UserData');
    dccode=get(findobj(figura,'Tag','StaticText7'),'UserData');
    accode=get(findobj(figura,'Tag','Frame5'),'UserData');
    for i = 1:size(accode,2)
        run(i) = getfield(accode,{i},'run');
        ssize(i) = getfield(accode,{i},'ssize');
    end
    A=find(run==15);
    ZRL=A(find(ssize(A)==0));%index od zero run length simbola
    A=find(run==0);
    EOB=A(find(ssize(A)==0));%index od end of block simbola
    x=qZ(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
    zig=zeros(64,2);stream=zeros(63,1);
    for n=1:64
        [zig(n,1),zig(n,2)]=find(zigzag==n-1);  
    end;
    for j=2:64
        stream(j-1)=x(zig(j,1),zig(j,2));
    end; 
    cnt=0;symb='';bits='';
    for j=1:63
        if stream(j)==0 cnt=cnt+1;  
        else 
            a=cnt;
            b=ceil(log2(abs(stream(j))+1));
            while a>=16
                symb=[symb 'F/0,'];  
                bits=[bits accode(ZRL).code];  
                a=a-16;
            end;   
            A=find(run==a);
            index=A(find(ssize(A)==b));
            symb=[symb dec2hex(a) '/' dec2hex(b) ','];
            if stream(j)<0
                stream(j)=stream(j)+2^b-1;
            end;   
            bits=[bits accode(index).code dec2bin(stream(j))];  
            cnt=0;
        end; 
    end;   
    symb=[symb '0/0'];
    bits=[bits accode(EOB).code];  
    sizsymb=size(symb,2);
    sblank='                    ';
    symbout='';
    while sizsymb>20
        symbout=[symbout;symb(1:20)];   
        symb=symb(21:sizsymb);
        sizsymb=sizsymb-20;  
    end;
    sblank(1:sizsymb)=symb(1:sizsymb);
    symbout=[symbout;sblank];
    sblank='                    ';
    symbout=[symbout;sblank];
    sizbits=size(bits,2);
    while sizbits>20
        symbout=[symbout;bits(1:20)];   
        bits=bits(21:sizbits);
        sizbits=sizbits-20;  
    end;
    sblank(1:sizbits)=bits(1:sizbits);
    symbout=[symbout;sblank];
    
    set(findobj(gcbf,'Tag','code_list'),'String',cellstr(symbout));
    %help! 
case 'help'
    h=msgbox('Sorry, the help files are currently not available - to be added/updated!','Message'); 
    %now=fileparts(which('dctlab.m'));
    %dirhelp=strcat(now,'\Help\introduction.htm');  
    %web(['file:/' dirhelp],'-browser'); 
    % 
    %kuci Muarko!  
case 'exit'
    close(gcf);  
end; 
%
%funkcija za manipuliranje mapom
function mapx=mapx(map,gama,invert)
if invert
    s=size(map,1);
    mapa=zeros(s,3);
    for i=1:s
        mapa(i,:)=map(s+1-i,:);
    end;
else mapa=map;
end;
mapx=brighten(mapa,gama);
%
%pravi varijablu u kojoj su podaci kako napravit trenutnu mapu iz originala (map)
function mapuser=mapuser(map,gama,invert)
mapuser(1,1)=gama;
mapuser(1,2)=invert;
mapuser(2:257,1:3)=map;
%
%resetira dio GUI-a za upravljanje mapom
function reset_gamma(figura)
set(findobj(figura,'UserData',3),'Enable','off');
set(findobj(figura,'Tag','StaticText5'),'String','gamma: 0');
set(findobj(figura,'Tag','Slider1'),'Value',0);
set(findobj(figura,'Tag','Checkbox1'),'Value',0);
set(findobj(figura,'Tag','Radiobutton2'),'Value',1);
set(findobj(figura,'Tag','Radiobutton1'),'Value',0);
delete(get(findobj(figura,'Tag','dctaxes'),'Children'));
delete(findobj(findobj(figura,'Tag','Axes2'),'Type','image'));
%
%resetira dio GUI-a za namjestanje praga
function  reset_treshold(figura)
set(findobj(figura,'UserData',3.25),'Enable','off');
set(findobj(figura,'Tag','EditText1'),'String','');
set(findobj(figura,'Tag','StaticText9'),'String','|coeff| in range []');
set(findobj(figura,'Tag','StaticText11'),'String','% coeff==0');
%
%resetira dio GUI-a za rekonstrukciju
function  reset_reconstruct(figura)
set(findobj(figura,'UserData',4),'Enable','off');
set(findobj(figura,'Tag','QM_1'),'String','MSE=');
set(findobj(figura,'Tag','QM_2'),'String','PSNR=');
set(findobj(figura,'Tag','QM_3'),'String','AD=');
set(findobj(figura,'Tag','QM_4'),'String','MD=');
set(findobj(figura,'Tag','QM_5'),'String','LMSE=');
set(findobj(figura,'Tag','QM_6'),'String','NAE=');
delete(get(findobj(figura,'Tag','idct_block_axes'),'Children'));
naslov=findobj(figura,'Tag','reconstructed');
if strcmp(get(naslov,'String'),'Error Image') dctact('error_recon');end;
delete(findobj(findobj(figura,'Tag','error_axes'),'Type','image'));
%
%resetira dio GUI-a za kvantizaciju
function  reset_quant(figura)
set(findobj(figura,'UserData',3.5),'Enable','off');
set(findobj(figura,'Tag','quant_text3'),'String','Multiplication factor: 1');
set(findobj(figura,'Tag','quant_slider'),'Value',0);
delete(get(findobj(figura,'Tag','quantised_axes'),'Children'));
%
%resetira dio GUI-a za kodiranje
function  reset_code(figura)
set(findobj(figura,'Tag','code_text1'),'String','total DC bits=');
set(findobj(figura,'Tag','code_text2'),'String','total AC bits=');
set(findobj(figura,'Tag','code_text3'),'String','bit-rate=');
set(findobj(figura,'Tag','code_list'),'String','');
%   
%prikazuje sadrzaj selektiranog blocka u pripadne osi format-(dctcoeff=%4.1f,orig=%3d) 
function show_values(axes,mtrx,font,format)
set(gcbf,'CurrentAxes',axes);cla;
korak=0.125;pocx=0.0625;pocy=0.9375;
if strcmp(format,'%4.1f')
    Y=get(findobj(gcbf,'Tag','Frame2'),'UserData');
    strtres=get(findobj(gcbf,'Tag','EditText1'),'String');
    if isempty(strtres) tres=0; else tres=str2num(strtres);end;
else tres=0;end; 
for i=1:8
    for j=1:8
        num=double(mtrx(i,j));    
        text(pocx,pocy,num2str(num,format),'Units','normalized','HorizontalAlignment','center',...
            'FontUnits','normalized','FontSize',font,'Color',[0.7 0.7 0.7]*(abs(num)<tres));
        pocx=pocx+korak;
    end;
    pocy=pocy-korak;
    pocx=0.0625;
end;
set(axes,'UserData',mtrx);
%   
%specijalna funkcija za prikaz quant blocka i zig-zag sekvence 
function quant_text(mtrx,font,nacin,pocx,pocy,boja,halig)
figura=gcbf; 
axes=findobj(figura,'Tag','quant_axes');
set(figura,'CurrentAxes',axes);
delete(findobj(axes,'Tag',nacin));
xswp=pocx;koraky=0.123;korakx=0.125;
for i=1:8
    for j=1:8
        num=double(mtrx(i,j));    
        text(pocx,pocy,num2str(num,'%3d'),'Units','normalized','HorizontalAlignment',halig,...
            'FontUnits','normalized','FontSize',font,'Color',boja,'Tag',nacin,'VerticalAlignment','Top');
        pocx=pocx+korakx;
    end;
    pocy=pocy-koraky;
    pocx=xswp;
end;
%
%prikazuje koordinate selektiranog blocka
function namjesti_tekst(Ud)
txtbx=findobj(gcbf,'Tag','StaticText7');
n2st=sprintf(' %d,%d,%d,%d',Ud(1,1)+1,Ud(2,1)+1,Ud(1,3)-1,Ud(2,2)-1);
set(txtbx,'String',['(xy1,xy2)=' n2st]); 
function show_dct_block(figura)
koo=get(findobj(figura,'Tag','kockica'),'UserData');
Y=get(findobj(figura,'Tag','Frame2'),'UserData');
dmtrx=Y(koo(2,1)+1:koo(2,2)-1,koo(1,1)+1:koo(1,3)-1);
show_values(findobj(figura,'Tag','dctaxes'),dmtrx,0.09,'%4.1f'); 
%
%get file via browse window
function [file,A,map,siz]=get_file()
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
            elseif (strcmp(info.ColorType,'grayscale')) 
                map=gray(256);
                bitmap=1;
            else 
                if ~all(all(map==gray(size(map,1))))
                    if ~(all(map(:,1)==map(:,2)) & all(map(:,1)==map(:,3)))
                        warndlg('Converting to grayscale!','Warning!'); 
                        uiwait;   
                    end;    
                    %A=round(255.*ind2gray(A,map));
                    
                    map=gray(256);
                end;   
                bitmap=1;    
            end;
        end;
    end;
end; 
function [SFM,Y]=activity(Y)
siz=size(Y,1);
siz=siz*siz;
S=sum(sum(double(Y).^2))/siz; 
Y=fft2(double(Y)); 
Z=abs(Y);
assignin('base','Z',Z);
P=geomean(Z(:).^2)/65536;
%Pp=Z.^(1/siz);
%P=prod(prod(Pp));
%S=sum(sum(Z))/siz;
SFM=num2str(P/S);
%
%napravi od 2dim 1dim analizu
function [Z,sz,maxY]=flatfreq(Zx)
Zx(:,1)=Zx(:,1)/sqrt(2);
Zx(1,:)=Zx(1,:)/sqrt(2); 
block=size(Zx,1);
bk=block*block;
i=0:block-1;
j=i.^2;
B=repmat(j,block,1);
U=B+B';
pom3(:,1)=sqrt(U(:));
pom3(:,2)=Zx(:);
pom3=sortrows(pom3,1);
k=1;zbroj=0;cnt=0;
udaljenost=1;razmak=1;
koji=1;
for k=1:bk
    if pom3(k,1)<udaljenost  
        zbroj=zbroj+pom3(k,2);
        cnt=cnt+1;
    else 
        pom3(koji,1)=udaljenost;
        if zbroj==0 pom3(koji,2)=-10; 
        else pom3(koji,2)=log2(zbroj/cnt); %srednja aritmetricka vrijednost svih amplituda u intervalu
        end;   
        udaljenost=udaljenost+razmak;
        zbroj=pom3(k,2); 
        koji=koji+1;
        cnt=1;
    end; 
end; 
if cnt>1
    pom3(koji,1)=udaljenost;
    if zbroj==0 pom3(koji,2)=-10; 
    else pom3(koji,2)=log2(zbroj/cnt);
    end;   
    koji=koji+1;
end; 
Z(:,1)=pom3(1:koji-1,1)/2;
Z(:,2)=pom3(1:koji-1,2);
sz=size(Z,1);
maxY=log2(block)+4;
if max(Z(2:sz,2))>maxY maxY=max(Z(2:sz,2))+1;end;   

function [Z,sz,maxY]=flatfreq2(Y,preciznost,refine)
%Y - matrica sa DFT koeficijentimazbog jednostavnosti pretpostavlja 
%     se da je oblika 2^n x 2^n  
%refine - stupanj poveæanja rezolucije (potencije broja 2: 1,2,4,8...)
%preciznosti - korak poveæanja udaljenosti (delta t)
origsiz=size(Y,1)/2;
bk=origsiz^2;
Y=abs(Y).^2./(4*bk);   
%poveæanje rezolucije
Y=Y./(refine^2);  
Ysize=refine*size(Y,1);
Yr=zeros(Ysize);
for i=1:refine
    for j=1:refine
        Yr(i:refine:Ysize,j:refine:Ysize)=Y(:,:);
    end;
end;
Y=Yr;
siz=size(Y,1)/2;
Zx=zeros(siz+refine);
%preklapanje kvadranata
Zx=Y(1:siz+refine,1:siz+refine);
Zx(1+refine:siz+refine,1+refine:siz+refine)=Zx(1+refine:siz+refine,...
    1+refine:siz+refine)+Y(2*siz:-1:siz+1,2*siz:-1:siz+1);
Zx(1+refine:siz+refine,1:siz+refine)=Zx(1+refine:siz+refine,1:siz+refine)+...
    Y(2*siz:-1:siz+1,1:siz+refine);
Zx(1:siz+refine,1+refine:siz+refine)=Zx(1:siz+refine,1+refine:siz+refine)+...
    Y(1:siz+refine,2*siz:-1:siz+1);
%definiranje i sortiranje matrice s udaljenostima i koeficijentima
siz=size(Zx,1);
i=-1/2+1/(2*refine):1/refine:origsiz+1;i=i(1:siz);
j=i.^2;
B=repmat(j,siz,1);
U=B+B';
pom3(:,1)=sqrt(U(:));
pom3(:,2)=Zx(:);
pom3=sortrows(pom3,1);
k=1;zbroj=0;cnt=0;
opseg=preciznost;
koji=1;
%petlja zbrajanja koeficijenata u kru?nim vijencima
for k=1:siz^2
    if pom3(k,1)<opseg  
        zbroj=zbroj+pom3(k,2);
        cnt=cnt+1;
    else 
        pom3(koji,1)=opseg;
        if zbroj==0 
            pom3(koji,2)=-10; 
        else 
            povrsina=(2*opseg-preciznost)*preciznost*pi; 
            pom3(koji,2)=log10(zbroj/povrsina); 
        end;   
        opseg=opseg+preciznost;
        zbroj=pom3(k,2); 
        koji=koji+1;
        cnt=1;
    end; 
end; 
if cnt>1
    pom3(koji,1)=opseg;
    if zbroj==0 pom3(koji,2)=-10; 
    else pom3(koji,2)=log10(zbroj/povrsina);
    end;   
    koji=koji+1; 
end; 
Z(:,1)=pom3(1:koji-1,1)/2;
Z(:,2)=pom3(1:koji-1,2);
maxY=max(Z(1:koji-1,2))+1;
sz=koji-1;

function b = blkprocnik(aa, block, fun)
% A faster option will be selected, according to the parameter T
% aa - input matrix
% block - block size
% fun - 'dct' or 'idct'

%Blocks of this size and larger will be process with fft based dct
T = 64; 
%Note that this value is empirical, on some machines it may be different

if block >= T %use fft based dct
    if strcmp(fun,'dct')
        b = blkdct2fft(aa,block);
    elseif strcmp(fun,'idct')
        b = blkidct2fft(aa,block);
    end;
else
    if strcmp(fun,'dct')
        b = blkdct2cos(aa,block);
    elseif strcmp(fun,'idct')
        b = blkidct2cos(aa,block);
    end;
end;