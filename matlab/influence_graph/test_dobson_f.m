%% Make the true lambda
n = 10;
n_samples = n*100;

for trial = 1:100
    lambda_true = rand(n,1)*1.5;
    
    %% Test Ian's method:
    % Build the A and b matrices
    A_parents  = sparse(n_samples,n);
    b_children = zeros(n_samples,1);
    for i = 1:n_samples
        % Choose some random outages
        outages = randi(n,1,2);
        A_parents(i,outages) = 1; %#ok<SPRIX>
        for o = outages
            b_children(i) = b_children(i) + mypoissrnd(lambda_true(o));
        end
    end
    
    lambda_est1 = A_parents\b_children;
    % SVD method
    [U,S,V] = svd(full(A_parents),0);
    lambda_est2 = V*(S\(U.'*b_children));
    
    
    %% Test my method
    f_num = zeros(n,1);
    f_den = zeros(n,1);
    for i = 1:n_samples
        % Figure out the outages
        outages = find(A_parents(i,:));
        num = b_children(i) / length(outages);
        f_num(outages) = f_num(outages) + num;
        f_den(outages) = f_den(outages) + 1;
    end
    
    lambda_f = f_num./f_den;
    
    %% Show
    %disp(['True  ' 'Dobson  ' 'Dobson  ' 'Hines  ']);
    %[lambda_true lambda_est lambda_est2 lambda_f]
    
    mae(trial,1) = mean(abs(lambda_true-lambda_est));
    mae(trial,2) = mean(abs(lambda_true-lambda_est2));
    mae(trial,3) = mean(abs(lambda_true-lambda_f));
end

mean(mae)
