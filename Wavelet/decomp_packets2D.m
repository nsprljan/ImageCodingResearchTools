function [D,packet_stream,s,E]=decomp_packets2D(Y,param,entp)
%2D wavelet packets decomposition with entropy-based subband splitting
%[D,packet_stream,s,E]=decomp_packets2D(Y,param,entp)
%
%Input: 
% Y - array to be transformed
% param - structure containing decomposition parameters            
%         N: maximum depth of decomposition
%         pdep: packet decompositon depth
%         wvf: structure containing properties of a wavelet (see load_wavelet.m)
%         dec: 'greedy' or otherwise 'full'
% entp - parameters for splitting criterion based on entropy
%
%Output:
% D - array of wavelet coefficients
% packet_stream - stream of bits representing information on splitting decisions
%                 of the wavelet packets decomposition 
% s - structure containing info on parent-children relationship between subbands
%     given by wavelet packets decomposition
%     s.scale: decomposition level of the subband
%     s.parent: subband's parent
%     s.children: subband's children 
%     s.band_abs: absolute position and size [x y dx dy] (in pixels)
%     s.ban_rel: position and size relative to the original image size
% E - entropy of the resulting decomposition
%
%Uses:
% dwt_2D.m
%
%Example:
% par=struct('N',5,'pdep',2,'wvf',load_wavelet('CDF_9x7'),'dec','greedy');
% ent_par=struct('ent','shannon','opt',0);
% [D,packet_stream,s,E]=decomp_packets2D('lena256.png',par,ent_par);
% draw_packets(D,par.N,par.pdep,s,packet_stream); %displays the result of performed decomposition 

if ischar(Y)
    Y=imread(Y);   
end;  
Y=double(Y);
[Drows,Dcols]=size(Y);
subr=Drows/(2^param.N); %dimensions of the lowest subband
subc=Dcols/(2^param.N);
D=zeros(Drows,Dcols);
%check the number of decompositions
if (round(subr) ~= subr) || (round(subc) ~= subc)
    %at the moment, only powers of two supported
    error('Illegal number of decompositions for a given matrix!');
end;    
%initialize the packet tree structure
s=init_packettree(param.N,subr,subc);
%reserving memory for D (coefficients matrix), and Dpom (helping matrix)
packet_stream=[];
E=0;
%performing the wavelet decomposition of N levels
N=param.N;
param.N=param.N-param.pdep;
for i=1:N
    [DA,DH,DV,DD]=dwt_2D(Y,param.wvf);
    siz=size(DA);
    if (i < N) && (param.pdep > 0) %checking the subbands only if it's not the lowest level of decomposition
        subbindex=(N-i+1)*3-1; %index of subband H in array structure 's'
        [DH,Eh,packet_stream,s]=decompose_subband(subbindex,DH,param,entp,packet_stream,s);
        subbindex=(N-i+1)*3;   %index of subband V in array structure 's'
        [DV,Ev,packet_stream,s]=decompose_subband(subbindex,DV,param,entp,packet_stream,s);
        subbindex=(N-i+1)*3+1; %index of subband D in array structure 's'
        [DD,Ed,packet_stream,s]=decompose_subband(subbindex,DD,param,entp,packet_stream,s);
    else
        Eh=subb_entropy(DH,entp.ent,entp.opt);
        Ev=subb_entropy(DV,entp.ent,entp.opt);
        Ed=subb_entropy(DD,entp.ent,entp.opt);
    end;       
    E=E+Eh+Ev+Ed;
    A=[DA DH; DV DD];
    D(1:2*siz(1),1:2*siz(2))=A;
    Y=DA;
    param.pdep=param.pdep-1;
end;
E=E+subb_entropy(DA,entp.ent,entp.opt)+subb_entropy(DV,entp.ent,entp.opt)+...
    subb_entropy(DH,entp.ent,entp.opt)+subb_entropy(DH,entp.ent,entp.opt);


function [band,E,p_stream,s]=decompose_subband(subbindex,band,param,entp,p_stream,s)
%Decompose subband a bit further
s0=struct('scale',0,'parent',0,'children',0,'band_abs',0,'band_rel',0);
coord=struct('abs',0,'rel',0);
parentindex=s(subbindex).parent;
s0.parent=parentindex;
coord.abs=s(subbindex).band_abs;
coord.rel=s(subbindex).band_rel;
if strcmp(param.dec,'greedy')   
    [band,E,p_stream,sub_list]=dec_greedy(coord,band,param,entp,p_stream,s0);
