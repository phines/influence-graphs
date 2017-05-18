clear all;
% Get started
n = 7;
nodes = [1:7]';
links = [1 2;
         2 3;
         3 4;
         3 5;
         3 6;
         3 7];
A = adjacency(nodes,links,0,1);
Glam = A;


M = 3;
p0 = [1;zeros(n-1,1)];
s0 = ones(n,1);
p = zeros(n,M);
p_ = p;
s = zeros(n,M+1);
for m = 1:M
    if m==1
        p_k_1 = p0;
        s_k_1 = s0;
    else
        p_k_1 = p(:,m-1);
        s_k_1 = s(:,m-1);
    end
    s(:,m) = (1-p_k_1).*s_k_1;
    p(:,m) = Glam' * p_k_1;
    p_(:,m) = (Glam')^m * p0;
end
s(:,M+1) = (1-p(:,m)).*s(:,M);

s
p
p_



% Gmat = 
% A = full(A)
% [V,D] = eig(full(A'))
