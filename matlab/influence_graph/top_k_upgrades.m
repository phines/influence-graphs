function [upgrades,alpha] = top_k_upgrades(H0,H1,p0,perturbation_size,rows_cols,subset,k)
% find the k most effective upgrades of size "perturbation_size"
% usage: [upgrades,alpha] = top_k_upgrades(H0,H1,p0,perturbation_size,rows_cols,subset,k)

upgrades = zeros(k,1);
alpha    = zeros(k,1);
n = size(H0,1);

ki = 0;
while ki < k
    % compute the metric
    delta_a_sum = compute_criticality(H0,H1,p0,perturbation_size,rows_cols,subset);
    % find the most effective upgrade
    [alpha_i,upgrade] = max(abs(delta_a_sum));
    ki = ki + 1;
    upgrades(ki) = upgrade;
    alpha(ki) = alpha_i;
    % now update H0 and H1;
    i = upgrade;
    if strcmpi(rows_cols,'rows')
        delta_0 = H0(i,:)*perturbation_size;
        delta_1 = H1(i,:)*perturbation_size;
        dH0 = sparse(i,1:n,delta_0,n,n);%sparse(ei*delta_0);
        dH1 = sparse(i,1:n,delta_1,n,n);%sparse(ei*delta_1);
    else
        delta_0 = sparse(H0(:,i)*perturbation_size);
        delta_1 = sparse(H1(:,i)*perturbation_size);
        dH0 = sparse(1:n,i,delta_0,n,n);
        dH1 = sparse(1:n,i,delta_1,n,n);
    end
    % apply the perturbation
    H0 = H0 - dH0;
    H1 = H1 - dH1;
end