else          
    [band,E,p_stream,sub_list]=dec_full(coord,band,param,entp,p_stream,s0);
end;
s=resolve_conflicts(subbindex,parentindex,s,sub_list);

function [band,E,p_stream,sub_list]=dec_full(coord,band,param,entp,p_stream,sub_list)
%Function for full packet decomposition and best basis selection. Provides optimal performance
E=subb_entropy(band,entp.ent,entp.opt);
if param.pdep>0
    cntold=size(p_stream,2)+1;
    [banda,bandh,bandv,bandd]=dwt_2D(band,param.wvf);
    siz=size(banda);
    A_coord=struct('abs',[coord.abs(1:2) siz(2) siz(1)],'rel',[coord.rel(1:2) coord.rel(3:4)/2]);
    H_coord.abs=A_coord.abs+[siz(2) 0 0 0];
    H_coord.rel=A_coord.rel+[A_coord.rel(3) 0 0 0];
    V_coord.abs=A_coord.abs+[0 siz(1) 0 0];
    V_coord.rel=A_coord.rel+[0 A_coord.rel(4) 0 0];
    D_coord.abs=A_coord.abs+[siz(2) siz(1) 0 0];
    D_coord.rel=A_coord.rel+[A_coord.rel(3) A_coord.rel(4) 0 0];
    param.pdep=param.pdep-1;
    [banda,Ea,p_stream,list_A]=dec_full(A_coord,banda,param,entp,p_stream,sub_list);
    [bandh,Eh,p_stream,list_H]=dec_full(H_coord,bandh,param,entp,p_stream,sub_list);
    [bandv,Ev,p_stream,list_V]=dec_full(V_coord,bandv,param,entp,p_stream,sub_list);
    [bandd,Ed,p_stream,list_D]=dec_full(D_coord,bandd,param,entp,p_stream,sub_list);
    if Ea+Eh+Ev+Ed<E
        p_stream(size(p_stream,2)+1)=1;
        band=[banda bandh;bandv bandd];
        E=Ea+Eh+Ev+Ed;
        sub_list=[list_A list_H list_V list_D];
    else
        p_stream(cntold)=0;
        p_stream=p_stream(1:cntold);
        sub_list=add_to_list(sub_list,param.N+param.pdep+1,coord,sub_list(1).parent,0);
    end;
else
    sub_list=add_to_list(sub_list,param.N+param.pdep,coord,sub_list(1).parent,0);
end;

function [band,E,p_stream,sub_list]=dec_greedy(coord,band,param,entp,p_stream,sub_list)
%Function for greedy packet decomposition and best basis selection. Provides faster preformance
[banda,bandh,bandv,bandd]=dwt_2D(band,param.wvf);
siz=size(banda);
E =subb_entropy(band,entp.ent,entp.opt);
Ea=subb_entropy(banda,entp.ent,entp.opt);
Eh=subb_entropy(bandh,entp.ent,entp.opt);
Ev=subb_entropy(bandv,entp.ent,entp.opt);
Ed=subb_entropy(bandd,entp.ent,entp.opt);
if Ea+Eh+Ev+Ed<E
    A_coord=struct('abs',[coord.abs(1:2) siz(2) siz(1)],'rel',[coord.rel(1:2) coord.rel(3:4)/2]);
    H_coord.abs=A_coord.abs+[siz(2) 0 0 0];
    H_coord.rel=A_coord.rel+[A_coord.rel(3) 0 0 0];
    V_coord.abs=A_coord.abs+[0 siz(1) 0 0];
    V_coord.rel=A_coord.rel+[0 A_coord.rel(4) 0 0];
    D_coord.abs=A_coord.abs+[siz(2) siz(1) 0 0];
    D_coord.rel=A_coord.rel+[A_coord.rel(3) A_coord.rel(4) 0 0];
    param.pdep=param.pdep-1;
    if param.pdep>0
        [banda,Ea,p_stream,sub_list]=dec_greedy(A_coord,banda,param,entp,p_stream,sub_list);
        [bandh,Eh,p_stream,sub_list]=dec_greedy(H_coord,bandh,param,entp,p_stream,sub_list);
        [bandv,Ev,p_stream,sub_list]=dec_greedy(V_coord,bandv,param,entp,p_stream,sub_list);
        [bandd,Ed,p_stream,sub_list]=dec_greedy(D_coord,bandd,param,entp,p_stream,sub_list);
    else
        sub_list=add_to_list(sub_list,param.N+param.pdep,A_coord,sub_list(1).parent,0);
        sub_list=add_to_list(sub_list,param.N+param.pdep,H_coord,sub_list(1).parent,0);
        sub_list=add_to_list(sub_list,param.N+param.pdep,V_coord,sub_list(1).parent,0);
        sub_list=add_to_list(sub_list,param.N+param.pdep,D_coord,sub_list(1).parent,0);
    end;  
    p_stream(size(p_stream,2)+1)=1;
    band=[banda bandh;bandv bandd];    
    E=Ea+Eh+Ev+Ed;
