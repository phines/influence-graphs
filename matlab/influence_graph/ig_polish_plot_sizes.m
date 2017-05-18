% Plot the cascade sizes in the empirical and the simulated data
load ig_polish_results

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

% plot the pmf
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

%% Write the raw data to files
f = fopen('cascade_sizes_real.data','w');
fprintf(f,'%d\n',cascade_sizes_real);
fclose(f);

f = fopen('cascade_sizes_sim.data','w');
fprintf(f,'%d\n',cascade_sizes_sim);
fclose(f);

