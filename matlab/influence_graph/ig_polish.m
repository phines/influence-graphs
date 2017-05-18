clear all;
%{
% Load stuff
addpath('../dcsimsep');
addpath('../dcsimsep/data');
opt = psoptions;
C = psconstants;
% load the case data
load case2383_mod_ps;

% run power flow
ps = dcpf(ps);
% draw the case
opt.draw.width = 0.01;
opt.draw.fontsize = 14;
opt.draw.bus_nos = 0;
%figure(1); clf;
%drawps(ps,opt);
% Remove a branch
%ps.branch(4,C.br.status) = 0;
%ps = dcpf(ps);
%drawps(ps,opt);
m = size(ps.branch,1);
n = m; % just to confuse us... `

%% Load the simulation data

disp('Loading data');
load results/polish_generations_data.mat
%generations = sparse(generations);
% Compute some stats
disp('Compute branching stats');
stats = compute_branching_stats(generations);
lambda_0 = stats.lambda(1);
lambda_1plus = sum(stats.event_gen_counter_Z(3:end))/sum(stats.event_gen_counter_Z(2:(end-1)));
[counts_real,cascade_sizes_real] = count_occurrances(n,generations);

%% Make ig F
disp('Calculating f');
do_F0_F1 = true;
%F_ian  = make_ig_f(m,gen_file,do_F0_F1,'dobson')
F_paul = make_ig_f(m,generations,do_F0_F1,'hines');
F = F_paul;

% check the weighted average
% if do_F0_F1
%     weigthed_avg = sum(F.F0.*P_counts.P0)/sum(P_counts.P0);
% else
%     weigthed_avg = sum(F.*P_counts)/sum(P_counts);
% end

%% Make ig G
disp('Calculating g');
G = make_ig_g(m,generations,false);
%G
save ig_polish_results

%% Now draw the influence graph
%figure(2); clf;
%draw_ig(ps,sqrt(F.F0)*5,G);
%}
%load ig_polish_results

%% Simulate the igraph
%{
disp('Simulating the igraph');
%load ig_polish_results
all_pairs = list_of_all(m);
gen_file_sim = simulate_igraph(F,G,all_pairs);
% Compute some stats
stats_sim = compute_branching_stats(gen_file_sim);

% Count occurrance rates
[counts_sim,cascade_sizes_sim]   = count_occurrances(n,gen_file_sim);
save ig_polish_results
%}
load ig_polish_results


%% Plot the occurance rates for the various elements
% Component names
% for i = 1:m
%     f = ps.branch(i,1);
%     t = ps.branch(i,2);
%     br_names{i} = sprintf('%d-%d',f,t); 
% end

figure(3); clf;
y_max = 1000;
% real
subplot(2,1,1);
bar(counts_real(2:end,:)','stacked');
for i = 0:(size(counts_real(2:end,:),1)-1)
    gen_text{i+1} = sprintf('Gen %d',i); %#ok<*SAGROW>
end
legend(gen_text);
legend boxoff;
axis([0 m+1 0 y_max]);
title('DCSIMSEP data');
% fake
subplot(2,1,2);
bar(counts_sim(2:end,:)','stacked');
legend(gen_text);
legend boxoff;
axis([0 m+1 0 y_max]);
title('Simuated IG data');

%% Produce a figure that shows the total dep. (endo) counts for both cases
endo_counts_real = sum(counts_real(2:end,:),1);
endo_counts_sim  = sum(counts_sim(2:end,:),1);
mx = 1800;
figure(4); clf;
subset = endo_counts_real>0 & endo_counts_sim>0;
plot(endo_counts_real(subset),endo_counts_sim(subset),'.');
hold on;
plot(1:mx,1:mx,'k-');
axis([1 mx 1 mx]);
set(gca,'fontsize',16)
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel({'The number of times that an element occurred','as a dependent outage in the real data'});
ylabel({'The number of times that an element occurred',' as a dependent outage in the i-graph data'});

%% Plot the F distributions
figure(5); clf;
set(gca,'FontSize',16);
hold on;
plot_ccdf(F.F0,[],'k-');
plot_ccdf(F.F1,[],'k--');
axis tight
box on;
legend('\lambda_0','\lambda_1');
legend boxoff;
set(gca,'xtick',10.^(-3:1));

xlabel('Component-wise branching rate (x)');
ylabel('Probability that \lambda_i \geq x');

%% Run a very simple branching process simulation with average lambda_0 and lambda_1
%{
disp('Completing a simple branching process sim.');
lambda_0 = F.F0;
lambda_1plus = F.F1;
event_sizes = simple_branching_sim(lambda_0,lambda_1plus,1e6,2);
simple_br_sizes = sum(event_sizes,1);
%}

%% Distribution of outage sizes
endo_counts_real = cascade_sizes_real;
endo_counts_sim  = cascade_sizes_sim;
% make the ccdf
close all;
figure(6); hold on;
set(gca,'FontSize',16);
plot_ccdf(endo_counts_real,[],'k-');
plot_ccdf(endo_counts_sim,[],'k--');
%plot_ccdf(simple_br_sizes,'k-.');
%set(h1,'xticklabel',{});
%axis([1 2e3 3e-4 1]);
box on;
%xlabel('Cascade size (x)');
ylabel('Pr ( cascade size \geq x )');
legend('Empirical','Simulated');
legend boxoff;

%% plot the pmf
%h2 = subplot(2,1,2); cla; hold on;
figure(7); clf; hold on;
set(gca,'FontSize',16);
plot_pmf(endo_counts_real,'r.-');
plot_pmf(endo_counts_sim,'b*-');
%plot_pmf(simple_br_sizes,'kx');
%axis tight;
%set(gca,'ytick',10.^(-5:1:0));
box on;
legend('Empirical','Simulated');
legend boxoff;
ylabel('Probability');
xlabel('Cascade size (including initiating events)');
axis([1 180 1e-7 2e-3]);
%set(h2,'Position',[ 0.1300    0.2    0.7750    0.3412]);

%% (unrelated) look a the correlation between lambda0 and lambda1
%{
lambda0 = F.F0;
lambda1 = F.F1;
figure(7); clf;
set(gca,'FontSize',16);
plot(lambda0,lambda1,'o');
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('\lambda_0');
ylabel('\lambda_1');
%}

%% Build, plot g-lambda
do_plot = false;
Glam = build_Glambda(F.F1,G,do_plot);

%% Write out files for drawing the system
C = psconstants;
nodes = ps.bus(:,[C.bu.id C.bu.locs]);
n_grid = size(nodes,1);
m = size(ps.branch,1);
links = [ps.branch(:,[1 2]) ones(m,1)*.1];
write_gdf(nodes,[],links,false,'polish_grid.gdf');
%figure(1); clf;
%draw_ig2(ps,Glam);
% link locations
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
f = ps.bus_i(ps.branch(:,1));
t = ps.bus_i(ps.branch(:,2));
x_link = (x(f) + x(t))/2;
y_link = (y(f) + y(t))/2;
m = length(f);
nodes_ig = [(1:m)'+10000 x_link y_link];
[ig_from,ig_to,weight] = find(Glam);
links_ig = [ig_from+10000,ig_to+10000,weight];
write_gdf(nodes_ig,[],links_ig,false,'polish_igraph.gdf');

% write a combined gdf
min_weight = 0.01;
links_ig_sub = links_ig(weight>min_weight,:);
n_ig = size(nodes_ig,1);
grid_color = ones(n_grid,3)*.7; % Gray
ig_color   = [ones(n_ig,1) zeros(n_ig,1) zeros(n_ig,1)]; % Red
nodes_all = [nodes    ones(n_grid,1)*.1 grid_color; 
             nodes_ig ones(n_ig,1)*.2   ig_color];
links_all = [links;links_ig_sub];

write_gdf(nodes_all,[],links_all,false,'polish_igraph_combo.gdf');



