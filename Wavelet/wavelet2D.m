function W=wavelet2D(wavelet,iter,type,pass1,pass2)
%Computes (and draws) a 2D wavelet, tensor product of 1D wavelets 
%W=wavelet2D(wavelet,iter,pass1,pass2,plt)
%
%Input: 
% wavelet - wavelet identification string
% iter - number of successive approximation iterations
% type - specifies wavelet
%         if (type == 'd') analysis (decomposition) filter
%         if (type == 'r') synthesis (reconstruction) filter
% pass1, pass2 - specifies which row-column combination to take
%                 if (pass1 == 'l' &  pass2 == 'l') then LL
%                 if (pass1 == 'l' &  pass2 == 'h') then LH
%                 if (pass1 == 'h' &  pass2 == 'l') then HL
%                 if (pass1 == 'h' &  pass2 == 'h') then HH
%
%Output: 
% W - 2D wavelet
%
%Uses: 
% wavelet_fun.m
% scaling_fun.m
%
%Example:  
% wavelet2D('CDF_9x7',5,'d','l','l');
% W=wavelet2D('LeGall_5x3',5,'d','l','l');

if nargin<=4
    plt = 0;
else
    plt = 1;
end;
if (nargout > 0) %display only if output is not defined
    plt = '';
end;
psi = []; %scaling function
phi = []; %wavelet function

if (pass1 == 'l')
    phi=scaling_fun(wavelet,iter,type);
    c1=phi; 
elseif (pass1=='h')
    psi=wavelet_fun(wavelet,iter,type);
    c1=psi;
end;
if (pass2=='l') 
    if (isempty(phi)) 
        phi=scaling_fun(wavelet,iter,type);
    end;
    c2=phi; 
elseif (pass2 == 'h')
    if (isempty(psi)) 
        psi=wavelet_fun(wavelet,iter,type);
    end;
    c2=psi;
end;

W=c1'*c2;

if (plt == 1)
    figure('NumberTitle','off','Name',[wavelet ' 2D wavelet']);
    opengl autoselect;
    surfl(W);
    axis([0 size(W,1) 0 size(W,1) min(min(W)) max(max(W))]);
    set(gca,'FontSize',15,'FontName','Times New Roman');
    shading interp;
    colormap('copper');
    rotate3d on;
end;

