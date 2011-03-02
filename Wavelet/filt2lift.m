function [L,Kx,Ky]=filt2lift(wvf)
%Computes lifting coefficients from the wavelet as FIR filter 
%[L,Kx,Ky]=filt2lift(wvf)
%
%Input:
% wvf - wavelet identification string
%
%Ouput:
% L - lifting coefficients, in a similar format as lift_coef from
%      load_wavelet.m. 
%      L(1,1:2) - prediction step (left and right lifting coefficient)
%      L(2,1:2) - update step (left and right lifting coefficient)
%      L(3,1:2) - prediction step (left and right lifting coefficient)
%      ...
% Kx - low-pass normalisation factor
% Ky - high-pass normalisation factor
%
%Note:
% The algorithm may not work due to imprecise coefficients!
%
%Examples:
% [L,Kx,Ky]=filt2lift('Haar');
% [L,Kx,Ky]=filt2lift('LeGall_5x3');

if ischar(wvf)
    wvf = load_wavelet(wvf);
end;
Ll = []; %lifting coeffcients for pixels on the left (z^-1)
Lr = []; %lifting coeffcients for pixels on the right (z^1)
Kx = 1; 
Ky = 1; 

%central pixel for the filters
cp_lp = find(wvf.filt_G0_delay == 0);
cp_hp = find(wvf.filt_G1_delay == 0);
g0_pw = wvf.filt_G0_delay;
g1_pw = wvf.filt_G1_delay;

%odd and even pixels:
%{e o} {e o} {e o} = {z^-1 z^-1} (1 1} {z^1 z^1}
%|g00  g10| | e |   | e'|
%|        | |   | = |   |
%|g01  g11| | o |   | o'|

%low-pass
g00 = zeroifempty(wvf.filt_G0(mod(g0_pw,2) == 0)); %subsampling to encompass the central pixel
g00_pw = zeroifempty(g0_pw(mod(g0_pw,2) == 0) / 2);
g01 = zeroifempty(wvf.filt_G0(mod(g0_pw,2) == 1)); %subsampling around the central pixel
g01_pw = zeroifempty((g0_pw(mod(g0_pw,2) == 1) + 1) / 2);
%high-pass
g10 = zeroifempty(wvf.filt_G1(mod(g1_pw,2) == 1)); %subsampling around the central pixel
g10_pw = zeroifempty((g1_pw(mod(g1_pw,2) == 1) - 1) / 2);
g11 = zeroifempty(wvf.filt_G1(mod(g1_pw,2) == 0)); %subsampling to encompass the central pixel
g11_pw = zeroifempty(g1_pw(mod(g1_pw,2) == 0) / 2);

while (1) %iterate lifting steps
    %check if the predict step is necessary
    if ((numel(g01) == 1) && (g01 == 0) && (numel(g10) == 1) && (g10 == 0))
        break; %all lifting steps have been found
    end;
    %predict step
    %|1          0| |g00  g10|
    %|lambda(z)  1| |g01  g11|
    %=
    %|g00                                      g10|
    %|lambda(z) * g00 + g01  lambda(z) * g10 + g11|
    %
    %task: reduce the order of (lambda(z) * g00 + g01) by 2
    %
    %lambda(z) = a + b * z^1 (pixels on left and right, both even pixels,
    % the central pixel is odd indexed and is being predicted)
    %
    %The task is then to reduce the order of:
    % a * g00 + b * g00 * z^1 + g01
    [a,b]=solvestep(g00,g00_pw,g01,g01_pw,1);
    if (a == 0) && (b == 0)
        warning(['Could not find the lifting coefficients for step ' num2str(length(Ll) + 1) ', filter coefficients are probably imprecise, or lifting not possible!']);
        L = [0,0];
        return;
    end;     
    Ll = [Ll; a];
    Lr = [Lr; b];
    %compute g01 = lambda(z) * g00 + g01 = a * g00 + b * g00 * z^1 + g01
    [g01,g01_pw]=multlambda(g00,g00_pw,g01,g01_pw,a,b,1);
    %compute g11 = lambda(z) * g10 + g11 = a * g10 + b * g10 * z^1 + g11
    [g11,g11_pw]=multlambda(g10,g10_pw,g11,g11_pw,a,b,1);
    %check if the update step is necessary
    if ((numel(g01) == 1) && (g01 == 0) && (numel(g10) == 1) && (g10 == 0))
        break; %all lifting steps have been found
    end; 
    %update step
    %|1  lambda(z)| |g00  g10|
    %|0          1| |g01  g11|
    %=
    %|g00 + lambda(z) * g01  g10 + lambda(z) * g11|
    %|g01                                      g11|
    %
    %task: reduce the order of (g10 + lambda(z) * g11) by 2
    %
    %lambda(z) = a * z^-1 + b (pixels on left and right, both odd pixels,
    % the central pixel is odd indexed and is being updated)
    %
    %The task is then to reduce the order of:
    % a * g11 + b * g11 * z^-1 + g10
    [a,b]=solvestep(g11,g11_pw,g10,g10_pw,-1);
    if (a == 0) && (b == 0)
        error(['Could not find the lifting coefficients for step ' num2str(length(Ll) + 1) ', filter coefficients are probably imprecise, or lifting not possible!']); 
    end;       
    Ll = [Ll; a];
    Lr = [Lr; b];
    %compute g00 = g00 + lambda(z) * g01 = a * g01 * z^-1 + b * g01 + g00
    [g00,g00_pw]=multlambda(g01,g01_pw,g00,g00_pw,a,b,-1);
    %compute g10 = g10 + lambda(z) * g11 = a * g11 * z^-1 + b * g11 + g10
    [g10,g10_pw]=multlambda(g11,g11_pw,g10,g10_pw,a,b,-1);    
