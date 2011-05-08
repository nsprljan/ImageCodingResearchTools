MATLAB Quality Assessment Toolbox
==================

Various reconstructed image quality metrics. Used in most of the other toolboxes.


Functions
---------

 - **iq_measures** - Image Quality Measures - various measures of reconstructed image quality
 - **image_show** - Displays image, with additional parameters
 - **pqs** - Script that runs software based on CIPIC PQS version 1 (Picture Quality Scale) image quality measure. Unzip the contents Pqs.zip into subdirectory .\Pqs to make the binary available to the script. The original  CIPIC PQS version 1 software has been modified so there is support for different block size (switch -b).
  
  
Examples
--------
**iq\_measures**:

	>> A = imread('Lena256.png');
	>> B = double(A) + rem(magic(256),5) - 2;
	>> [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE] = iq_measures(A,B,'disp');
	 MSE (Mean Squared Error) = 1.999985
	 PSNR (Peak Signal / Noise Ratio) = 45.120537 dB
	 AD (Average Difference) = 0.000015
	 SC (Structural Content) = 0.999893
	 NK (Normalised Cross-Correlation) = 0.999997
	 MD (Maximum Difference) = 2.000000
	 LMSE (Laplacian Mean Squared Error) = 0.035148
	 NAE (Normalised Absolute Error) = 0.009669