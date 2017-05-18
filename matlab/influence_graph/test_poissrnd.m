lambda = 0.5;
k_max = 2;

n = 10000;
r1 = zeros(n,1);
for i=1:n
    r1(i) = mypoissrnd(lambda);
end


r2 = zeros(n,1);
for i=1:n
    r2(i) = trunk_poiss_rnd(lambda,k_max);
end

figure(2);
hist([r1 r2],0:10);

