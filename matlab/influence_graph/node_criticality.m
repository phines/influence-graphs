function ES = node_criticality(G_lambda,M)
% Roughly estimate the expected blackout size resulting from the outage of each component

n = size(G_lambda,1);
ES = zeros(n,1);

for i = 1:n
    p0 = zeros(n,1);
    p0(i) = 1;
    s0 = ones(n,1);
    p = zeros(n,M);
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
        p(:,m) = G_lambda' * p_k_1;
    end
    s(:,M+1) = (1-p(:,m)).*s(:,M);
    ES(i) = n - sum(s(:,M+1));
end
