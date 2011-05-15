Joint Source-Channel Coding of Images Toolbox
=============================================

Simulation of transmission of SPIHT encoded images over unreliable channels, for instance wireless or packet-erasure channels. Requires the MATLAB Communications Toolbox. Note that some functions are undocumented.

Functions
---------

 - **awgn_EsN0** - Simulation of the Additive White Gaussian Noise (AWGN) channel
 - **BSC_BER** - Simulation of the Binary Symemtric Channel (BSC)
 - **GE_awgn** - Simulation of the Gilbert-Elliot (GE) channel, using two AWGN channels
 - **get_channel** - Loads a predefined channel (saved in a txt file)
 - **get\_RCPC\_code** - Loads a predefined RCPC code from a default code family ('Punct_codes.txt')
 - **RCPC_encode** - Rate Compatible Punctured Convolutional (RCPC) coding of the binary stream
 - **RCPC\_test\_equal_data** - Transmission of packets with constant data part, using RCPC
 - **RCPC\_test\_equal_packet** - Transmission of packets with constant size, using RCPC
 - **optimal\_RCPC_equal** - Computes the Equal Error Protection (EEP) scheme for a given image and channel
 - **send\_image_equal** - Transmission of SPIHT encoded image using EEP
 - **send\_image\_equal_RS** - Transmission of SPIHT encoded image using EEP and Reed-Solomon protection
 - **optimal\_RCPC_unequal** - Computes the Unequal Error Protection (UEP) scheme for a given image and channel
 - **send\_image_unequal** - Transmission of SPIHT encoded image using UEP 

Some scripts measure the channel error rate, RCPC code characteristics and Rate-Distortion (R-D) curve of the SPIHT compression on the particular image:

 - **script\_channel_performance** - Measures the BER and PER values for RCPC transmission on a given channel
 - **RDcurveBytePrec** - Runs SPIHT over range of target bitrates and stores the R-D curve 
  
Examples
--------
**get_channel** (contents of the file `AWGN1.txt`):
    
    ch_handle=@awgn_EsN0;
    parametar.EsN0=-0.8556;
    parametar.state=-1;
    parametar.Bch=128000;
    parametar.Nch=256;
  
  
**get\_RCPC_code** (one RCPC entry from the file `Punct_codes.txt`):
    
    8/9
    [Hag88]
    Memory=6
    CodeGenerator=[133 171 145]
    PunctCode=f78800
    cd=[0,0,24,740,13321,217761,3315491,48278177]
    %Punctcode=[f7,88,00]=[1 1 1 1 0 1 1 1,1 0 0 0 1 0 0 0,0 0 0 0 0 0 0 0]


**RCPC_encode**:

    >> signal=round(rand(1,8))
     signal =
          0     1     1     0     0     0     1     0
    >> [Memory,Ib,Kb,t,PN,P,TotRate,PunctInd] = get_RCPC_code('8/9');
    >> outsignal = RCPC_encode(signal,Memory,t,P,PunctInd)
     outsignal =
          1     1    -1    -1    -1     1    -1     1     1

**RCPC\_test\_equal_data**:
      
    >> [diffvec,BER,PER]=RCPC_test_equal_data(100,128,'AWGN1','1/2',8,0);
     Mother code rate: 1/3
     Puncturing code rate: 16/24
     Total rate: 1/2
     Packet size: 284
     Number of packets: 100
     Transmitted data bits: 12800
    
     ***Errors Statistics***
     Errors = 52
     BER = 0.004063
     Packet errors = 12
     PER = 0.120000
     (CRC) Correctly detected packet errors = 12
     (CRC) Detected packet errors = 12
 
**script\_channel_performance**:

    >> script_channel_performance(@RCPC_test_equal_packet,100000,16,'GE1');   

![RCPC codes epsilon characteristic](https://github.com/nsprljan/Matlab/raw/master/JSCCImage/RCPC_ch_epsilon.png)	

![RCPC codes ro characteristic](https://github.com/nsprljan/Matlab/raw/master/JSCCImage/RCPC_ch_ro.png)	

**optimal\_RCPC_equal**:

    >> optimal_RCPC_equal(1000,16,'GE1','Lena512RD','draw_small');
    RCPC total rate: 1/1 - average PSNR: 17.281731
    RCPC total rate: 8/9 - average PSNR: 18.406105
    RCPC total rate: 4/5 - average PSNR: 18.432578
    RCPC total rate: 2/3 - average PSNR: 19.129653
    RCPC total rate: 4/7 - average PSNR: 21.051831
    RCPC total rate: 1/2 - average PSNR: 24.052347
    RCPC total rate: 4/9 - average PSNR: 26.976499
    RCPC total rate: 2/5 - average PSNR: 29.522427
    RCPC total rate: 4/11 - average PSNR: 30.491567
    RCPC total rate: 1/3 - average PSNR: 30.432119
    ***
    Minimal distortion RCPC code: 4/11
    PSNR: 30.491567

![RCPC plots for AWGN1 and EEP](https://github.com/nsprljan/Matlab/raw/master/JSCCImage/AWGN1_RCPC.png)	

