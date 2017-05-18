function [A,num2index] = adjacency(nodes,links,binary,directed)
% usage: [A,num2index] = adjacency(nodes,links,binary,directed)
% returns the adjacency matrix for a set of nodes and links
%  if requested will return an  index telling us where to find
%  particular nodes
% if binary==true, then duplicates 

if nargin<3 || isempty(binary)
    binary = true;
end
if nargin<4
    directed = false;
end

n = length(nodes);
nodes = reshape(nodes,n,1);
%m = size(links,1);

num2index = sparse(nodes,1,(1:n),max(nodes),1);

F = num2index(links(:,1)); % from end of each link
T = num2index(links(:,2)); % to end of each link

if directed
    A = sparse(F,T,1,n,n);
else
    A = sparse(F,T,1,n,n) + ...
        sparse(T,F,1,n,n);
end
if binary
    A(A>1) = 1; % this line is needed because sparse adds parallel items together
end
