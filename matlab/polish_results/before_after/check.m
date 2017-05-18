% check
clear all;
%% Set up paths
addpath('../../dcsimsep');
addpath('../../dcsimsep/data');
addpath('../../influence_graph');


%% Load and prepare the data
% load the case data
load case2383_mod_ps;
ps0 = ps;
load case2383_mod_ps_before.mat;
ps_org = ps;
load case2383_mod_ps_after.mat
ps_mod = ps;
load case2383_mod_ps_old.mat
ps_old = ps;

%% Load the igraph data
load ig_polish_results;

cascades = find(cascade_sizes_real>5);

%% Now simulate to see what matches
C = psconstants;
opt = psoptions;
opt.verbose = false;
opt.sim.stop_threshold = 0.00;

for c = cascades'
    outage = all_pairs(c,:)
    [~,relay_outages0,MW_lost0] = dcsimsep(ps_old,outage,[],opt);
    [~,relay_outages1,MW_lost1] = dcsimsep(ps0,outage,[],opt);
    [~,relay_outages2,MW_lost2] = dcsimsep(ps_org,outage,[],opt);
    [~,relay_outages3,MW_lost3] = dcsimsep(ps_mod,outage,[],opt);
    n_out_data = cascade_sizes_real(c)
    n_out_old  = size(relay_outages0,1)
    n_out0     = size(relay_outages1,1)
    n_out_org  = size(relay_outages2,1)
    n_out_mod  = size(relay_outages3,1)
    pause
end
