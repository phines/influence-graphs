
% make the scatter plot requested by reviewer 2

%% load the data
load ig_polish_results;
% counts_real and counts_sim are the variables of interest

%% collect data for m>=1
first_gen = 2;
real_counts_subset1 = sum(counts_real(first_gen:end,:));
sim_counts_subset1 = sum(counts_sim(first_gen:end,:));
subset = real_counts_subset1>0 | sim_counts_subset1>0;
real_counts_subset1 = real_counts_subset1(subset);
sim_counts_subset1 = sim_counts_subset1(subset);

%% collect data for m>=4
first_gen = 5;
real_counts_subset4 = sum(counts_real(first_gen:end,:));
sim_counts_subset4 = sum(counts_sim(first_gen:end,:));
subset = real_counts_subset4>0 | sim_counts_subset4>0;
real_counts_subset4 = real_counts_subset4(subset);
sim_counts_subset4 = sim_counts_subset4(subset);

%% make the plot
figure(1); clf;
x1 = real_counts_subset1/sum(real_counts_subset1);
y1 = sim_counts_subset1/sum(sim_counts_subset1);
x4 = real_counts_subset4/sum(real_counts_subset4);
y4 = sim_counts_subset4/sum(sim_counts_subset4);
plot(x1,y1,'bo'); hold on;
plot(x4,y4,'rx'); hold on;
set(gca,'fontsize',16);
xlabel('Occurrance rate in empirical data','interpreter','latex');
ylabel('Occurrance rate in influence graph data','interpreter','latex');
set(gca,'xscale','log');
set(gca,'yscale','log');
axis tight;
mn = 2e-5;
mx = 2e-2;
axis([mn mx mn mx]);
%plot([mn mx],[mn mx],'k-');

%% and then the individual plots
figure(2); clf;
plot(x1,y1,'bo'); hold on;
set(gca,'fontsize',16);
xlabel('Occurrance rate in empirical data','interpreter','latex');
ylabel('Occurrance rate in influence graph data','interpreter','latex');
set(gca,'xscale','log');
set(gca,'yscale','log');
axis tight;
mn = 2e-5;
mx = 2e-2;
axis([mn mx mn mx]);

figure(3); clf;
plot(x4,y4,'rx'); hold on;
set(gca,'fontsize',16);
xlabel('Occurrance rate in empirical data','interpreter','latex');
ylabel('Occurrance rate in influence graph data','interpreter','latex');
set(gca,'xscale','log');
set(gca,'yscale','log');
axis tight;
mn = 2e-5;
mx = 2e-2;
axis([mn mx mn mx]);


%% Correlation

rho_1 = corrcoef(x1,y1)
rho_4 = corrcoef(x4,y4)

