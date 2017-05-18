% Find the expected value of a number raised to a poisson


lambda = 3;
g = 0.8;
k = 0:40;

% Test
temp = exp(-lambda) * sum( (1-g).^k .* (lambda.^k) ./ factorial(k) )
temp = exp(-lambda) * sum( ((1-g)*lambda).^k ./ factorial(k) )
%temp = sum( ((1-g)*lambda).^k ./ factorial(k) )
%temp = exp( (1-g)*lambda )
temp = exp( -g * lambda )

% The full answer
g_prime = 1 - sum( (1-g).^k .* (lambda.^k)./factorial(k).*exp(-lambda) )
g_prime_guess = 1 - (1-g)^lambda

1- exp(-g * lambda)