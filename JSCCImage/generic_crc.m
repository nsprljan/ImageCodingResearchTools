function crc=generic_crc(input,gen_poly)
%accepts binary inputs and computes CRC
%if gen_poly is just one number in length the it doesn't 
%represent generator polynomial but the length of the CRC
%which will be searched in the tables
%example of gen_poly -> [1 1 0 1]=1+x+x^3

gpl=length(gen_poly);
if gpl==1
    switch gen_poly
        case 0
            crc=[];return
        case 4
            gpl=5;
            gen_poly=[1 1 1 1 1]; % 1 + x^1 + x^2 + x^3 + x^4
        case 8
            gpl=9;
            gen_poly=[1 0 1 0 1 0 1 1 1]; % 1 + x^2 + x^4 + x^6 + x^7 + x^8
        case 10
            gpl=11;
            %gen_poly=[1 0 1 0 1 0 1 0 1 0 1]; % 1 + x^2 + x^4 + x^6 + x^8 + x^10
             gen_poly=[1 1 0 0 1 1 0 0 0 1 1]; % 1 + x + x^4 + x^5 + x^9 + x^10
        case 16
            gpl=17;
            %gen_poly=[1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1]; % 1 + x + x^15 + x^16
            gen_poly=[1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1]; % 1 + x^2 + x^15 + x^16
    end;
end;
crc=zeros(1,gpl-1);
[q,rem] = gfdeconv([zeros(1,gpl-1) input],gen_poly);
crc(1:length(rem))=rem;