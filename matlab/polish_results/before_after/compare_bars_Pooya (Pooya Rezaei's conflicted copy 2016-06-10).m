
clear all;

% range of percents for the bars
EPS = 1e-4;
range = [5,10,20,30,40,100];
% load data
before = csvread('../before/bo_sizes_loadprc_100.csv',2);
after = csvread('../after_top10/bo_sizes_loadprc_100.csv',1);
before_MW_lost = before(:,3);
before_br_lost = before(:,4);
% make the after case a complete set (with all n-2's)
subset = (before_br_lost > 0);
after_new = before;
after_new(subset,:) = after;
after = after_new;
after_MW_lost = after(:,3);
after_br_lost = after(:,4);
% find total load
load('../before/ps_polish_before.mat')
C = psconstants;
total_load = sum(ps.shunt(:,C.sh.P) .* ps.shunt(:,C.sh.factor));
total_br = 2896;
Pr = ps.branch(:,C.br.fail_rate)/8760;

% make y_bar
y_bar = nan(2,length(range)-1);
for i = 1:length(range)-1
    min_MW = range(i)*total_load/100;
    max_MW = range(i+1)*total_load/100;
    % compute risk for the before case
    subset = before_MW_lost>=min_MW & before_MW_lost<max_MW;
    y_bar(1,i) = sum(before_MW_lost(subset) .* Pr(before(subset,1)) .* Pr(before(subset,2)))*1000;
    % compute risk for the after case
    subset = after_MW_lost>=min_MW & after_MW_lost<max_MW;
    y_bar(2,i) = sum(after_MW_lost(subset) .* Pr(after(subset,1)) .* Pr(after(subset,2)))*1000;
end
%% polish figure
% colormap('summer')
cmap = [linspace(0,1,64)', zeros(64,1), linspace(1,0,64)'];
font_size = 20;
figure(11); clf
hbar = bar(y_bar,0.8,'stacked');
set(hbar,'EdgeColor','none');
xlim([0.5,2.5])
ylim([0 60])
set(gca,'xticklabel',{'Before','After'},'FontSize',font_size)
ylabel('Risk (Expected blackout size, kW)','FontSize',font_size);
text(1.79,57,'Blackout Sizes, S','FontSize',font_size)
% h1 = legend('5%<S<10%','10%<S<20%','20%<S<30%','30%<S<40%','S>40%');
h1 = legend('5%<S<10%','10%<S<20%','20%<S<30%','30%<S<40%','S>40%');
set(h1,'pos',get(h1,'pos')-[0,0.05,0,0])
legend boxoff
colormap(cmap);
set(gca,'box','off')



