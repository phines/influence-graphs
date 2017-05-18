clear all;
clc

%% get constants that help us to find the data
C = psconstants; % tells me where to find my data

%% set some options
opt = psoptions;
opt.verbose = true; % set this to false if you don't want stuff on the command line
% Stopping criterion: (set to zero to simulate a complete cascade)
opt.sim.stop_threshold = 0.00; % the fraction of nodes, at which to declare a major separation
opt.sim.fast_ramp_mins = 1;

%% Prepare and run the simulation for the Polish grid
%ps = case300_001_ps;
fprintf('----------------------------------------------------------\n');
disp('loading the data');
tic
if exist('case2383_mod_ps.mat','file')
    load case2383_mod_ps;
else
    ps = case2383_mod_ps;
end
toc
fprintf('----------------------------------------------------------\n');
disp('Preparing the case');
tic
ps = updateps(ps);
ps = redispatch(ps);
ps = dcpf(ps);
toc
fprintf('----------------------------------------------------------\n');
m = size(ps.branch,1);
pre_contingency_flows = ps.branch(:,C.br.Pf);
phase_angles_degrees = ps.bus(:,C.bu.Vang);

%% Run an extreme case
% outage
br_outages = BOpairs(i,:);
% run the simulator
[isblackout,relay_outages,MW_lost] = dcsimsep(ps,br_outages,[],opt);

%% Run several cases
opt.verbose = false;
load BOpairs
n_iters = 10;

disp('Testing DCSIMSEP without control.');
tic
for i = 1:n_iters
end
toc

% try again with control
disp('Testing DCSIMSEP with control.');
opt.sim.use_control = true;
tic
for i = 1:n_iters
    % outage
    br_outages = BOpairs(i,:);
    % run the simulator
    fprintf('Running simulation %d of %d. ',i,n_iters);
    [~,relay_outages_2,MW_lost_2(i),p_out,busessep,flows] = dcsimsep(ps,br_outages,[],opt);
    fprintf(' Result: %.2f MW of load shedding\n',MW_lost_2(i));
    %is_blackout = dcsimsep(ps,br_outages,[],opt);
end
toc

return
%% make a picture
figure(1);
Pd0 = sum(ps.shunt(:,C.sh.P));
bo_sizes = MW_lost/Pd0;
bar(1:n_iters,bo_sizes,1,'EdgeColor','none');

fprintf('%d of %d simulations resulted in 10%% or more load shedding\n',sum(bo_sizes>0.1),n_iters);
return
%% draw the cascade
if is_blackout
    draw_cascade(ps,br_outages,bus_outages,relay_outages);
end

return

