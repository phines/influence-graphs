%% Load stuff
addpath('../dcsimsep');
addpath('../dcsimsep/data');
opt = psoptions;
C = psconstants;
% load the case data
load ../polish_results/before/ps_polish_before.mat;

%% Build the power grid graph
C = psconstants;
% run power flow
ps = dcpf(ps);
flow_mag = abs(ps.branch(:,C.br.Pf));
% draw the case
opt.draw.width = 0.01;
opt.draw.fontsize = 14;
opt.draw.bus_nos = 0;
%figure(1); clf;
nodes = ps.bus(:,1);
links = ps.branch(:,1:2);
locs = ps.bus(:,C.bu.locs);
nodes = [nodes locs];
%draw_graph(nodes,links,locs);
% Remove a branch
%ps.branch(4,C.br.status) = 0;
%ps = dcpf(ps);
%drawps(ps,opt);
n = size(ps.bus,1);
m = size(ps.branch,1);
% node/edge labels
nodelabels = cell(n,1);
for i=1:n
    nodelabels{i} = sprintf('v%d',i); %#ok<*SAGROW>
end
edgelabels = cell(m,1);
for j=1:m
    edgelabels{j} = sprintf('e%d',j);
end
write_dot(nodes,nodelabels,links,edgelabels,false,'polish_power_net.dot');


%% now do a version that has "edge nodes"
% link position data
f = ps.bus_i(ps.branch(:,1));
t = ps.bus_i(ps.branch(:,2));
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
x_link = (x(f) + x(t))/2;
y_link = (y(f) + y(t))/2;

% form the nodes
e_nodes = (1:m)' + 10000;
e_nodes = [e_nodes x_link y_link];
all_nodes = [nodes;e_nodes];
e_nodelabels = cat(1,nodelabels,edgelabels);
% form the links for the left half
F1 = f;
T1 = e_nodes(:,1);
F2 = t;
T2 = e_nodes(:,1);
e_links = [ F1 T1; F2 T2 ];
weights = sqrt([abs(flow_mag);abs(flow_mag)]);
e_links = [e_links weights];
write_dot(all_nodes,e_nodelabels,e_links,[],false,'polish_power_net_2.dot');

%% Now write out the IG
% Load the data and build the influence graphs
load ig_polish_results;

% Collect the igraph data
%H0 = build_Glambda(F.F0,G,false);
H1 = build_Glambda(F.F1,G,false);
[from,to,weights] = find(H1);
% subset the weights
thresh = 0.05;
subset = weights>thresh;
% scale the weights
weights = log10(weights / thresh)*20;
% build nodes/links
ig_nodes = (1:size(links,1))';
ig_links = [from(subset) to(subset) weights(subset)];
figure(1); clf;
hist(weights(subset),100);

% node/edge labels
ig_nodelabels = cell(m,1);
for i=1:m
    ig_nodelabels{i} = sprintf('e%d',i); %#ok<*SAGROW>
end
ig_m = size(ig_links,1);
ig_edgelabels = cell(ig_m,1);
for j=1:ig_m
    ig_edgelabels{j} = sprintf('ig_e%d',j);
end

n_ig_links = size(ig_links,1)

ig_nodes = [ig_nodes x_link y_link];

write_dot(ig_nodes,ig_nodelabels,ig_links,ig_edgelabels,true,'polish_igraph.dot');

%% Write out a simple combined version
return

%% Now write out the combined graph
%subset the igraph links
subset = weights>0.001;
ig_links = ig_links(subset,:);
nodes_combined = [nodes;ig_nodes];
links_combined = [[links ones(m,1)*.001];ig_links];
nodelables_combined = cat(1,nodelabels,ig_nodelabels);
edgelables_combined = cat(1,edgelabels,ig_edgelabels);
write_dot(nodes_combined,nodelables_combined,links_combined,edgelables_combined,true,'polish_combined.dot');


