function cascade_sizes = simple_branching_sim(lambda_0,lambda_1plus,n_runs,n_init)

MAX_GENS = 20;
cascade_sizes = zeros(MAX_GENS,n_runs);

for i = 1:n_runs
    % Status update
    if rem(i,1e6)==0, fprintf('Completed %d of %d simulations\n',i,n_runs); end
    % produce the initiating events
    gen_no = 0;
    n_parents = n_init; % g=0
    while n_parents>0
        % figure out which lambda to use
        if gen_no==0
            lambda = lambda_0;
        else
            lambda = lambda_1plus;
        end
        % start with no kids
        n_children = 0;
        % add kids for each parent
        for p = 1:n_parents
            n_children = n_children + mypoissrnd(lambda);
        end
        % increment gen
        gen_no = gen_no + 1;
        % Save the results
        cascade_sizes(gen_no,i) = n_children;        
        % children become parents
        n_parents = n_children;
    end
end

end



