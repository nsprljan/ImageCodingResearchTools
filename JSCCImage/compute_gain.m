function g=compute_gain(imgname,PSNRinp,chnlname,gain)

[ch_handle,parametar]=get_channel(chnlname);
EsN0inp=parametar.EsN0+gain;
[pathstr,filename]=fileparts(imgname);
%..uncodedPSNR_....mat file contains variable PSNRmean

if findstr('AWGN',chnlname)
 load([filename 'uncodedPSNR_AWGN'],'PSNRmean');
else
 load([filename 'uncodedPSNR_' chnlname],'PSNRmean'); 
end;
PSNR=PSNRmean(1,:);
EN=PSNRmean(2,:);
if PSNRinp==PSNR(1) %no gain is achieved
    g=0;
else
    Ind=find(PSNR>PSNRinp);
    PSNRup=PSNR(Ind(1));
    ENup=EN(Ind(1));
    PSNRdn=PSNR(Ind(1)-1);
    ENdn=EN(Ind(1)-1);
    EsN0unc=ENdn+(ENup-ENdn)*(PSNRinp-PSNRdn)/(PSNRup-PSNRdn);
    g=EsN0unc-EsN0inp;
end;