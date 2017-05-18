function cluster_id = spectral_clustering(A,n_clusters,method)
% Use spectral clustering to divide the network described by A
%  into subgraphs. 
% A can be a Laplacian, adjacency matrix, or whatever
% usage: cluster_id = spectral_clustering(A,n_clusters)


%% Check the inptus
[n,m] = size(A);
if n~=m
    error('matrix A should be square');
end
if n_clusters<2
    error('No point in making < 2 clusters');
end
if nargin<3
    method = 'largest';
end

%% Initialize the output
cluster_id = zeros(n,1);

%% Find subgraphs in A
[subgraphs,n_subgraphs] = find_subgraphs(A+A.');
if n_subgraphs == 1
    Asub = A;
else
    sz = zeros(n_subgraphs,1);
    for i = 1:n_subgraphs
        sz(i) = sum(subgraphs==i);
    end
    [~,biggest_sub] = max(sz);
    subset = find(subgraphs==biggest_sub);
    Asub = A(subset,subset);
end
n_sub = size(Asub,1);

%% Find the appropriate set of eigenvectors
%is_symm = issymmetric(Asub);
if     strcmpi(method,'largest')
    [eigenvectors,~] = eigs(Asub,n_clusters,'LM');
elseif strcmpi(method,'smallest')
    [eigenvectors,~] = eigs(Asub,n_clusters,'SM');
elseif strcmpi(method,'laplacian')
    D = diag(sum(Asub,2));
    L = (D - Asub);
    [eigenvectors,~] = eigs(L,n_clusters,'SM');
elseif strcmpi(method,'Lnorm')
    Dinv_sqrt = diag(sum(Asub,2).^(-1/2));
    Lnorm = speye(n_sub) - Dinv_sqrt*Asub*Dinv_sqrt;
    [eigenvectors,~] = eigs(Lnorm,n_clusters,'SM');
end

%% Now do kmeans clustering using these coordinates
cluster_id_sub = kmeans(eigenvectors,n_clusters);

%% Assign the output
if n_subgraphs == 1
    cluster_id = cluster_id_sub;
else
    cluster_id(subset) = cluster_id_sub;
end

