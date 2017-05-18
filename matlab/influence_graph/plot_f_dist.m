clear all

%% Make the f-related data
if 1
    if 1
        casename = 'polish';
        load case2383_mod_ps;
    else
        casename = 'case30x4';
        load ../data/case30x4_ps;
    end
    
    n_br = size(ps.branch,1);
    gen_fname = sprintf('../%s_results/k2/generations.csv',casename);
    [F,F_dist] = make_ig_f(n_br,gen_fname);
    
    save results
else
    load polish_f_plot_results;
end

%% Do some plots
figure(1); clf;
for i = 1:n_br
    if F_dist.F1(2,i)>0
        %hold on;
        x = F_dist.row_index(F_dist.row_index>0);
        y = F_dist.F1(F_dist.row_index>0,i);
        plot(F_dist.row_index,F_dist.F1(:,i),'-');
        set(gca,'xscale','log');
        pause
    end
end
% adjust the figure
%set(gca,'scale','log');
%set(gca,'yscale','log');
axis tight
axis([1e-2 10 0 20]);

%% Plot the overall distribution
F1_dist_mean = mean(F_dist.F1,2);
figure(2); clf
x = F_dist.row_index';
probability = F1_dist_mean / sum(F1_dist_mean);
plot(x,probability,'k-');
set(gca,'xscale','log');
% find the effective lambda parameter, if this were poisson
lambda = sum(x.*probability / sum(probability))
hold on;
plot(x,poisspdf(x,lambda),'k--');
set(gca,'yscale','log');
axis([0 100 1e-5 1]);
ylabel('Probability mass');
xlabel('# of children');
legend('Actual data','Poisson fit');
legend boxoff;



