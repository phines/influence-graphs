function [gen_file,Z] = prepare_ig_data_modified(ps,output_dir,sampling_method,outages_n_iter,delta_t)
% Produce the cascading failure simulation data needed to make an influence
% graph
% ps is the case data
% output_dir is the name of the directory
% sampling_method is either: "n2s" for all of the n-2 contingencies
%  or "MC" is monte carlo using 
% n is the number of samples (not needed for n2s method)
% delta_t is the time step

% Gather some data
C = psconstants;
opt = psoptions;
opt.verbose = false;
m = size(ps.branch,1);

% Get the probabilities if needed
if strcmp(sampling_method,'MC')
    Pr_outage = ps.branch(:,C.br.fail_rate)/8760;
    n_iter = outages_n_iter;
else
    all_exo_outages = outages_n_iter;
    n_iter = size(all_exo_outages,1);
end

% make the output directory
mkdir(output_dir);
% open a file for the blackout sizes
bosize_fname = sprintf('%s/bo_sizes.csv', output_dir);
fk = fopen(bosize_fname,'w');
if fk<=0, error('could not open file'); end
fprintf(fk,'No. exogenous, BO size (MW), BO size (branches)\n');
if fk<=0, error('could not open file'); end

% open the outage sequence data file
events_fname = sprintf('%s/events.csv',output_dir);
f = fopen(events_fname,'w');
if f<=0, error('could not open file'); end
fprintf(f,'type (exogenous=0 endogenous=1 stop=-1), time (sec), branch number\n');

iter = 1;
while iter <= n_iter
    % show the progress
    progressbar(iter/n_iter)
    % choose the outages
    if strcmp(sampling_method,'MC')
        is_failed = rand(m,1)<Pr_outage;
        exo_outages = find(is_failed)';
        %if isempty(exo_outages)
        %    continue
        %end
    else % method for n2s
        exo_outages = all_exo_outages(iter,:);
    end
    % error checking
    if length(exo_outages)<length(unique(exo_outages))
        error('Something funny happened');
    end
    % simulate the sequence
    if isempty(exo_outages)
        MW_lost = 0;
        endo_outages = [];
        relay_outages = zeros(0,2);
    else
        fprintf('Simulating outage %d of %d ...',iter,n_iter);
        [~,relay_outages,MW_lost] = dcsimsep(ps,exo_outages,[],opt);
        fprintf(' BO size = %.2f MW\n',MW_lost);
        % Error checking
        endo_outages = relay_outages(:,2)';
        if any(ismember(exo_outages,endo_outages))
            error('This should not happen');
        end
    end
    % save bo size to the aggregate file
    fprintf(fk,'%d,',length(exo_outages));
    fprintf(fk,'%g,%g\n',MW_lost,size(relay_outages,1));
    
    % print the exogenous outages
    t = 1.0;
    for i = 1:length(exo_outages)
        o = exo_outages(i);
        fprintf(f,'0,%g,%d\n',t,o);
    end
    
    % print the endogenous outages
    for i = 1:size(relay_outages,1)
        t = relay_outages(i,1);
        fprintf(f,'1,%.4f,%d\n',t,relay_outages(i,2));
    end
    % print the stop event
    fprintf(f,'-1,%.4f,-1\n',t+100);
    % increment iter
    iter = iter + 1;
end

%% Now prepare the generations data
% Read the input data
infile = events_fname;
data = csvread(infile,1);
event_type = data(:,1);
out_time = data(:,2);
br_no = data(:,3);

% prep an outfile
gen_file = sprintf('%s/generations.csv',output_dir);
[~,Z] = group_generations(event_type,out_time,br_no,delta_t,gen_file);

