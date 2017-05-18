function k_out = trunk_poiss_rnd(lambda,k_max)
% generates a random integer from a upper truncated poisson distribution
% st:
%   f_t(k,lambda,k_max) = f(k,lambda)/(1-F(k_max,lambda)) for
%      k={0,...,k_max}

% perhaps do this the easy way
k_not_trunk = mypoissrnd(lambda);
k_out = min(k_not_trunk,k_max);

% Or the more complicated way:
%{
% If k_max is large ignore this:
% Find the pmf for the standard poisson
k = 0:k_max;
pmf = lambda.^k ./ factorial(k) .* exp(-lambda);
% Find the cdf
cdf_k_max = sum(pmf);

% Do the scaling
pmf_trunk = pmf ./ cdf_k_max;
cdf_trunk = cumsum(pmf_trunk);
r = rand;
ix = find(cdf_trunk>r,1,'first');
k_out = k(ix);
%}

% function Q = regularized_gamma(a,z)
% % Regularized Gamma according to: http://mathworld.wolfram.com/RegularizedGammaFunction.html
% 
% Q = gammainc(z,a) ./ gamma(a);