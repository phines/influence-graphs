% generate lists of cascade paths for ian dobson

%% load the data
C  = psconstants;
ps = case30_ps;
ps = updateps(ps);
ps = dcpf(ps);
n_branch = size(ps.branch,1);
flow = abs(ps.branch(:,C.br.Pf));
flow_max = ps.branch(:,C.br.rateA);
hist(flow./flow_max,20);

%% create the contingency list
n_minus_2_set = list_of_all(n_branch,2);
n_minus_3_set = list_of_all(n_branch,3);
% convert to cells and combine
n2 = mat2cell(n_minus_2_set,ones(size(n_minus_2_set,1),1),2);
n3 = mat2cell(n_minus_3_set,ones(size(n_minus_3_set,1),1),3);
all_contingencies = [n2;n3];
n_contingency = size(all_contingencies,1);

%% prep the ouptut files
t_file = fopen('trigger_outages.csv','wt');
fprintf(t_file,'List of triggering branch outages (branch numbers)\n');
d_file = fopen('dependent_outages.csv','wt');
fprintf(d_file,'List of dependent branch outages (branch numbers)\n');
MW_file = fopen('blackout_sizes.csv','wt');
fprintf(MW_file,'Blackout sizes in MW\n');

%% run a debug test
opt = psoptions;
opt.sim.sep_threshold = 0.0;
opt.verbose = true;
br_outages = [2 3 5];%all_contingencies{20};
[is_blackout,relay_outages,MW_lost] = dcsimsep(ps,br_outages,[],opt);

%% apply dcsimsep to each
opt = psoptions;
opt.verbose = false;

for i = 1:n_contingency
    br_outages = all_contingencies{i};
    fprintf('Simulating outages: ');
    fprintf('%d ',br_outages');
    fprintf('\n');
    
    [is_blackout,relay_outages,MW_lost] = dcsimsep(ps,br_outages,[],opt);
    if ~isempty(relay_outages)
       fprintf(t_file,'%d,',br_outages');
       fprintf(t_file,'\n');
       fprintf(d_file,'%d,', relay_outages(:,2));
       fprintf(d_file,'\n');
       fprintf(MW_file,'%g\n',MW_lost);
    end
end

fclose(d_file);
fclose(e_file);
fclose(MW_file);

%% also save the locations