end;
%what remained in the polyphase matrix are the normalisation factors
L = [Ll Lr];
Kx = 1/g00;
Ky = 1/g11;

function [a,b]=solvestep(g0,g0_pw,g1,g1_pw,db)
%task: solve a * g00 + b * g00 * z^1 + g01 for (a,b) so that the
%order of polynomial is reduced by 2
if (db == 1)
 g0a_pw = g0_pw;
 g0b_pw = g0_pw + 1;
elseif (db == -1)
 g0a_pw = g0_pw - 1;
 g0b_pw = g0_pw;
else
    error('db must be either 1 or -1');
end;
a = 0;
b = 0;
if (g1_pw(1) == g0a_pw(1))
    a = -g1(1) / g0(1);
    if (g1_pw(end) == g0b_pw(end))
        b = -g1(end) / g0(end);
    elseif (length(g1) > 1) && (g1_pw(2) ~= 0) %central sample should be preserved for the next step
        if (length(g0) > 1)
            b = -(g1(2) + a * g0(2)) / g0(1);
        else
            b = -g1(2) / g0(1);
        end;
    end;
elseif (g1_pw(end) == g0b_pw(end))
    b = -g1(end) / g0(end);
    if (length(g1) > 1) && (g1_pw(end-1) ~= 0) %central sample should be preserved for the next step
        a = -(g1(end-1) + b * g0(end-1)) / g0(end);
    end;
    %else
    %    error('Wavelet specified incorrectly!');
end;

function [g,g_pw]=multlambda(g0,g0_pw,g1,g1_pw,a,b,db)
%compute g0 = lambda(z) * g0 + g1 = a * g0 + b * g0 * z^1 + g1 (for db = 1)
%compute g0 = lambda(z) * g0 + g1 = a * g0 * z^-1 + b * g0 + g1 (for db = -1)
%constant that takes into account the floating point imprecision in
%computing of the wavelt coeffcients
zero_tolerance = 10^(-10);
%
if (db == 1)
 g0a_pw = g0_pw;
 g0b_pw = g0_pw + 1;
elseif (db == -1)
 g0a_pw = g0_pw - 1;
 g0b_pw = g0_pw;
else
    error('db must be either 1 or -1');
end;
g_pw = [];
g = [];
for pw=min(g0a_pw(1),g1_pw(1)):max(g0b_pw(end),g1_pw(end))
 ai = find(g0a_pw == pw);
 if ~isempty(ai)
    g_pw = [g_pw;pw];
    g(length(g_pw)) = 0;
    g(end) = a * g0(ai);
 end;
 bi = find(g0b_pw == pw);
 if ~isempty(bi)
     if (g_pw(end) ~= pw) %ai was empty
         g_pw = [g_pw;pw];
         g(length(g_pw)) = 0; 
         g(end) = b * g0(bi);
     else
         g(end) = g(end) + b * g0(bi);  
     end;
 end;
 i = find(g1_pw == pw);
 if ~isempty(i)
    if (isempty(g_pw)) error('Lifting coefficients cannot be found!');end;
     if (g_pw(end) ~= pw) %ai and bi were empty
         g_pw = [g_pw;pw];
         g(length(g_pw)) = 0;  
         g(end) = g1(i);
     else
         g(end) = g(end) + g1(i);  
     end;
 end;
end;
%now, remove zeros from both sides
while (~isempty(g) && (abs(g(1)) < zero_tolerance))
 g = g(2:end);
 g_pw = g_pw(2:end);
end;
while (~isempty(g) && (abs(g(end)) < zero_tolerance))
    g = g(1:end-1);
    g_pw = g_pw(1:end-1);
end;
if isempty(g)
    g = 0;
    g_pw = 0;
end;

function v = zeroifempty(v)
if isempty(v)
    v = 0;
end;

