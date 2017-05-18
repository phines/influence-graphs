function make_polish_data(runno,n_runs)

% Give things a seed
randseed;

% load the case data
load case2383_mod_ps;

% Prep ig data -- run for 24 hours
hours_24 = 24*3600;
output_dir = sprintf('polish_data_%d_of_%d',runno,n_runs);
prepare_ig_data(ps,output_dir,'mc_time',hours_24);
