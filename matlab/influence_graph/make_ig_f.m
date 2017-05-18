function [F,F_dist,P,C] = make_ig_f(n,generations,separate_f0_f1,method)
% build "f" from the influence graph
% usage: [F,F_dist] = make_ig_f(n,generations)
%   n is the number of components
%   generations is either a file name or a matrix, describing the outages
%   method is

% process inputs
% read from a file if specified
if ischar(generations)
    disp('Loading the data');
    generations = sparse(csvread(generations)');
end
% Check the size of things
[sz1,sz2] = size(generations);
% each generation should be in a separate column
if sz1>sz2
    generations = generations';
end
%[~,n_total_gens] = size(generations);

%n_gens = size(generations,1);

if nargin<4
    method = 'mine';
end

% Build F
if strcmp(method,'dobson')
    F = compute_dobson_f(n,generations,separate_f0_f1);
    F_dist = [];
    P = [];
    C = [];
else
    [F,F_dist,P,C] = compute_hines_f(n,generations,separate_f0_f1);
end

end

%% Build F using my method
function [F,F_dist,P,C] = compute_hines_f(n,generations,separate_f0_f1)
    % Initialize stuff
    F0_num = zeros(1,n);
    F1_num = zeros(1,n);
    F0_den = zeros(1,n);
    F1_den = zeros(1,n);
    F0 = zeros(1,n);
    F1 = zeros(1,n);
    if nargout>1
        n_bins = 101;
        F_dist.row_index = 0:(n_bins-1);
        F_dist.F0 = zeros(n_bins,n);
        F_dist.F1 = zeros(n_bins,n);
    end
    n_gens = size(generations,2);
    
    gen_no = 0;
    outages_in_prev_gen = [];
    for g = 1:n_gens
        if rem(g,1e6)==0, fprintf('Completed %d of %d\n',g,n_gens); end
        outages = generations(:,g)';
        outages = outages(outages>0);
        n_out = length(outages);
        outages_in_this_gen = outages;
        % There is nothing to do for the initiating generation
        if gen_no>0
            % numerator is N current over n previous
            num = length(outages_in_this_gen) / length(outages_in_prev_gen);
            % process the data for F
            if gen_no==1 && separate_f0_f1
                F0_num(outages_in_prev_gen) = F0_num(outages_in_prev_gen) + num;
                F0_den(outages_in_prev_gen) = F0_den(outages_in_prev_gen) + 1;
            else
                F1_num(outages_in_prev_gen) = F1_num(outages_in_prev_gen) + num;
                F1_den(outages_in_prev_gen) = F1_den(outages_in_prev_gen) + 1;
            end
            if nargout>1
                % Produce data for a pmf of "num"
                index = min(round(num)+1,n_bins);
                if gen_no==1 && separate_f0_f1
                    % Save the F_dist data
                    values = F_dist.F0(index,outages_in_prev_gen);
                    F_dist.F0(index,outages_in_prev_gen) = values + 1;
                else
                    % Save the F_dist data
                    values = F_dist.F1(index,outages_in_prev_gen);
                    F_dist.F1(index,outages_in_prev_gen) = values + 1;
                end
            end
        end
        
        % check to see if we have reached the end of this cascade
        if n_out==0
            gen_no = 0;
        else
            gen_no = gen_no + 1;
        end
        % save the old outages
        outages_in_prev_gen = outages_in_this_gen;
    end
    
    % Process F
    subset = F0_den>0;
    F0(subset) = F0_num(subset)./F0_den(subset);
    subset = F1_den>0;
    F1(subset) = F1_num(subset)./F1_den(subset);
    
    % Prepare the outputs
    if separate_f0_f1
        F.F0 = F0;
        F.F1 = F1;
        P.P0 = F0_den;
        P.P1 = F1_den;
        C.C0 = F0_num;
        C.C1 = F1_num;
    else
        F = F1;
        if nargout>1
            F_dist = F_dist.F1;
            P = F1_den;
            C = F1_num;
        end
    end
    
end % End of the function

%{
% Process F_dist if requested
if nargout>1
    F_dist.F0 = zeros(10,n);
    F_dist.F1 = zeros(10,n);
    for i = 1:n
        if F0_den(i)>0
            f0_dist_vals = F0_num_dist{i} / F0_den(i);
            F_dist.F0(:,i) = hist(f0_dist_vals,0:10)';
        end
        if F1_den(i)>0
            f1_dist_vals = F1_num_dist{i} / F1_den(i);
            F_dist.F1(:,i) = hist(f1_dist_vals,0:10)';
        end
    end
end
%}

%% Compute F using Ian's method
function F = compute_dobson_f(n,generations,separate_f0_f1)
% usage: F = compute_dobson_f(n,generations,separate_f0_f1)

n_gens = size(generations,1);
% count the generations data
if separate_f0_f1
    n_g0 = 0;
    n_g1 = 0;
    gen_no = 0;
    for g = 1:n_gens
        outages = generations(:,g)';
        n_out = sum(outages>0);
        if n_out==0
            gen_no = 0;
            continue;
        end
        if gen_no==0
            n_g0 = n_g0 + 1; 
        else%if n_out>0
            n_g1 = n_g1 + 1;
        end
        gen_no = gen_no + 1;
    end
end

% initialize A and b
if separate_f0_f1
    A0 = sparse(n_g0,n);
    A1 = sparse(n_g1,n);
    b0 = zeros(n_g0,1);
    b1 = zeros(n_g1,1);
else
    A = sparse(n_gens,n);
    b = zeros(n_gens,1);
end
gen_no = 0;
parents = [];
%children = [];
g0 = 1; % counter
g1 = 1; % counter

disp('Processing the cascades to compute f');
for g = 1:n_gens
    children = generations(:,g)';
    children = children(children>0);
    n_out = length(children);
    % Build A and b matrices
    if gen_no>0
        if separate_f0_f1
            if gen_no==1
                % Mark the parents
                A0(g0,parents) = 1; %#ok<SPRIX>
                % Note the number of children
                b0(g0) = length(children);
                g0 = g0 + 1;
            else
                % Mark the parents
                A1(g1,parents) = 1; %#ok<SPRIX>
                % Note the number of children
                b1(g1) = length(children);
                g1 = g1 + 1;
            end
        else
            % Mark the parents
            A(g,parents) = 1; %#ok<SPRIX>
            % Note the number of children
            b(g) = length(children);
        end
    end
    % check to see if we have reached the end of this cascade
    if n_out==0
        gen_no = 0;
        %parents = [];
        children = [];
    else
        gen_no = gen_no + 1;
    end
    % save the old outages, children become parents
    parents = children;
end
% Now try to solve the system(s)
if separate_f0_f1
    % for Gen 0-1
    F.F0 = f_by_svd(A0,b0);
    % for gen 1+
    F.F1 = f_by_svd(A1,b1);
else
    F = f_by_svd(A,b);
end
%keyboard

end

%% Compute lambda using Ian's SVD method
function lambda = f_by_svd(A,b)

n = size(A,2);
col_subset = sum(A)>0;
[U,S,V] = svd(full(A(:,col_subset)),0);
lambda_sub = V*(S\(U.'*b));
lambda = zeros(1,n);
lambda(col_subset) = lambda_sub;

end