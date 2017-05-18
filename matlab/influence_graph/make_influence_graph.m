function [F,G,stats] = make_influence_graph(n,generations,stats)
% build the influence graph
%   generations is either a file name or a matrix, describing the outages
%   

%% process inputs
% read from a file if specified
if ischar(generations)
    generations = csvread(generations);
end


%% Init the outputs
% F
F0_num = zeros(1,n);
F1_num = zeros(1,n);
F0_den = zeros(1,n);
F1_den = zeros(1,n);
F0 = zeros(1,n);
F1 = zeros(1,n);

% G
G = zeros(n,n);
G_num = G;
%G_den = G_num;

%% Build F and G
gen_no = 0;
outages_in_prev_gen = [];

for g = 1:size(generations,1)
    outages = generations(g,:);
    outages = outages(outages>0);
    n_out = length(outages);
    outages_in_this_gen = outages;
    % There is nothing to do for the initiating generation
    if gen_no>0
        % numerator is N current over n previous
        num = length(outages_in_this_gen) / length(outages_in_prev_gen);
        % process the data for F
        if gen_no==1
            F0_num(outages_in_prev_gen) = F0_num(outages_in_prev_gen) + num;
            F0_den(outages_in_prev_gen) = F0_den(outages_in_prev_gen) + 1;
        else
            F1_num(outages_in_prev_gen) = F1_num(outages_in_prev_gen) + num;
            F1_den(outages_in_prev_gen) = F1_den(outages_in_prev_gen) + 1;
        end
        % process the data for g
        G_num(outages_in_prev_gen,outages_in_this_gen) = ...
            G_num(outages_in_prev_gen,outages_in_this_gen) + num;
        %G_den(outages_in_prev_gen,:) = G_den(outages_in_prev_gen,:) + 1;
    end
    
    % check to see if we have reached the end
    if n_out==0 
        gen_no = 0;
    else
        gen_no = gen_no + 1;
    end
    % save the old outages
    outages_in_prev_gen = outages_in_this_gen;
end

subset = F0_den>0;
F0(subset) = F0_num(subset)./F0_den(subset);
subset = F1_den>0;
F1(subset) = F1_num(subset)./F1_den(subset);

F.F0 = F0;
F.F1 = F1;

%subset = G_den>0;
% build g

for row = 1:n
    G_row = G_num(row,:);
    if sum(G_row)>0
        G(row,:) = G_num(row,:)/sum(G_num(row,:));
    end
end

return