function outdir = run_many_dcsimsep(casefile,trigger_outage_file)
% Use DCSIMSEP to run many triggering events
% trigger_outage_file should be a comma or space delimited text file
%  with one set of outages per line. Each outage should be an integer
%  between 1 and the number of branches in the network (2383)

% Load the power systems data
load(casefile);



outdir = sprintf(