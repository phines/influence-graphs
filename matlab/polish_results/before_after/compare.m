
clear all;
%before = csvread('bo_sizes.csv',1);
before = csvread('../before/bo_sizes_loadprc_100.csv',2);
after  = csvread('../after_top10/bo_sizes_loadprc_100.csv',1);
before_lines = before(:,4);
before_MW    = before(:,3);
after_lines  = after(:,4);
after_MW     = after(:,3);
sub_before = find(before_lines>0);
l1 = before(sub_before,1);
l2 = before(sub_before,2);
sub_after = zeros(size(sub_before));
for i = 1:length(sub_before)
    sub_after(i) = find( l1(i)==after(:,1) & l2(i)==after(:,2) );
end

%% do a quick comparison plot
delta_abs = before_lines(sub_before)-after_lines(sub_after);
delta_pct = delta_abs./before_lines(sub_before)*100;
%delta2 = (before_MW(subset)-after_MW)./before_MW(subset)*100;
%delta2(isnan(delta2))=0;
figure(2); clf; hold on;
set(gca,'fontsize',16);
[before_srted,ix] = sort(before_lines(sub_before));
tmp = after_lines(sub_after);
after_srted = tmp(ix);
plot(before_srted,'k');
plot(after_srted,'ro');
plot(sort(after_srted),'b-');
ylabel('Absolute reduction');
legend('Original cascade sizes','After increasing capacities','After, sorted');
legend boxoff;

%% plot the ccdf of the data
after_lines_all = zeros(size(before_lines));
after_lines_all(sub_before) = after_lines;
figure(4); clf; hold on;
cascade_sizes_after = after_lines_all + 2;
cascade_sizes_before = before_lines + 2;
plot_ccdf(cascade_sizes_before,0,'k-');
plot_ccdf(cascade_sizes_after,0,'r--');
legend('before','after top 10');
legend boxoff;


%% Risk
big = 52;
freq_of_big_before = sum(cascade_sizes_before>big)/length(cascade_sizes_before)
freq_of_big_after  = sum(cascade_sizes_after>big)/length(cascade_sizes_after)
change = (freq_of_big_before - freq_of_big_after)/freq_of_big_before

risk_before = sum(before_MW)
risk_after  = sum(after_MW)
ratio = (risk_after - risk_before) / risk_before * 100

% probability of large cascades


return

%% Print out the cascade sizes
%cascade_sizes_after  = after_full(:,4)+2;
f = fopen('cascade_sizes_after.data','w');
fprintf(f,'%d\n',cascade_sizes_after);
fclose(f);



%legend('before','after');
return

%% Set up paths
addpath('../../dcsimsep');
%addpath('../../dcsimsep/data');

%% Prepare the before/after cases
C = psconstants;
load ../before/ps_polish_before;
ps_before = ps;
ps_after = ps;
data = csvread('criticality.csv');
br_nos = data(:,1);
crit_meas = data(:,2);
crit_set = br_nos(crit_meas>0);
ps_after.branch(crit_set,C.br.rates) = ps_after.branch(crit_set,C.br.rates)*2;
%save ../after/ps_polish_after ps_after;

%% Take a look at the better and worse cases
opt = psoptions;
opt.verbose = 1;
opt.sim.stop_threshold = 0.00;
better = delta>0;


disp('worst case');
[d,worst] = min(delta);
outage = after(worst,1:2);
dcsimsep(ps_before,outage,[],opt);
fprintf('\n\n\n\n\n');
dcsimsep(ps_after,outage,[],opt);

disp('Worst set');
opt.verbose = false;
worse_set = find(delta<0);
sizes_before = zeros(length(worse_set),1);
sizes_after  = zeros(length(worse_set),1);
for i = 1:length(worse_set)% = worse_set'
    ci = worse_set(i);
    outage = after(ci,1:2);
    [~,relay_outages,MW_b] = dcsimsep(ps_before,outage,[],opt);
    sizes_before(i) = size(relay_outages,1);
    [~,relay_outages,MW_a] = dcsimsep(ps_after,outage,[],opt);
    sizes_after(i) = size(relay_outages,1);
    fprintf('Before: %5.0f %3d, After: %5.0f %3d\n',MW_b,sizes_before(i),MW_a,sizes_after(i));
end

[sizes_before sizes_after]


return

%{
%% Check the data
errors1 = (before(:,1)~=after(:,1));% | before(:,2)~=after(:,2));
errors2 = (before(:,2)~=after(:,2));

n_errors1 = sum(errors1)
n_errors2 = sum(errors2)

%% Subset the data 
casc_size = 0;
%before_MW    = before(:,3);
%before_lines = before(:,4);
%after_MW     = after(:,3);

subset = before_lines>casc_size | after_lines>casc_size;
n_cascades = sum(subset)

%% Compare
better = after_lines < before_lines;
n_better = sum(better)
worse = after_lines > before_lines;
n_worse = sum(worse)

%% Plot the difference
diff = better | worse;
difference = after_lines(diff) - before_lines(diff);
%bar((difference));

%% Save the results
save compare;

return

%% Draw the figure
data = [before_lines after_lines];
figure(1); clf;
bar(data,'grouped')
%}