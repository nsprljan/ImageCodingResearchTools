Zerotree Coding Toolbox
=======================

Image compression based on wavelets, using zerotrees of wavelet coefficients. Uses [Wavelet](https://github.com/nsprljan/Matlab/tree/master/Wavelet) and [Quality Assessment](https://github.com/nsprljan/Matlab/tree/master/QualityAssessment) toolboxes. The SPIHT binaries required for function spspiht.m can be downloaded from the SPIHT image compression homepage, see below. 


Functions
---------

 - **dead\_zone\_q** - Quantisation with a central dead-zone around zero
 - **ezw** - EZW (Embedded Zerotree Wavelet) image compression
 - **pdf_opt** - Optimisation (pdf) of reconstructed values of quantised wavelet coefficients 
 - **spiht\_stream\_dec** - Performs decoding of the bitstream produced by spiht_wpackets.m 	 	 
 - **spiht_wpackets** - SPIHT image compression using Wavelet Packets (WP) decomposition
 - **spspiht** - Script for batch execution of DOS SPIHT binaries 

DOS SPIHT binaries required for function spspiht.m can be found at [SPIHT image compression homepage](http://www.cipr.rpi.edu/research/SPIHT/spiht3.html). Here's [direct link](http://www.cipr.rpi.edu/research/SPIHT/EW_Code/SPIHT.zip) to the package. 
 
 
Examples
--------
SPIHT algorithm flow-chart:

  ![SPIHT algorithm flow-chart](https://github.com/nsprljan/Matlab/raw/master/ZerotreeCoding/SPIHT_flowchart.png)	
  
**spiht_wpackets** with dyadic DWT, as in the original SPIHT:  

    >> [Arec,bitstream,PSNR]=spiht_wpackets('Lena512.png',[0.1 1],'CDF_9x7',6);
    6 decompositions, 0 packet depth, CDF_9x7 wavelet, highest bitrate 1.000000 bpp
    Image transformed in 0.85 seconds
    Maximum magnitudes computed in 0.24 seconds

    SPIHT algorithm...

    1. bitrate - 0.099995 bpp
    No. output bits - 26216(3277 bytes; 3 excess bits)-> 0.100006 bpp
    MSE (Mean Squared Error) = 68.231052
    PSNR (Peak Signal / Noise Ratio) = 29.790983 dB

    2. bitrate - 0.999996 bpp
    No. output bits - 262144(32768 bytes; 1 excess bits)-> 1.000000 bpp
    MSE (Mean Squared Error) = 6.535866
    PSNR (Peak Signal / Noise Ratio) = 39.977772 dB

    ...LIS (checking children) loop out - completed in 8.91 seconds

Statistics collected during encoding in **SPIHTlog.txt**, where 'bpc' stands for 'bits per significant coefficient':

                        LIP loop                LIS loop              Total significant
     pass(start bit)   bits/coeffs.            bits/coeffs.              coeffs.(LSP start bit)
     1.(      52)       65/1     =65.00 bpc     64/0     =  Inf bpc           1(     181)
     2.(     181)       81/18    = 4.50 bpc     89/5     =17.80 bpc          24(     351)
     3.(     352)       67/12    = 5.58 bpc    246/32    = 7.69 bpc          68(     665)
     4.(     689)      150/39    = 3.85 bpc    749/111   = 6.75 bpc         218(    1588)
     5.(    1656)      362/80    = 4.53 bpc   1650/235   = 7.02 bpc         533(    3668)
     6.(    3886)      927/237   = 3.91 bpc   4549/624   = 7.29 bpc        1394(    9362)
     7.(    9895)     2512/621   = 4.05 bpc   9202/1334  = 6.90 bpc        3349(   21609)
     8.(   23003)     5424/1489  = 3.64 bpc  17931/2677  = 6.70 bpc        7515(   46358)
     9.(   49707)    10719/2998  = 3.58 bpc  33035/5101  = 6.48 bpc       15614(   93461)
    10.(  100976)    20709/5739  = 3.61 bpc  68089/10551 = 6.45 bpc       31904(  189774)
    11.(  205388)    45154/12562 = 3.59 bpc  11602/2519  = 4.61 bpc       46985(       0)
    Total:
                    147206/23189 = 3.62 bpc  86170/23189 = 6.35 bpc       46985

The following example uses functions from Wavelet and Quality Assessment Toolboxes. It demonstrates that using the pdf-optimised reconstruction of quantised wavelet coefficients a meagre improvement of ~0.02 dB can be expected on high bit-rates. Functions used are **dead_zone_q** and **pdf_opt**:

    >> D=dwt_dyadic_decomp('Lena256.png','CDF_9x7',6);
    >> qstep = 4; %quantisation step is 4
    >> Dq = dead_zone_q(D,qstep); 
    >> Dq_opt = pdf_opt(Dq,qstep);
    >> iq_measures(idwt_dyadic_recon(Dq,'CDF_9x7',6),'Lena256.png',1,1); 
    MSE (Mean Squared Error)= 2.556086
    PSNR (Peak SNR)= 44.055048 dB
    >> iq_measures(idwt_dyadic_recon(Dq_opt,'CDF_9x7',6),'Lena256.png','disp');
    MSE (Mean Squared Error)= 2.544909
    PSNR (Peak SNR)= 44.074081 dB

DOS SPIHT binaries using function **spspiht**:
   
    >> [Arec,bitstream,PSNR]=spspiht('Lena512.png',[0.1 1],'fast');
    Number of bits = 262160(32770 bytes, 1.0001 bpp)
    
    1. bitrate - 0.1000 bpp
    MSE (Mean Squared Error)= 67.644821
    PSNR (Peak SNR)= 29.828458 dB
    
    2. bitrate - 1.0000 bpp
    MSE (Mean Squared Error)= 6.532291
    PSNR (Peak SNR)= 39.980148 dB
    
    Total execution time - 0.84 seconds
    
EZW (Embedded Zerotree Wavelet) algorithm with function **ezw**:
    
    >> ezw('ezw_testdata1.mat',2,2,'CDF_9x7');
    Image ezw_testdata1.mat, 2 decompositions, CDF9_7 wavelet, bitrate 2.000000 bpp
    
    Example matrix:
        55    42    24   -28     6    16     0     3     1     8     1     8
        31    48    22    29     2     6     0     2    -8     2    -8     2
        25   -21    26    20     6    18     2     7    -9     4    -9     4
         1     0    29    18    16    10     5     3     1     2     1     2
        17     2     7   -16     6     3    -4     6     1     0     7     0
        13    -9    16    15     1     7     7     9     7     0     7     0
       -18     0     1     2     6    -3     5     5    -7     8    -7     8
        10     2     0     8    -1     9     5     9     6     3     6     3

    1. pass
    p z z z z z t t t t t t t t t t t t t t t t t t 
    1
    2. pass
    z p z z z z t t t t t t p t t t t t t t t t t t t t t t 
    100
    3. pass
    z z z z p z z t t z t t z n t z t t p t t t t t n p p t t p t t t n t t t t t t t t
    EZW algorithm executed in 0.047000 seconds

    Number of output bits: 192
    MSE (Mean Squared Error)= 60.529236
    PSNR (Peak SNR)= 30.311152 dB
