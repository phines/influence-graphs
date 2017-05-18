% Compare our criticality results to the performance index method

%% load the data
load ig_polish_results;

%% compute the performance indices for each branch
m = size(ps.branch,1);
br_outages = (1:m)';
[PI,is_overload] = get_contingency_metrics(ps,br_outages,'wollenberg');

save polish_PI PI;

%% compare to our metric
load polish_criticality
figure(1); clf;
plot(PI,delta_a_sum,'ro'); hold on;
set(gca,'xscale','log');
set(gca,'yscale','log');
set(gca,'fontsize',16);
xlabel('Performance Index','interpreter','latex');
ylabel('$\alpha$','interpreter','latex');

%% mark the top 10 in both dimensions

[alpha_sorted,ix] = sort(delta_a_sum,'descend');
top_10_alpha = ix(1:10);

[PI_sorted,ix] = sort(PI,'descend');
top_10_PI = ix(1:10);

plot(PI(top_10_alpha),delta_a_sum(top_10_alpha),'bx');
plot(PI(top_10_PI),delta_a_sum(top_10_PI),'g^');
