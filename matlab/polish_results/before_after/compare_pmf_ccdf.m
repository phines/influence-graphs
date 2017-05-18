before = csvread('cascade_sizes_real.data');
after  = csvread('cascade_sizes_after.data');

%% Produce a plot
figure(1); clf;
%% pmf
h1 = subplot(2,1,1); cla;
hold on;
p1 = plot_pmf(before,30,'r-');
p2 = plot_pmf(after,30,'b-');
axis(h1,[1 130 1e-7 1e-3]);
set(p1,'linewidth',3);
set(p2,'linewidth',3);

%% ccdf
h2 = subplot(2,1,2); cla;
hold on;
p3 = plot_ccdf(before,1,'r-');
p4 = plot_ccdf(after,1,'b-');
set(h2,'yscale','linear');

axis(h2,[1 130 1e-7 1e-3]);
set(p3,'linewidth',3);
set(p4,'linewidth',3);
