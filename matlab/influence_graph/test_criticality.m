load ig_data_6bus;

H

%% 
m = size(H,1);
p0 = ones(m,1)*1/100;
perturbation_size = 0.5;
H0 = H;
H1 = H;
[delta_a_sum,delta_a]   = compute_criticality(H0,H1,p0,perturbation_size,'cols');

%[delta_a_sum_,delta_a_] = compute_criticality(H,[],p0,perturbation_size,'cols');
%delta_a_sum ./ delta_a_sum_

%% Display the results for the top_10
disp('Top k');
k = 4;
[delta_a_sum_sorted,index] = sort(delta_a_sum,'descend');
top_k = index(1:k);
for j = top_k'
    fprintf('%d (%s): %.4f\n',j,br_names{j},delta_a_sum(j));
end


%% now do the incremental calculation
[upgrades,alpha] = top_k_upgrades(H0,H1,p0,perturbation_size,'cols',[],k);
disp('Top k, incremental');

for ix = 1:k
    j = upgrades(ix);
    fprintf('%d (%s): %.4f\n',j,br_names{j},alpha(ix));
end


return

%% Now just produce a to show the effect of various initiating outages
I = speye(m);
for j = 1:m
    p0 = zeros(m,1);
    p0(j) = 1;
    aj = p0' + p0' * H0 * inv(I-H1); %#ok<*MINV>
    fprintf('%d (%s): %.4f\n',j,br_names{j},sum(aj));
end

