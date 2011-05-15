function [PSNR_RD8,MSE_RD8]=RDcurveBytePrec(imagename,totalmaxbits)
header_size=51;
wavelet='CDF_9x7';
no_decomp=7;
start_size=8;
end_size=ceil(totalmaxbits/8)*8;
iminfo=imfinfo(imagename);
imsize=prod(iminfo.Width*iminfo.Height);
bpps=(start_size:8:end_size)'/imsize;
[Arec,bitstream,PSNR_RD8,MSE_RD8]=spiht_wpackets(imagename,bpps,wavelet,no_decomp);
[pathstr,filename] = fileparts(imagename);
save(['.\RD_curve\' filename 'RD'],'PSNR_RD8','MSE_RD8');