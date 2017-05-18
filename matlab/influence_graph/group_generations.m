function [out_fname,outage_counts] = group_generations(event_type,out_time,br_no,max_delta_t,out_fname)
% group (branch/component) outages into generations using the Dobson method

%% Constants
TYPE_STOP = -1;
TYPE_ENDO = 1;
TYPE_EXO  = 0;

%% Prep work
n_events = length(br_no);
% open a file
if nargin>4
    outf = fopen(out_fname,'a');
else
    outf = fopen('generations.csv','a');
end
if outf<1
    error('cound not open file');
end
outage_counts = zeros(1,50);

%% group the data into generations
first = 1;
n_cascade = 0;
this.time=[];
this.br_no=[];
this.type=[];
this.n=0;
% loop through the events
while first<n_events
    progressbar(first/n_events)
    % find the stop event in this cascade
    for j = first:n_events
        if event_type(j)==TYPE_STOP
            last = j;
            break
        end
    end
    if event_type(last)~=TYPE_STOP
        error('something went wrong');
    end
    % remember the previous generation
    prev = this;
    % collect the outages in this cascade
    this.time  = out_time(first:last)';
    this.br_no = br_no(first:last)';
    this.type  = event_type(first:last)';
    this.n     = length(this.br_no);
    % find the amount of time from the current event until the next event
    this.delta_t = [0 (this.time(2:this.n) - this.time(1:(this.n-1)))];
    % split the outages into generations
    gen_no = 0;
    this_gen = [];
    for k=1:this.n
        % figure out what to do with the event, based on type
        switch this.type(k)
            % if this is an exo event, just stick it into the current
            % generation
            case TYPE_EXO
                this_gen = cat(2,this_gen,k);
            case TYPE_ENDO
                if gen_no>0 && this.delta_t(k)<max_delta_t
                    this_gen = cat(2,this_gen,k);
                else % we found a new generation
                    % record the old generation in the file
                    fprintf(outf,'%d,',this.br_no(this_gen));
                    fprintf(outf,'\n');
                    % also record the number of events
                    outage_counts(gen_no+1) = ...
                        outage_counts(gen_no+1) + length(this_gen);
                    gen_no = gen_no + 1;
                    % initiate the new generation
                    this_gen = k;
                end
            case TYPE_STOP
                % record the old generation
                fprintf(outf,'%d,',this.br_no(this_gen));
                fprintf(outf,'\n');
                % also record the number of events
                outage_counts(gen_no+1) = ...
                    outage_counts(gen_no+1) + length(this_gen);
                % write a stop event to the output file
                fprintf(outf,'-1\n');
                % start clean
                this_gen = [];
            otherwise 
                error('Bad event type');
        end
        
    end
    % Check for strange conditions
    %if any(ismember(this.br_no,prev.br_no))
    %    error('This doesn''t make sense');
    %end
    % increment my counters
    first = first + this.n;
    n_cascade = n_cascade+1;
end
% close the output file
fclose(outf);

% remove zeros from the outage counter
outage_counts = outage_counts(outage_counts>0);
outage_counts = [outage_counts 0];

return
%{
%% save the results
%save(sprintf('%s_influence_graph_data',casename));
%end

%% tally the generational results
lambda = gen_no_counts(2:end) ./ gen_no_counts(1:(end-1));
lambda_total = sum(gen_no_counts(2:end)) / sum(gen_no_counts(1:(end-1)))
lambda0 = gen_no_counts(2) / gen_no_counts(1)
n_parents = sum(gen_no_counts(2:(end-1)));
n_kids = sum(gen_no_counts(3:end));
lambda1 = n_kids / n_parents
% 
n_gens = length(lambda);
disp('Generation number, counts, lambda');
data = [(0:n_gens)' gen_no_counts [lambda;NaN]];
fprintf(' % 2d,  % 6d,  %.6f\n',data(1:20,:)');

%% build F
F0 = F0_num ./ F0_den;
F1 = F1_num ./ F1_den;
ss = F0_den>0;
lambda0_ = sum(F0(ss).*F0_den(ss)) / sum(F0_den(ss)) % weighted mean
ss = F1_den>0;
lambda1_ = sum(F1(ss).*F1_den(ss)) / sum(F1_den(ss)) % weighted mean

%% make some plots
ss = (F1>0);
figure(1);
hist(F1(ss),40,'width',.9);
h = findobj(gca,'Type','patch'); % get a handle to the hist bars
set(h,'FaceColor',[0 .5 .5],'EdgeColor','none') % set the edge color
title('histogram of the non-zero \lambda_{f1} data');
%%
figure(2);
hist(F0(ss),40,'width',.9);
h = findobj(gca,'Type','patch'); % get a handle to the hist bars
set(h,'FaceColor',[0 .5 .5],'EdgeColor','none') % set the edge color
title('histogram of the non-zero \lambda_{f0} data');
%%
figure(3);
plot(F0(ss),F1(ss),'ko','markersize',5);
r = corr(F0(ss),F1(ss))
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('\lambda_{f0}');
ylabel('\lambda_{f1}');
title('Scatterplot showing the propagation rate for generation 0-1 (\lambda_{f0}) vs the propagation rate for susequent generations (\lambda_{f1})');
%%
figure(4);
plot(flow(ss),F1(ss),'ko','markersize',5);
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('Base case power flow (absolute)');
ylabel('\lambda_{f1}');
title('lambda_{f1} vs. pre-contingency power flow');


%% save some stuff
save(sprintf('igraph_data_%s',casename),'F0','F1','lambda0','lambda1','lambda','gen_no_counts');
f = fopen('polish_lambda_f','w');
fprintf(f,'F0: ');
fprintf(f,'%g,',F0);
fprintf(f,'\n');
fprintf(f,'F1: ');
fprintf(f,'%g,',F1);
fprintf(f,'\n');
fclose(f);

return

%% now build the "f" vector
count_f = zeros(1,n_br);
denom_f = zeros(1,n_br);

for c = 1:n_cascade
    ng = length(cascade(c).gen);
    for g = 1:ng
        O_g = cascade(c).gen(g).outages;
        if g==ng
            O_g_next = [];
        else
            O_g_next = cascade(c).gen(g+1).outages;
        end
        lambda_g = length(O_g_next) / length( O_g );
        % Count stuff for building the branching data
        count_f(O_g) = count_f(O_g) + lambda_g;
        denom_f(O_g) = denom_f(O_g) + 1;
    end
end

f = count_f ./ denom_f;

%% now build the "g" matrix
count_g = zeros(n_br,n_br);

for c = 1:n_cascade
    ng = length(cascade(c).gen);
    for g = 1:ng
        O_g = cascade(c).gen(g).outages;
        if g==ng
            O_g_next = [];
        else
            O_g_next = cascade(c).gen(g+1).outages;
        end
        lambda_g = length(O_g_next) / length( O_g );
        % Count stuff for building the branching data
        count_f(O_g) = count_f(O_g) + lambda_g;
        denom_f(O_g) = denom_f(O_g) + 1;
    end
end

f = count_f ./ denom_f;
%}
