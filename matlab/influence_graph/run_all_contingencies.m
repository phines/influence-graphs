clear all;
randseed(1); % deterministic randomness

%% load the data
C = psconstants;
load case2383_mod_ps; % this is the case data
load pairdata4paul;   % this is the n-2 set that causes blackouts, BOpairs
ps = dcpf(ps);
flow = ps.branch(:,C.br.Pf);

m = size(ps.branch,1);

%% generate a complete list
disp('Generating list of contingencies');
all_pairs = list_of_all(m);
is_bo_all = check_bo_all(all_pairs,BOpairs);

%% Compute LODF
H = makePTDF(ps.baseMVA, ps.bus, ps.branch);
LODF = makeLODF(ps.branch, H);
LODF(isnan(LODF)) = 0;
LODF(isinf(LODF)) = 0;

%% compute the weighted performance indices

weights = abs(flow)/sum(abs(flow));
[PI,is_overload] = get_contingency_metrics(ps,all_pairs,'wollenberg',LODF,weights);

%% look at the stats
PI_bo = PI(is_bo_all);
PI_nobo = PI(~is_bo_all);

save metric_results;

%% plot
figure(1); clf; hold on;
n_bo = sum(is_bo_all);
n_nobo = length(PI)-n_bo;
P = (n_bo:-1:1)/n_bo;
plot(sort(PI_bo),P,'r');
P = (n_nobo:-1:1)/n_nobo;
plot(sort(PI_nobo),P,'k');
set(gca,'xscale','log');
set(gca,'yscale','log');
axis([1e-6 1e-1 1e-6 1]);

return
