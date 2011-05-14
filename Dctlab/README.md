DCTlab
======

A GUI for sudying the steps of DCT-based image compression and for assessment of reconstructed image quality. The program window is divided into parts representing stages of JPEG image compression - transform, quantisation, coding. Additional menus are available with right-click over displayed image (e.g. for the original image the choices are: Zoom View (shows enlarged picture), Save (saves picture as .bmp file), Assign to workspace (saves image as a variable in Matlab workspace).

If the selected size of DCT block is 8x8 (as in JPEG), quantisation table and coding can be applied, leading to the compressed bit-stream. Note that no actual bit-stream is generated, just the resulting bit rate is computed. The compression ratio can be adjusted by changing the quantisation matrix (by multiplying it with a selected constant). Zig-zag scanning order, quantisation matrix and Huffman codes are user-definable. The predefined tables, taken from the JPEG standard, come with DCTlab: Qdefault.txt (quantization matrix), Zdeafult.txt (zig-zag pattern), Hdefault (Huffman tables). The file DCTlabDefaults.txt is a 'registry' file pointing to the files containing these tables, so new ones can easily be added in this way. Supported image formats are greyscale .bmp, .png and .mat, and dimensions are restricted to be powers of two, with a square aspect ratio.

The main portion of this software was developed during my BSc and MSc studies at the Department of Radiocommunications and Microwave Engineering [Video Communications Laboratory](http://www.vcl.fer.hr/), [Faculty of Electrical Engineering and Computing](http://www.fer.hr/), University of Zagreb.
 
Functions
---------

 - **dctlab** - 2D DCT on blocks (using cosine function), optimised for square matrices   
 - **blkdct2cos** - 2D DCT on blocks (using cosine function), optimised for square matrices   
 - **blkdct2fft** - 2D DCT on blocks (using fft), optimised for square matrices   
 - **blkidct2cos** - 2D IDCT on blocks (using cosine function), optimised for square matrices
 - **blkidct2fft** - 2D IDCT on blocks (using fft), optimised for square matrices
 - **dct2sq** - 2D DCT optimised for square matrices 
 - **dctbasis** - Computes the elementary basis functions for 1D and 2D DCT
 - **idct2sq** - 2D IDCT optimised for square matrices 	
 
Examples
--------
**dctlab** screenshot:

  ![dctlab screenshot](https://github.com/nsprljan/Matlab/raw/master/Dctlab/DCTlab.png)	  

DCT basis functions with **dctbasis**:

    >> A=dctbasis(8,2);
  
  ![DCT 8x8 basis](https://github.com/nsprljan/Matlab/raw/master/Dctlab/dct_8x8_basis.png)	  
