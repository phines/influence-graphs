function [G,G_num,G_den] = make_ig_g(n,generations,separate_g0_g1)
% build "f" from the influence graph
% usage: [F,F_dist] = make_ig_f(n,generations)
%   n is the number of components
%   generations is either a file name or a matrix, describing the outages
%   

%% process inputs
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
n_total_gens = size(generations,2);

if separate_g0_g1
    error('separate_g0_g1 not working yet');
end

%% Init the outputs
% G
G = zeros(n,n);
G_num = zeros(n,n);
G_den = zeros(n,1);

%% Build G
gen_no = 0;
parent_outages = [];
disp('Processing the cascades');
for gen_i = 1:n_total_gens
    if rem(gen_i,1e6)==0, fprintf('Completed %d of %d\n',gen_i,n_total_gens); end
    outages = generations(:,gen_i)';
    outages = outages(outages>0);
    n_out = length(outages);
    child_outages = outages;
    % There is nothing to do for the initiating generation
    if gen_no>0 && ~isempty(child_outages)
        % Find the numerator
        num = 1/length(parent_outages);% or 1
        for p = parent_outages
            % Numerator
            G_num(p,child_outages) = G_num(p,child_outages) + num;
            % Find the denominator
            G_den(p) = G_den(p) + num*length(child_outages); % This is the total number of children produced by p
            %keyboard
            if any(p==child_outages) || G_num(p,p)>0
                error('Something funny happened.');
            end
        end
        
    end
    
    % check to see if we have reached the end of this cascade
    if n_out==0 
        gen_no = 0;
        %child_outages = [];
        parent_outages = [];
    else
        gen_no = gen_no + 1;
        % All the children now become parents
        parent_outages = child_outages;
        %child_outages = [];
    end
end

for i = 1:n
    if  G_den(i)>0
        G(i,:) = G_num(i,:) / G_den(i);
    else
        %G(i,:) = 1/n;
    end
end

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

return