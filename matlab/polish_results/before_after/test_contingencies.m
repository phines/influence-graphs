clear all;
%% Set up paths
addpath('../../dcsimsep');
addpath('../../dcsimsep/data');

%% Load and prepare the data
C = psconstants;
opt = psoptions;
opt.verbose = 0;
opt.sim.stop_threshold = 0.00;

load compare;
% Load the case data
load ps_polish_all.mat;
ps_scopf = ps_polish_100;
% Modify several branches
%critical_br = [113, 821, 90, 115, 53];
%ps.branch(critical_br,C.br.rates) = ps.branch(critical_br,C.br.rates)*2; 
%ps_mod = ps;

%% Do a sanity checks
outage_i = 47;
outage = all_contingencies(outage_i,:);
%[~,relay_outages1,MW_lost1] = dcsimsep(ps0,outage,[],opt);
[~,relay_outages2,MW_lost2] = dcsimsep(ps_scopf,outage,[],opt);
%[~,relay_outages3,MW_lost3] = dcsimsep(ps_mod,outage,[],opt);
%n_out0     = size(relay_outages1,1)
n_out_org  = size(relay_outages2,1)
%n_out_mod  = size(relay_outages3,1)
n_out_data = before_lines(outage_i)

%% Compare some of the blackout sizes
bo_set = find(before_lines>10);

for outage_i = bo_set'
    MW_lost_data = before(outage_i,3);
    n_out_data   = before(outage_i,4);
    outage = before(outage_i,1:2);
    [~,relay_outages,MW_lost] = dcsimsep(ps_scopf,outage,[],opt);
    n_out = size(relay_outages,1);
    fprintf('outage = [%d %d]: MW_lost = [%g %g], line_outages = [%g %g]\n',...
        [outage MW_lost MW_lost_data n_out n_out_data]);
end

%% Select some contingencies to compare
better_set = find(better);
worse_set  = find(worse);
outage_better = all_contingencies(better_set(1),:);
outage_worse = all_contingencies(worse_set(1),:);

%% Run dcsimsep on the two cases

% better
[~,relay_outages1,MW_lost1] = dcsimsep(ps_org,outage_better,[],opt);
[~,relay_outages2,MW_lost2] = dcsimsep(ps_mod,outage_better,[],opt);

% worse
[~,relay_outages3,MW_lost3] = dcsimsep(ps_org,outage_worse,[],opt);
[~,relay_outages4,MW_lost4] = dcsimsep(ps_mod,outage_worse,[],opt);


%% Compare the results
n_out_better_org = size(relay_outages1,1)
n_out_better_mod = size(relay_outages2,1)
n_out_worse_org = size(relay_outages3,1)
n_out_worse_mod = size(relay_outages4,1)

