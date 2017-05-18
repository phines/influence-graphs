function results = roulette_wheel(probabilities,n_spins)
% Spin a relette wheel n_spins times.
% The landing probabilities are given by "probabilities"

cumulative_P = cumsum(probabilities);
results = zeros(1,n_spins);

for i=1:n_spins
    r = rand;
    ix = find(r<cumulative_P,1);
    results(i) = ix;
end

results = unique(results); % Removes duplicates; shouldn't make a difference