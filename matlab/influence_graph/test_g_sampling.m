%% Load the data
%load ig_polish_results
n_children = 1;
n_trials = 10000;

% choose a row
eligible_rows = find(sum(G>0,2)>100);
ix = randi(length(eligible_rows));
row = eligible_rows(ix);
g_row = G(row,:);

%% Sample from g n_children times
n_new_children = zeros(n_trials,1);
n_new_children2 = zeros(n_trials,1);

for tr = 1:n_trials
    new_children = false(1,n);
    for c = 1:n_children
        % draw from G to get n_children
        %select_vec = rand(1,n).*g_p.*(~is_failed);
        %select_vec = rand(1,n).*g_p;
        % Find the new children using a sequence of Bernoulli trials
        n_new_children2 = n_new_children2 + sum(rand(1,n)<g_row);
        new_children = new_children | rand(1,n)<g_row;
        %indices = find_max_k(select_vec,n_children,true);
        %new_children(indices) = true;
    end
    n_new_children(tr) = sum(new_children);
end

mean(n_new_children)
