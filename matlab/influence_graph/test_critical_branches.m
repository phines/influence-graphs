% Look at the critical branches to see which ones are worthwhile
load critical_branches;
load ig_polish_results;
load results/polish_generations_data.mat;
most_critical = 16;

% Loop through the generations data and figure out how many times crit.
%  branches occur
occ_gens = cell(length(critical_branches),1); % tells us where each br occurs
n_generations = size(generations,2);
gen_no_m = 0;
for g = 1:n_generations
    if gen_no_m==0
        gen_no_m = gen_no_m + 1;
        continue;
    end
    outages = generations(:,g);
    outages = outages(outages>0);
    if isempty(outages)
        gen_no_m = 0;
        continue;
    end
    is_crit = ismember(critical_branches,outages);
    ss = find(is_crit)';
    for s = ss
        occ_gens{s} = cat(1,occ_gens{s},g);
    end
    gen_no_m = gen_no_m + 1;
end
