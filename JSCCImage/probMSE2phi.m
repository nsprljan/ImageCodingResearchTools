function phi_PSNR=probMSE2phi(prob_res,prob_arrival,MSE)
phi_PSNR=zeros(1,prob_res);
cum_prob=cumsum(prob_arrival);
MSE_ind=1;
for z=1:prob_res
    prob=z/prob_res;
    while cum_prob(MSE_ind)<prob & MSE_ind<length(MSE)
        MSE_ind=MSE_ind+1;
    end;
    phi_PSNR(prob_res-z+1)=10*log10(255^2./MSE(MSE_ind));
end;