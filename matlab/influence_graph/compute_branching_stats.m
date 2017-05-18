function stats = compute_branching_stats(generations,event_gen_counter_Z,print_table,add_to_z0)
% usage: stats = compute_branching_stats(generations,event_gen_counter_Z,print_table,add_to_z0)
% Compute Dobson branching process statistics
MAX_GENS = 1000;

cascade_i = 1; % cascade no counter;
cascade_sizes = 0;
% if this is a file name, read the file
if ischar(generations)
    generations = sparse(csvread(generations)'); % Convert rols to columns;
end
% Check the size of things
[sz1,sz2] = size(generations);
% each generation should be in a separate column
if sz1>sz2
    generations = generations';
end
[~,n_total_gens] = size(generations);

% See if we need to build the event counter
if nargin<2 || isempty(event_gen_counter_Z)
    % and build it
    event_gen_counter_Z = zeros(MAX_GENS,1);
    
    gen_no = 0;
    max_gens = 0;
    for g = 1:n_total_gens
        outages = generations(:,g); % faster to iterate through columns
        %outages = outages(outages>0);
        if rem(g,1e6)==0, fprintf('Completed %d of %d\n',g,n_total_gens); end 
        n_out = full(sum(outages>0));
        cascade_sizes(cascade_i) = cascade_sizes(cascade_i) + n_out; %#ok<*AGROW>
        if n_out>0
            event_gen_counter_Z(gen_no+1) = event_gen_counter_Z(gen_no+1) + n_out;
        end
        %if gen_no>1 && n_out>0
        %    keyboard
        %end
        
        % update the generation counter
        if n_out>0
            gen_no = gen_no + 1;
            max_gens = max(gen_no,max_gens);
            %if gen_no>1
            %    keyboard
            %end
        else
            gen_no = 0;
            cascade_i = cascade_i + 1;
            cascade_sizes = cat(1,cascade_sizes,0);
        end
    end
else
    max_gens = sum(event_gen_counter_Z>0);
end
% remove the last element of cascade_sizes
cascade_sizes(end) = [];
% Print a table
if nargin<3
    print_table=true;
end
% tweak in case we are only listing the cascades in the dataset
if nargin>3
    event_gen_counter_Z(1) = event_gen_counter_Z(1) + add_to_z0;
end

%% Compute the statistics
% chop off the zeros on the end of the event counter
while event_gen_counter_Z(end)==0
    event_gen_counter_Z(end) = [];
end
event_gen_counter_Z = [event_gen_counter_Z' 0];
stats.event_gen_counter_Z = event_gen_counter_Z; 
stats.lambda = (event_gen_counter_Z(2:end) ./ event_gen_counter_Z(1:(end-1)));
stats.lambda = [stats.lambda 0]; % append a 0
stats.max_gens = max_gens;
stats.lambda_overall = sum(event_gen_counter_Z(2:end)) / sum(event_gen_counter_Z(1:(end-1)));
stats.cascade_sizes = cascade_sizes;
%% Print a table of results
if print_table
    disp('Gen.,  # outages, Lambda');
    for i = 1:stats.max_gens
        fprintf('% 2d,  % 7d, %g\n',...
            i-1,stats.event_gen_counter_Z(i),stats.lambda(i));
    end
    fprintf('Overall lambda = %g\n\n',stats.lambda_overall);
end

% %%
% 
% 
% lambda0 = gen_no_counts(2) / gen_no_counts(1)
% n_parents = sum(gen_no_counts(2:(end-1)));
% n_kids = sum(gen_no_counts(3:end));
% lambda1 = n_kids / n_parents
% % 
% n_gens = length(lambda);
% disp('Generation number, counts, lambda');
% data = [(0:n_gens)' gen_no_counts [lambda;NaN]];
% fprintf(' % 2d,  % 6d,  %.6f\n',data(1:20,:)');
% 
