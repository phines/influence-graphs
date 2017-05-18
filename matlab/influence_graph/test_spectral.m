clear all;
% make 2 random graphs and connect them
n_sub = 100;
m_sub = 200;
n_inter = 5;
[nodes1,links1] = random_graph(n_sub,m_sub);
[nodes2,links2] = random_graph(n_sub,m_sub);
nodes = [nodes1;(nodes2 + n_sub)];
links = [links1;(links2 + n_sub)];
% add interlinks that connect the two
for i = 1:n_inter
    node1 = randi(n_sub);
    node2 = randi(n_sub) + n_sub;
    links = [links;[node1 node2]]; %#ok<AGROW>
end
n = length(nodes);
m = size(links,1);

% do a graph layout
[x,y] = graph_layout(nodes,links);
locs = [x,y];
% Do kmeans on the location data
figure(1);clf;
clusters_kmeans = kmeans(locs,2);
draw_graph(nodes,links,locs,[],clusters_kmeans);
title('K-means on locations');

A = adjacency(nodes,links);
D = diag(sum(A,2));

Dinv_sqrt = diag(sum(A,2).^(-1/2));
Lnorm = speye(n) - Dinv_sqrt*A*Dinv_sqrt;

%% Standard Laplacian method
figure(2); clf;
clusters_spectral1 = spectral_clustering(A,2,'Laplacian');
draw_graph(nodes,links,locs,[],clusters_spectral1);
title('Spectral with simple Laplacian');

%% Lnorm
figure(3);clf;
clusters_spectral2 = spectral_clustering(A,2,'Lnorm');
draw_graph(nodes,links,locs,[],clusters_spectral2);
title('Spectral with Lnorm');

