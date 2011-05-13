JPEG2000 Toolbox
================

A GUI front-end for executing the external JPEG2000 software (the java-based, not included in this package). Apart form the GUI, the script jpeg2000jj2k.m can be used for calling JJ2000 in the command line mode. The scripts for batch execution of the [JPEG 2000 Kakadu software](http://www.kakadusoftware.com/) are also provided (not included in this package). The only implementation of JJ2000 that currently can be found on the web is at [this link](http://anabuilder.free.fr/jj2000-5.1.jar). However, keep in mind this is not the original location, as the authors' location for dowload is not online any more ([original location](http://jj2000.epfl.ch/jj_download/index.html))

Functions
---------

 - **jpeg2000gui** - GUI for Jpeg 2000 compression, calls jpeg2000jj2k
 - **jpeg2000jj2k** - Script that executes the JJ2000 java byte code (place the corresponding jar file in this toolbox directory)
 - **jpeg2000kakadu** - Frontend for the Kakadu JPEG 2000 compression (place the corresponding binaries under ./kakadu directory)
 - **jpeg2000kakadu_yuv** - Frontend for the Kakadu JPEG 2000 compression of video sequences in YUV format 
 
Examples
--------
Kakadu JPEG 2000 compression at 5 bit-rates with **jpeg2000kakadu**:

    >> [Arec,PSNR,bpp_out] = jpeg2000kakadu('Lena512.png',4,0.25:0.25:1.25,1,'parse',1);
    1. bitrate 0.253357 bpp (0.253357 bpp):
    MSE (Mean Squared Error) = 85.891251
    PSNR (Peak Signal / Noise Ratio) = 28.791314 dB
    2. bitrate 0.503357 bpp (0.503357 bpp):
    MSE (Mean Squared Error) = 49.897293
    PSNR (Peak Signal / Noise Ratio) = 31.150034 dB
    3. bitrate 0.753357 bpp (0.753357 bpp):
    MSE (Mean Squared Error) = 19.818527
    PSNR (Peak Signal / Noise Ratio) = 35.160090 dB
    4. bitrate 1.003357 bpp (1.003387 bpp):
    MSE (Mean Squared Error) = 9.743835
    PSNR (Peak Signal / Noise Ratio) = 38.243504 dB
    5. bitrate 1.253357 bpp (1.253387 bpp):
    MSE (Mean Squared Error) = 0.636932
    PSNR (Peak Signal / Noise Ratio) = 50.089870 dB
  
Compressing a raw (uncompressed) video with **jpeg2000kakadu\_yuv**:
  
    >> PSNR=jpeg2000kakadu_yuv('RaceHorses_416x240_30.yuv',[416 240],30,[1024 2048],5);
    Processing frame 1
    . Rate = 0.34228 bpp, PSNR_Y = 28.69, PSNR_U = 32.49, PSNR_V = 32.54
    . Rate = 0.68416 bpp, PSNR_Y = 32.19, PSNR_U = 35.29, PSNR_V = 35.40
    Processing frame 2
    . Rate = 0.34228 bpp, PSNR_Y = 28.87, PSNR_U = 32.39, PSNR_V = 33.00
    . Rate = 0.68416 bpp, PSNR_Y = 32.39, PSNR_U = 35.30, PSNR_V = 35.58
    Processing frame 3
    . Rate = 0.34228 bpp, PSNR_Y = 28.99, PSNR_U = 33.13, PSNR_V = 32.57
    . Rate = 0.68416 bpp, PSNR_Y = 32.55, PSNR_U = 35.22, PSNR_V = 35.65
    Processing frame 4
    . Rate = 0.34228 bpp, PSNR_Y = 29.22, PSNR_U = 33.04, PSNR_V = 32.96
    . Rate = 0.68416 bpp, PSNR_Y = 32.69, PSNR_U = 35.79, PSNR_V = 35.87
    Processing frame 5
    . Rate = 0.34228 bpp, PSNR_Y = 29.25, PSNR_U = 33.30, PSNR_V = 32.93
    . Rate = 0.68416 bpp, PSNR_Y = 32.73, PSNR_U = 35.68, PSNR_V = 35.67

Wrapper for JJ2000 java implementation of JPEG2000, **jpeg2000jj2k**:   

    >> [Arec,PSNR]=jpeg2000('Lena256.png',[0.1 0.5 1],1);
        Target bitrate = 1.0 bpp (i.e. 8192 bytes)
        Achieved bitrate = 0.9766846 bpp (i.e. 8001 bytes)
    [INFO]: 1 component(s) in codestream, 1 tile(s)
            Image dimension: 256x256
            Target rate = 0.1 bpp (819 bytes)
            Actual bitrate = 0.095214844 bpp (i.e. 780 bytes)
    [INFO]: 1 component(s) in codestream, 1 tile(s)
            Image dimension: 256x256
            Target rate = 0.5 bpp (4096 bytes)
            Actual bitrate = 0.4984131 bpp (i.e. 4083 bytes)
    [INFO]: 1 component(s) in codestream, 1 tile(s)
            Image dimension: 256x256
            Target rate = 1.0 bpp (8192 bytes)
            Actual bitrate = 0.9766846 bpp (i.e. 8001 bytes)
    >> image_show(Arec{1},256,1,'');
    >> image_show(Arec{2},256,1,'');
    >> image_show(Arec{3},256,1,'');
   
Screenshot of **jpeg2000gui**:

  ![jpeg2000gui screenshot](https://github.com/nsprljan/Matlab/raw/master/Jpeg2000/Jpeg2000gui.png)	  