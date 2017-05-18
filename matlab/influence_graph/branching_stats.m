% load the data
load ig_polish_results;
% Compute the key branching statistics
lambda_0_org = stats.event_gen_counter_Z(2)/stats.event_gen_counter_Z(1)
C = sum(stats.event_gen_counter_Z(3:end));
P = sum(stats.event_gen_counter_Z(2:(end-1)));
lambda_1p_org = C/P


%% now look at the stats of the "after" data
% Process the data into generations
disp('Processing data');
max_delta_t = 10;
in_dir = '../polish_results/after_top10/';
file_root = 'all_k2_loadprc_100';
output_dir = in_dir;
gen_file = process_cascade_data(in_dir,file_root,max_delta_t,output_dir);
generations = sparse(csvread(gen_file)');
add_to_z0 = 8383920-922;
stats_after = compute_branching_stats(generations,[],false,add_to_z0);

lambda_0_after = stats_after.event_gen_counter_Z(2)/stats_after.event_gen_counter_Z(1)
C = sum(stats_after.event_gen_counter_Z(3:end));
P = sum(stats_after.event_gen_counter_Z(2:(end-1)));
lambda_1p_after = C/P


%% make a cascade sizes ccdf plot
cascade_sizes_after = cascade_sizes_real;
cascade_sizes_after(cascade_sizes_real>2) = stats_after.cascade_sizes;
figure(1); clf; hold on;
plot_ccdf(cascade_sizes_real,2,'k-');
plot_ccdf(cascade_sizes_after,2,'k--');

%% plot the branching rates
figure(2); clf;
gen_nos = 0:(length(stats.lambda)-1);
y1 = stats.lambda;
y2 = stats_after.lambda;
y2_ = zeros(size(y1));
y2_(1:length(y2)) = y2;
bar(gen_nos,[y1;y2_]',2,'grouped');
axis([-.5 17.5 0 1.6]);
xlabel('Generation');
ylabel('Branching rate');
set(gca,'fontsize',16);
legend('Original data','Modified data');
legend boxoff;

