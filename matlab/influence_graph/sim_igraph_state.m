function simulated_state = sim_igraph_state(F_or_file,G,state_0,generation_m)
% Find the state of the igraph, which started at state_0, at generation_m
% if F_or_file is a file, then simulations are not re-run

%% Simulate if needed
if isstruct(F_or_file)
    F = F_or_file;
    % Find the outage probability
    p_out = 1-state_0;
    n = length(p_out);
    
    % run the simulations
    fname = 'temp_igraph_sim.csv';
    disp('Running the igraph simulations');
    gen_file = simulate_igraph(F,G,10000000,p_out,fname,generation_m);
elseif exist(F_or_file,'file')
    gen_file = F_or_file;
    n = G;
else
    error('first input looks strange');
end

%% Process the data
% read the file
disp('Processing the generations data');
generations = sparse(csvread(gen_file)');

% iterate through and compute an empirical probability
n_gens = size(generations,2);
cascade_counter = 0;
state_sum = zeros(n,generation_m+1);
gen_no = 0;
for g = 1:n_gens
    % read the outages
    outages = generations(:,g)';
    outages = full(outages(outages>0));
    n_out = length(outages);
    % initialize the state
    if gen_no==0
        state = true(n,1);
        cascade_counter = cascade_counter + 1;
    elseif gen_no>generation_m && ~isempty(outages)
        error('This file has too many generations in it');
    elseif gen_no>generation_m
        gen_no=0;
        continue
    end
    %debug
    if 0
        fprintf('Cas %d, gen %d:',cascade_counter,gen_no);
        fprintf('%d,',outages);
        fprintf('\n');
    end
    % update the state
    state(outages) = false;
    % record the state for this generation
    state_sum(:,gen_no+1) = state_sum(:,gen_no+1) + state;
    % if there are no more outages, also record the state to the coming generations
    if gen_no<generation_m && isempty(outages)
        for gen_next = (gen_no+1):generation_m
            state_sum(:,gen_next+1) = state_sum(:,gen_next+1) + state;
        end
    end
    % check to see if this is the end of a cascade
    if n_out==0
        gen_no=0;
    else % there are some outages
        % update the counter
        gen_no = gen_no + 1;
    end
end

%% Compute the output
simulated_state = state_sum / cascade_counter;

end