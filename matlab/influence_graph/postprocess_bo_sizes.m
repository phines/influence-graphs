clear all;

% infile = '~/Dropbox/Paul-Ian et al/INFLUENCE/MATLAB/polish_results/k2/bo_sizes_loadprc_100_mod.csv';
% bo_sizes = csvread(infile,1);
% save('../polish_results/k2/bo_sizes_loadprc_100_mod.mat','bo_sizes')

% load('../polish_results/k2/bo_sizes_loadprc_100_mod')
% nbr_out = bo_sizes(:,4);

%% Check if all the simulations are done and make a mat file
n_subsets = 100;
nbr = 2896;
n_k2 = nbr*(nbr-1)/2;
bo_sizes = nan(n_k2,4);
skip_list = [];
for set_no = 1:n_subsets
    progressbar(set_no/n_subsets)
    if ismember(set_no,skip_list)
        fprintf('set number %d not loaded.\n',set_no);
        continue
    end
    fprintf('loading set number %d.\n',set_no);
    n_per_subset = ceil(n_k2/n_subsets);
    first = (set_no-1)*n_per_subset + 1;
    last  = min(set_no*n_per_subset,n_k2);
    infile = sprintf('../polish_results/k2/raw data/bo_sizes_loadprc_100_%d.csv',set_no);
    data = csvread(infile,1);
    N = size(data,1);
    if (set_no<n_subsets && N~=n_per_subset) || (set_no==n_subsets && N~=n_k2-n_per_subset*(set_no-1))
        fprintf('set number %d (rows %d to %d) has %d simulations.\n', ...
            set_no,first,last,N);
    else
        bo_sizes(first:last,:) = data;
    end
end 
nbr_out = bo_sizes(:,4);

%% plot results

figure; plot_pmf(nbr_out,'-*')

