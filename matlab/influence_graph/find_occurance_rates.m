function counts = count_occurrances(n,gen_file)

% Read in the generation data
generations = csvread(gen_file);
n_gen = size(generations,1);
% Init the output
counts = zeros(10,n);

% Iterate and count
gen_no = 1;
for g = 1:n_gen
    this_gen = generations(g,:);
    outages = this_gen(this_gen>0);
    if isempty(outages)
        gen_no = 1;
    else
        counts
    end
end
