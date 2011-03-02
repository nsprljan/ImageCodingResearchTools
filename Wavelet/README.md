MATLAB Wavelet Toolbox
======================

Wavelet transform related functions specifically designed to be used as a tool for image/video compression. The core of the toolbox consists of one-dimensional (1D) wavelet analysis and synthesis functions. The separable decomposition of multidimensional signals is supported, building on the 1D analysis and synthesis functions. The special case of the 2D signal is given with separate functions, with option to perform either dyadic or wavelet packets decomposition. Several functions are dedicated to the computation of wavelet filter properties and their visualisation.

- - -

Functions
---------
General:

 - **bibo_gains** - Computes BIBO(Bounded Input Bounded Output) gains of a wavelet
 - **scaling_fun** - Computes (and plots) samples of the scale function
 - **wavelet_fun** - Computes (and plots) samples of the wavelet function
 - **wavelet2D** - Computes (and draws) a 2D wavelet, tensor product of 1D wavelets 
 - **load_wavelet** - Loads definition and properties of a wavelet filter
 - **subband** - Selects a subband from a 2D wavelet coefficients array
 - **wavelet_char** - Computes (and plots) frequency and phase charateristic of a wavelet
 - **wavelet_check** - Lists properties of a wavelet and performs several tests
 - **wavelet_downscale** - Image resizing performed by wavelet decomposition
 - **filt2lift** - Computes lifting coefficients from the wavelet as FIR filter

1D DWT:

 - **dwt_lifting1D** - DWT of a 1D signal in lifting implementation
 - **idwt_lifting1D** - IDWT of a 1D signal in lifting implementation
 - **dwt_conv1D** - DWT of a 1D signal in convolution implementation
 - **idwt_conv1D** - IDWT of a 1D signal in convolution implementation

2D DWT:

 - **dwt_2D** - Two-dimensional separable DWT
 - **idwt_2D** - Two-dimensional separable IDWT
 - **decomp_packets2D** - 2D wavelet packets decomposition with entropy-based subband splitting
 - **recon_packets2D** - 2D wavelet packets reconstruction
 - **draw_packets** - Visualises the wavelet packets decomposition 

Multidimensional DWT:

 - **submatrix** - Extracts submatrix from a multidimensional matrix
 - **subband_dim** - Computes the subband dimensions for a specified number of decompositions
 - **dwt_dim** - DWT in specific dimension of multidimensional matrix
 - **idwt_dim** - DWT in specific dimension of multidimensional matrix
 - **dwt_dyadic_decomp** - Dyadic wavelet decomposition of a multidimensional signal
 - **idwt_dyadic_recon** - Dyadic wavelet reconstruction of a multidimensional signal

  
Examples
--------
Wavelet definition - Le Gall 5/3, defined in file **LeGall_5x3.wvf**:

	%wvf_type
	 SYMMETRIC_ODD
	%lift_coeff
	-0.5,-0.5
	 0.25,0.25
	%lift_norm
	 1.41421356237310
	 0.70710678118655
	%filt_H0 - symmetric
	-2,-0.17677669529664
	-1, 0.35355339059327
	 0, 1.06066017177982
	 1, 0.35355339059327
	 2,-0.17677669529664
	%filt_H1 - symmetric
	 0,-0.35355339059327
	 1, 0.70710678118655
	 2,-0.35355339059327
	%filt_G0 - can be deduced from filt_H1
	%filt_G1 - can be deduced from filt_H0

### BIBO ###
Bounded Input Bounded Output) gains of a wavelet, with **bibo\_gains**:

    >> bibo_gains('CDF_9x7',3);
    Low-pass filter (H0) BIBO gains (cumulative)= 1.95(1.95) 2.67(1.37) 3.70(1.39) 
    High-pass filter (H1) BIBO gains (cumulative)= 1.84(1.84) 2.63(1.43) 3.61(1.37) 

