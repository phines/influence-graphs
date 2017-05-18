%% load the data
%load ig_polish_results;
load ig_polish_results_delta_t_5;

%% Distribution of outage sizes
endo_counts_real = cascade_sizes_real;
endo_counts_sim  = cascade_sizes_sim;
% make the ccdf
%close all;
figure; hold on;
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
