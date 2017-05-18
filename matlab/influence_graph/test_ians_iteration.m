
load test_G_lambda_results;

p0 = ones(n,1)*1/500;
H = G_lambda1;

a = p0' / (speye(n,n) - H);
figure(
hist(a,100)