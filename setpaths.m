function setpaths
%setpaths
%Adds subdirectories to the Matlab search path

fp = fileparts(which(mfilename));
addpath([fp '\QualityAssessment']); 
addpath([fp '\Wavelet']); 
addpath([fp '\YUV']); 
addpath([fp '\ZerotreeCoding']); 
