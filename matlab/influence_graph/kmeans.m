function cluster_id = kmeans(coordinates,K)
% divide the data in matrix into k clusters
% usage: cluster_id = kmeans(coordinates,k)

n = size(coordinates,1);
cluster_id = zeros(n,1);

%% choose k points as initial centroids
% using my extrema method

% Start with the centroid at the system mean
centroid_coordinates = mean(coordinates);

centroids = zeros(K,1);
for k = 1:K
    % Find the point furthest from this mean
    distances = zeros(n,1);
    for i = 1:n
        node_coordinates = coordinates(i,:);
        distances(i) = sum( (node_coordinates - centroid_coordinates).^2 );
    end
    [~,centroids(k)] = max(distances);
%     if k==2
%         coordinates
%         centroids
%         distances
%     end
    % Find the centroid of the centroids
    centroid_coordinates = mean(coordinates(centroids(1:k),:),1);
end
%centroids
%keyboard
% Random centroid method
% centroids = [];
% while length(centroids)<K
%     centroids = unique(randi([1 n],[K 1]));
% end
centroid_coordinates = coordinates(centroids,:);

%% Main loop
while 1
    new_cluster_id = cluster_id;
    % for each node find the distance between this node and the k centroids
    for i = 1:n
        distances = zeros(K,1);
        node_coordinates = coordinates(i,:);
        for k = 1:K
            distances(k) = sum( (node_coordinates - centroid_coordinates(k,:)).^2 );
        end
        % assign this node to its nearest cluster
        [~,new_cluster_id(i)] = min(distances);
    end
    % Now find the "centroid" of each cluster
    for k = 1:K
        subset = new_cluster_id==k;
        n_sub = sum(subset);
        if n_sub==0
            continue;
        end
        subset_coordinates = coordinates(subset,:);
        centroid_coordinates(k,:) = mean(subset_coordinates,1);
    end
    % Figure out how much we have changed
    n_change = sum(new_cluster_id~=cluster_id);
    if n_change<1/n
        break;
    end
    %new_cluster_id;
    %
    % Assign the new cluster ids
    cluster_id = new_cluster_id;
end