else
    p_stream(size(p_stream,2)+1)=0;
    sub_list=add_to_list(sub_list,param.N+param.pdep,coord,sub_list(1).parent,0);
end;

function sub_list=add_to_list(sub_list,scale,coord,parent,children)
ind=size(sub_list,2);
if sub_list(ind).scale
    ind=ind+1;
end;
sub_list(ind).scale=scale;
sub_list(ind).band_abs=coord.abs;
sub_list(ind).band_rel=coord.rel;
sub_list(ind).parent=parent;
sub_list(ind).children=children;

function s=resolve_conflicts(subbindex,parentindex,s,sub_list)
siz_new_list=size(sub_list,2);
if siz_new_list>1 %if subband was further decomposed
    siz_list=size(s,2);
    new_children=siz_list+1:siz_list+siz_new_list; %indices of new subbands in 's'
    s(new_children)=sub_list(1:siz_new_list); %then add new subbands in 's'
else %else subband H stays as child of it's parent
    new_children=subbindex;     
end;    
move_children_up=[]; %children that will be moved upwards to low parent (or ancestor) in subband tree structure
prev_children=s(subbindex).children; %children assigned to subband in previous level of decomposition
%resolve parenting conflicts between current and previous level of decomposition 
if prev_children(1)>0 %if it's not the subband from the highest level
    siz_prev=size(prev_children,2);
    coord_prev=reshape([s(prev_children).band_rel],4,siz_prev)'; %coordinates of subbands
    siz_new=size(new_children,2);
    for k=1:siz_new
        band_scale=s(new_children(k)).scale;
        int_areas_overlap=rectint(s(new_children(k)).band_rel,coord_prev)>0;
        overlapping_bands=prev_children(int_areas_overlap);
        scale_diff=[s(overlapping_bands).scale]-band_scale; %scale diference of the overlapping bands
        s(new_children(k)).children=overlapping_bands(scale_diff>-1); %link subband to children
        if isempty(s(new_children(k)).children)
            s(new_children(k)).children=0;
        end; 
        if ~isempty(find(scale_diff>1,1))
            disp(['Heavy parenting conflict resolved on subband ' num2str(overlapping_bands(scale_diff>1))]);   
        end;  
        move_children_up=[move_children_up overlapping_bands(scale_diff<=-1)]; %move up in subband tree
        indices=~int_areas_overlap; %just the rest will be tested again
        prev_children=prev_children(indices); 
        coord_prev=coord_prev(indices,:);
    end;    
end;
    s(parentindex).children(1)=[]; %remove first child (from initial structure)
    s(parentindex).children=[s(parentindex).children new_children move_children_up]; %and assign new children to parent 
if isempty(s(parentindex).children)
 s(parentindex).children=0;
end; 

function s=init_packettree(N,subr,subc)
%subband ordering is H,V,D
bands=N*3+1;
s=repmat(struct('scale',0,'parent',0,'children',0,'band_abs',0,'band_rel',0),1,bands);
s(1).scale=1;
s(1).parent=0;
s(1).children=[2 3 4];
s(1).band_abs=[0 0 subc subr]; %coordinates that define subband as a rectangle 
s(1).band_rel=[0 0 1 1];
for i=2:bands
    mul=2^floor((i-2)/3);   
    subrs=subr*mul;
    subcs=subc*mul;
    s(i).scale=floor((i+1)/3);
    s(i).parent=i-3;
    s(i).children=i+3;
    s(i).band_abs=[(mod(i,3)>0)*subcs (mod(i+1,3)>0)*subrs subcs subrs];
    s(i).band_rel=[0 0 1 1];
end;
s(2).parent=1;
s(3).parent=1;
s(4).parent=1;
s(bands-2).children=0;
s(bands-1).children=0;
s(bands).children=0;

function ent = subb_entropy(A,type,par)
switch type
    case 'shannon'
        A = A(find(A)).^2;
        ent = -sum(A.*log(A));
    case 'threshold'     % par is the threshold.
        ent = sum(abs(A) > par);
    case 'logenergy'     % in3 not used.
        A = A(find(A)).^2;
        ent = sum(log(A));
end;