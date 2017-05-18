clear all;

load('ps_polish_all','ps_polish_100')
ps = ps_polish_100;

% make a list of all n2s
nbr = size(ps.branch,1);
all_n2s = zeros(nbr*(nbr-1)/2, 2);
cnt = 0;
start_idx = 1;
for i = 1:nbr
    progressbar(i/nbr)
    new_br_list = i+1:nbr;
    n = length(new_br_list);
    new_set = [i*ones(n,1), new_br_list'];
    all_n2s(start_idx:start_idx+n-1,:) = new_set;
    start_idx = start_idx+n;
end

critical_br = [16, 18, 19, 38, 1029];

C = psconstants;
ps.branch(critical_br,C.br.rates) = ps.branch(critical_br,C.br.rates)*2;

[gen_file,Z] = prepare_ig_data_modified(ps,'polish_mod','n2s',all_n2s,30);

