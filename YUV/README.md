MATLAB YUV Toolbox
==================

Functions for manipulation of YCbCr (also known as 'YUV') sequences. 

For YUV sequences comparison the Quality Assessment toolbox is required. For sequence rescaling and when rescaling chromas (e.g. conversion from 4:4:4 to 4:2:2) Matlab Image Processing Toolbox function imresize is used. 


Functions
---------

 - **divide_seq** - Divides YUV sequence into segments
 - **mm_seq** - Converts video file into raw YCbCr format
 - **read_floatframe** - Reads and displays frame values stored as a stream of float numbers
 - **rgb2yuv** - Converts RGB to YUV
 - **save_yuvframe** - Saves selected frame from yuv sequence to image file
 - **scale_seq** - Scales YUV sequence
 - **seq_frames** - Returns the number of frames in YUV sequence file
 - **shift_seq** - Artificially shifts a sequence in a defined direction by any displacement
 - **write_floatframe** - Stores matrix in a file as a stream of float numbers
 - **yuv2avi** - Imports YUV sequence and saves it as AVI
 - **yuv2rgb** - Converts YUV to RGB
 - **yuv_compare** - Compares two YUV sequences by computing PSNR
 - **yuv_export** - Exports YUV sequence
 - **yuv_import** - Imports YUV sequence
 - **yuv_range** - Computes the range of samples in YUV sequence 

  
Examples
--------
**yuv\_import**, **yuv2rgb**, **yuv\_compare**:

	>> [Y, U, V] = yuv_import('FOREMAN_352x288_30_orig_01.yuv',[352 288],2);
	>> rgb = yuv2rgb(Y{1},U{1},V{1});
	>> [PY, PU, PV]=yuv_compare('compressed.yuv','original.yuv',[352 288]);
