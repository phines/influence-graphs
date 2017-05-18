function [counts,cascade_sizes] = count_occurrances(n,gen_file)
% usage: counts = count_occurrances(n,gen_file)
% Count the number of times particular elements occur in particular
% generations
% also compute the cascade sizes

% Read in the generation data
if ischar(gen_file)
    generations = sparse(csvread(gen_file)');
else
    generations = gen_file;
end
[sz1,sz2] = size(generations);
if sz1>sz2
    disp('It looks like generations is backwards');
    generations = generations';
end

n_gen = size(generations,2);

% Init the output
largest_possible_gen_i = 200;
counts = zeros(largest_possible_gen_i,n);

cascade_sizes = [];

% Iterate and count
gen_no = 1;
cs = 0;
for g = 1:n_gen
    if rem(g,1e6)==0
        fprintf('Completed %d of %d generations\n',g,n_gen);
    end
    this_gen = generations(:,g);
    outages = this_gen(this_gen>0);
    if isempty(outages)
        gen_no = 1;
        cascade_sizes = cat(1,cascade_sizes,cs);
        cs = 0;
    else
        counts(gen_no,outages) = counts(gen_no,outages) + 1;
        cs = cs + length(outages);
        gen_no = gen_no + 1;
    end
end

% remove empty rows
non_empty_rows = any(counts>0,2);
counts = counts(non_empty_rows,:);
