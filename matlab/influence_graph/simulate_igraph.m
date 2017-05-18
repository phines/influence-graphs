function gen_file = simulate_igraph(F,G,samples,p_out,fname,gen_max)
% usage: gen_file = simulate_igraph(F,G,n_samples,p_out,fname,gen_max)
%  or
%        gen_file = simulate_igraph(F,G,samples,[],fname)
% Inputs:
%  F - the parameters for the F distribution (n x 1)
%  G - the parameters for the G distribution (n x n)

% First input
if isstruct(F)
    F0 = F.F0;
    F1 = F.F1;
    n = length(F.F0);
else
    n = length(F);
    F0 = F;
    F1 = F;
end
% Second input
assert(size(G,1)==n);
assert(size(G,2)==n);
% Third input
if isscalar(samples)
    n_samples = samples;
    MC_sampling = true;
else
    n_samples = size(samples,1);
    MC_sampling = false;
end
% Fourth input
%assert(length(p_out)==n);
% Fifth, open the output file
if nargin<5
    fname = 'generations_sim.csv';
end
fout = fopen(fname,'w');
% Sixth, gen_max
if nargin<6, gen_max = Inf; end

% iterate
for i = 1:n_samples
    % status update
    if rem(i,1e5)==0, fprintf('Running sim %d of %d\n',i,n_samples); end
    % find the independent outage
    if MC_sampling
        exo_outages = find(rand(n,1)<p_out)';
    else
        exo_outages = samples(i,:);
        exo_outages = exo_outages(exo_outages>0);
    end
    parents = exo_outages;
    assert(size(exo_outages,1)<=1);
    is_failed = false(1,n);
    gen_no = 0;
    while ~isempty(parents)
        is_failed(parents) = true;
        assert(size(parents,1)<=1);
        % Save the outages to a file
        for p = 1:(length(parents)-1)
            fprintf(fout,'%d,',parents(p));
        end
        fprintf(fout,'%d\n',parents(end));
        if gen_no>=gen_max
            break;
        end
        % Find children for each parent
        children = false(1,n);
        % Figure out which F to use
        if gen_no == 0
            F = F0;
        else
            F = F1;
        end
        for p = parents
            % Grab the row from g
            g_p = G(p,:);
            n_children_max = sum(g_p>0);
            % draw from F to figure out how many children
            n_children = trunk_poiss_rnd(F(p),n_children_max);
            new_children = false(1,n);
            for c = 1:n_children % draw from G to get n_children
                % Option 1: Roullette wheel - produces too many kids
                %child_indices = roulette_wheel(g_p,n_children);
                %new_children(child_indices) = true;
                
                % Option 2: Goofball sampling
                %select_vec = rand(1,n).*g_p.*(~is_failed);
                %select_vec = rand(1,n).*g_p;
                %select_vec = (g_p - rand(1,n));%rand(1,n) - g_p;
                %indices = find_max_k(select_vec,n_children,true);

                % Option 3: Bernoulli trials
                % Find the new children using a sequence of Bernoulli trials
                new_children = new_children | rand(1,n)<g_p;
            end
            % combine the new children with the existing ones
            children = (children|new_children)&(~is_failed);% remove already failed components from children (can't fail twice)
            gen_no = gen_no + 1;
        end
        % Now all the parents become children
        parents = find(children);
    end
    % we have come to the end of the cascade, therefore quit
    fprintf(fout,'-1\n');
end
fclose(fout);

gen_file = fname;
