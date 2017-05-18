clear all;
% General prep work
addpath('../dcsimsep');
addpath('../dcsimsep/data');
opt = psoptions;
C = psconstants;
% Load the data
load polish_G_lambda;
G_lambda = Glam;
load case2383_mod_ps;
% Get the power grid/graph data
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
f = ps.bus_i(ps.branch(:,1));
t = ps.bus_i(ps.branch(:,2));
x_link = (x(f) + x(t))/2;
y_link = (y(f) + y(t))/2;

% Collect the basic grid graph data
nodes_grid = ps.bus(:,1);
locs_grid = [x y];
flow = abs(ps.branch(:,C.br.Pf));
links_grid = [ps.branch(:,1:2) flow];

% Collect the basic igraph grid data
[from,to,weight] = find(G_lambda);
m = size(ps.branch,1);
nodes_igraph = (1:m)';
locs_igraph = [x_link y_link];
links_igraph = [from to weight];

%% save the results
save polish_igraph_data nodes_grid locs_grid links_grid nodes_igraph locs_igraph links_igraph G_lambda
