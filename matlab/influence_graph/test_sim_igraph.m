%% load the data
load polish_influence_graph;
n = size(ps.branch,1);

%% simulate some cascades
outage = [169 96];
verbose = true;
sim_influence_graph( n, F.F0, F.F1, G, outage, verbose );