### Wavelet characteristics ###
Analysis and synthesis filter taps, orthogonality test, Perfect Recostruction (PR) property test,..., with **wavelet\_check**:
		
	>> wavelet_check('CDF_9x7',3);
	Analysis (decomposition) filters (H0 taps, H1 taps) = (9,7)
	H0 taps = [0.03783 -0.02385 -0.11062 0.37740 0.85270 0.37740 -0.11062 -0.02385 0.03783]
	H1 taps = [0.06454 -0.04069 -0.41809 0.78849 -0.41809 -0.04069 0.06454]
	H0 (DC,Nyquist) gain = (1.414214,0.000000) 
	H1 (DC,Nyquist) gain = (0.000000,1.414214) 

	Synthesis (reconstruction) filters (H0 taps, H1 taps) = (7,9)
	H0 taps = [-0.06454 -0.04069 0.41809 0.78849 0.41809 -0.04069 -0.06454]
	H1 taps = [0.03783 0.02385 -0.11062 -0.37740 0.85270 -0.37740 -0.11062 0.02385 0.03783]
	H0 (DC,Nyquist) gain = (1.414214,0.000000) 
	H1 (DC,Nyquist) gain = (0.000000,1.414214) 

	Orthogonality (test) = biorthogonal (b)
	H0/H1 L2 norms ratio = 1.028824
	o/e reconstructed error energies ratio, (e,o) lattice = 1.221005
											(e,e) lattice = 0.466805
	Orthonormality parameter = 0.015002
	Vanishing moments (test) = (4,4)
	Time-frequency localisation wavelet f. (t, w) = 1.504155 (0.649418, 2.316156)
	Time-frequency localisation scaling f. (t, w) = 0.607824 (0.667394, 0.910742)

	level  L2(G0)   L2(G1)   dBIBO(L) dBIBO(H) PCR(e,o)
	 1     0.99144  1.02002  1.95211  1.83513  1.22101 ( 0.91 1.11 )
	 2     1.01519  0.98347  1.36549  1.34483  1.30426 ( 0.98 1.12 0.86 1.12 )
	 3     1.02572  1.01962  1.38657  1.35364  1.37387 ( 0.98 1.11 0.90 1.13 0.98 1.13 0.82 1.11 )

	Sum of absolute differences (lifting - convolution), low-pass = 0.000000, high-pass = 0.000000
	Sum of absolute differences to original, lifting = 0.000000, convolution = 0.000000
	
### Scaling function ###
5 iterations for nice approximation, with **scaling\_fun**:
	
	>> scaling_fun('CDF_9x7',5,'d','plot');
	
![9x7 wavelet scaling function](https://github.com/nsprljan/Matlab/Wavelet/raw/master/CDF_9x7_scaling_analysis.png)

### Wavelet filter taps ###
Low pass filter taps, (scaling function with 0 iterations) with **scaling\_fun**:

	>> scaling_fun('LeGall_5x3',0,'d');

![5x3 wavelet h0 taps](https://github.com/nsprljan/Matlab/Wavelet/raw/master/LeGall_5x3_h0.png)	

### Frequency and phase characteristic ###
With **wavelet\_char**:

	>> wavelet_char('CDF_9x7','CDF_9x7','d','plot');  

![9x7 wavelet frequency characteristic](https://github.com/nsprljan/Matlab/Wavelet/raw/master/wavelet_9x7_char_freq.png)	
![9x7 wavelet phase characteristic](https://github.com/nsprljan/Matlab/Wavelet/raw/master/wavelet_9x7_char_phase.png)

### 2D wavelet ###
As a tensor product of 1D wavelets, with **wavelet2D**:

	>> wavelet2D('LeGall_5x3',5,'d','l','l');

![2D wavelet](https://github.com/nsprljan/Matlab/Wavelet/raw/master/2Dwavelet.png)		
	
### Wavelet packet decomposition ###

	>> par=struct('N',5,'pdep',2,'wvf',load_wavelet('CDF_9x7'),'dec','greedy');
	>> ent_par=struct('ent','shannon','opt',0);
	>> [D,packet_stream,s,E]=decomp_packets2D('lena256.png',par,ent_par);
	>> draw_packets(D,par.N,par.pdep,s,packet_stream);
	
Wavelet packet subband tree:

![Wavelet packet subband tree](https://github.com/nsprljan/Matlab/Wavelet/raw/master/wavelet_packet_subband_tree.png)	

Wavelet packet transform coefficients:

![Wavelet packet transform coefficients](https://github.com/nsprljan/Matlab/Wavelet/raw/master/Lena_transform_coefficients.jpg)

	