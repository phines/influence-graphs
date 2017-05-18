
% options
addpath('../dcsimsep');
opt = psoptions;
opt.draw.width = 0.2;
opt.draw.fontsize = 14;
C = psconstants;
% load the case data
ps = case6_mod_ps;
p0 = 1/100;
ps.branch(:,C.br.fail_rate) = p0*8760; % in outages per year
% run power flow
ps = dcpf(ps);
printps(ps);
figure(1); clf;
%ps.bus(:,C.bu.locX) = ps.bus(:,C.bu.locX)/2;
% draw the case
set(gca,'fontsize',16);
drawps(ps,opt);
% pause
% Remove a branch
%ps.branch(4,C.br.status) = 0;
%ps = dcpf(ps);
%drawps(ps,opt);
m = size(ps.branch,1);
n = m; % just to confuse us... `
n_MC_runs = 10000;

%% Prepare the simulation data
disp('Loading the simulation data');
if 0
    % Prepare the data needed for the ig
    [gen_file,Z] = prepare_ig_data(ps,'../case6_mod/','MC',n_MC_runs,5);
    save ig_data_6bus;
else
    load ig_data_6bus;
end

%% Compute branching stats
disp('Branching stats');
stats = compute_branching_stats(gen_file);

%% Make ig F
disp('Computing F');
do_F0_F1 = false;
F_ian  = make_ig_f(m,gen_file,do_F0_F1,'dobson');
[F_paul,F_dist,P,C] = make_ig_f(m,gen_file,do_F0_F1,'hines');
F_paul
F = F_paul;

% check the weighted average
% if do_F0_F1
%     weigthed_avg = sum(F.F0.*P_counts.P0)/sum(P_counts.P0);
% else
%     weigthed_avg = sum(F.*P_counts)/sum(P_counts);
% end

%% Make ig G
disp('Computing G');
G = make_ig_g(m,gen_file,false);
G

%% Simulate the igraph
disp('Simulating the igraph');
gen_file_sim = simulate_igraph(F,G,n_MC_runs,p0);
% Compute some stats
disp('Computing branching statistics');
stats_sim = compute_branching_stats(gen_file_sim);

%% Plot the occurance rates for the various elements
disp('Making plots');
[counts_real,sizes_real] = count_occurrances(n,gen_file);
[counts_sim,sizes_sim] = count_occurrances(n,gen_file_sim);

% Component names
for i = 1:m
    f = ps.branch(i,1);
    t = ps.branch(i,2);
    br_names{i} = sprintf('%d-%d',f,t); 
end

figure(3); clf;
% real
subplot(2,1,1);
bar(counts_real','stacked');
for i = 0:(size(counts_real,1)-1)
    gen_text{i+1} = sprintf('Gen %d',i); %#ok<*SAGROW>
end
legend(gen_text);
legend boxoff;
axis([0 10 0 600]);
set(gca,'xticklabel',br_names);
title('DCSIMSEP data');
% fake
subplot(2,1,2);
bar(counts_sim','stacked');
legend(gen_text);
legend boxoff;
set(gca,'xticklabel',br_names);
axis([0 10 0 600]);
title('Simuated IG data');

%% Sizes
figure(4); clf; hold on;
plot_pmf(sizes_real,'ko');
set(gca,'yscale','linear');
set(gca,'xscale','linear');

%% 6-bus criticality
H = build_Glambda(F,G,false,br_names);
H0 = H;
H1 = H;
if isscalar(p0)
    po = ones(m,1)*p0;
end

perturbation_size = 0.1;
[delta_a_sum,delta_a] = compute_criticality(H0,H1,p0,perturbation_size);

delta_a_sum

%% Old stuff
% % write latex for annotations
% for i = 1:n
%     fprintf('\\lambda_{%s} = %.2f\n',br_names{i},F(i));
% end




