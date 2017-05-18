clear all;
% Load data
load polish_igraph_data;


%% Scale the igraph matrix
[from,to,weight] = find(G_lambda);
figure(2); clf;
weight_mod = log10(weight/min(weight)*10);
hist(weight_mod,100);
node_subset = unique([from;to]);
% Build an adjacency matrix for the subgraph
nodes_i = (1:length(node_subset))';
e2i = sparse(node_subset,1,nodes_i,max(node_subset),1);
i2e = node_subset;
from_i = e2i(from);
to_i   = e2i(to);
links_i = [from_i to_i weight];
Asub = adjacency(nodes_i,links_i,false,true);

%% Perform the clustering
m = length(nodes_igraph);
clusters = spectral_clustering(Asub,5,'largest');
clusters_all = zeros(m,1);
clusters_all(node_subset) = clusters;

%% Plot the igraph and the grid
% Plot the grid
colormap jet
GRAY = [1 1 1]*0.5;
RED = [1 .5 .5];

figure(1); clf; hold on;
links_grid(:,3) = links_grid(:,3)/100;
nodes_grid = [nodes_grid zeros(size(nodes_grid))];
draw_graph(nodes_grid,links_grid,locs_grid,[],GRAY,GRAY);

figure(1); hold on;
link_subset = weight>0.1;
node_sizes = zeros(m,1);
node_sizes(node_subset) = 1;
nodes_igraph = [nodes_igraph node_sizes];
draw_graph(nodes_igraph,links_igraph(link_subset,:),locs_igraph,[],clusters_all,RED);

return

%% Show a table with the results
% Component names
m = size(ps.branch,1);
n = m;
for i = 1:m
    f = ps.branch(i,1);
    t = ps.branch(i,2);
    br_names{i} = sprintf('%d-%d',f,t); 
end

disp('Branch, cluster');
for i = 1:m
    fprintf('%s, %d\n',br_names{i},clusters(i));
end

%% Plot the clustering results
% bus locations
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
% branch locations
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
x_link = (x(F) + x(T))/2;
y_link = (y(F) + y(T))/2;

nodes = (1:n)';
% find the igraph links;
[from,to,vals] = find(G_lambda);
links = [from to];
draw_graph(nodes,links,[x_link y_link],[],clusters);
