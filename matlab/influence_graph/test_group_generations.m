clear all;
%% Constants
LARGE=200;

%% read the outage data
%casename = 'polish';
casename = 'case30x4';
%load ../data/case30x4_ps;

infile = sprintf('../%s_results/k2/all_k2.csv',casename);
data = csvread(infile);
event_type = data(:,1);
out_time = data(:,2);
br_no = data(:,3);
save(sprintf('%s_outage_data',casename));

%% Figure out what delta_t to use
TYPE_STOP = -1;
%TYPE_ENDO = 1;
TYPE_EXO  = 0;
% compute the time between the current event and the previous one
delta_t = [0;out_time(2:end) - out_time(1:(end-1))];
delta_t(event_type==TYPE_STOP) = LARGE;
delta_t(event_type==TYPE_EXO) = LARGE;

%% plot a histogram
figure(1); clf;
hist(delta_t(delta_t<LARGE & delta_t>0),30)

%% do the grouping
% prep an outfile
out_fname = sprintf('../%s_results/k2/generations.csv',casename);
max_delta_t = 30; % maximum amount of time to put things into the same generation
[out_fname,Z] = group_generations(event_type,out_time,br_no,max_delta_t,out_fname);

%% do some error checking
stats = compute_branching_stats(out_fname,Z);

