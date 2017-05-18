clear all;
addpath('../../dcsimsep');

%% Read the before sizes
before = csvread('../before/bo_sizes_loadprc_100.csv',2);
before_lines = before(:,4);
before_MW    = before(:,3);

%% load the original case data
load ../before/ps_polish_before.mat;
ps_before = ps;

%% Find the most severe contingencies
worst_set = find(before_lines>10) %& before_lines<20);
n_worst = size(worst_set,1)

%% modify the "critial" transmission lines
C = psconstants;

% performance index method
load ../../influence_graph/polish_PI.mat;
[PI_sorted,ix] = sort(PI,'descend');
top_10_PI = ix(1:10);

% criticality method
load ../../influence_graph/polish_criticality.mat;
[alpha_sorted,ix] = sort(delta_a_sum,'descend');
top_10_alpha = ix(1:10);

% choose a method
top_10 = top_10_PI;

% modify the top_10
ps_after = ps_before;
ps_after.branch(top_10,C.br.rates) = ps_after.branch(top_10,C.br.rates)*2;

%% run the worst contingencies on this modified case
opt = psoptions;
opt.verbose = 0;
opt.sim.stop_threshold = 0.00;

n_worst = size(worst_set,1);
sizes_before = zeros(n_worst,1);
sizes_after  = zeros(n_worst,1);
sizes_before_MW = zeros(n_worst,1);
sizes_after_MW  = zeros(n_worst,1);

for i = 1:n_worst
    ci = worst_set(i);
    outage = before(ci,1:2);
    %[~,relay_outages,MW_b] = dcsimsep(ps_before,outage,[],opt);
    MW_b = before_MW(ci);
    sizes_before(i) = before_lines(ci);%size(relay_outages,1);
    [~,relay_outages,MW_a] = dcsimsep(ps_after,outage,[],opt);
    sizes_after(i) = size(relay_outages,1);
    fprintf('[%4d %4d] Before: %5.0f %3d, After: %5.0f %3d\n',outage(1),outage(2),MW_b,sizes_before(i),MW_a,sizes_after(i));
    sizes_before_MW(i) = MW_b;
    sizes_after_MW(i)  = MW_a;
end

%% Plot
figure(1); clf; hold on;
[sizes_before_sorted,index] = sort(sizes_before);
sizes_after_sorted = sizes_after(index);
plot(sizes_before_sorted,'k-');
plot(sizes_after_sorted,'o');

%% Save the results 
save before_after_top10_PI

%% compare
mu_br_before = mean(sizes_before(:,1))
mu_br_after  = mean(sizes_after(:,1))

mu_MW_before = mean(sizes_before_MW(:,1))
mu_MW_after  = mean(sizes_after_MW(:,1))

