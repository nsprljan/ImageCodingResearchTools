function Y=dead_zone_q(X,qstep)
%x = dead_zone_q(x,qstep)
%Quantisation with a dead-zone around zero 
%
%Input: 
% X - original matrix
% qstep - quantisation step (threshold)
%
%Output:
% Y - quantised matrix
%
%Note:
% Dead zone is equal to the quantisation step, i.e. all coefficients whose
% absolute value is <qstep get quantised to 0.
%
%Example:
% Y=dead_zone_q(X,0.5);

if (~isfloat(X)) X = double(X);end;  
Xs = sign(X);
Y = abs(X);
Y(Y<qstep) = 0;
Y = floor(Y/qstep);
Y(Y~=0) = Y(Y~=0)+0.5;
Y = Xs.*Y*qstep;
