function [nodes,links] = random_graph(n,m)
% Produce a random graph without self loops

nodes = (1:n)';
links = zeros(m,2);

for j = 1:m
    node1 = randi(n);
    node2 = randi(n);
    while node2==node1
        node2 = randi(n);
    end
    links(j,:) = [node1 node2];
end
