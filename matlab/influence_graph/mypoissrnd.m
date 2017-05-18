function r = mypoissrnd(lambda)
% usage: r = poissrnd(lambda)
% only set up to generate numbers <1000

if isnan(lambda)
    error('Lambda cannot be NaN');
end
if lambda<0
    error('Lambda has to be non-negative');
end
if lambda==0
    r = 0;
    return;
end

L = exp(-lambda);
k = 0;
p = 1;

for k = 1:1000
    u = rand;
    p = p * u;
    if p<=L
        break;
    end
end

r = k-1;

if k==1000
   error('something went wrong'); 
end
