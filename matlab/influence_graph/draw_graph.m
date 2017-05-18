function [locs,base_sizes] = draw_graph(nodes,links,locs,node_labels,node_colors,link_colors,base_sizes)
% usage: locs = draw_graph(nodes,links,locs,node_labels,node_colors,link_colors)
% draws the simple network defined by nodes, links
% -if locs are not given it will call fnGraphLayout to genenerate node locations.
% -relative node sizes may be specified in the second column of nodes.
% -relative link strength/size can be specified in the third column of
%  links.
% -node_labels, link_labels are either a binary value indicating that the
%  node/link numbers should be drawn, or a vector, or cell-vector, of
%  labels that should be placed on the nodes/links


% defaults
EPS = 1e-9;
if nargin<7
    base_sizes.node_size = 20;
    base_sizes.link_width = 1;
end

if nargin<3 || isempty(locs)
    [x,y] = graph_layout(nodes,links);
    locs = [x y];
end
if nargin<4 || isempty(node_labels), node_labels=false; end
if nargin<5 || isempty(node_colors), node_colors='r'; end
if nargin<6 || isempty(link_colors), link_colors=[0.5 0.5 0.5]; end
nodes = vert(nodes);
links = vert(links);
[n,cols] = size(nodes);
if cols<2
    node_size = ones(n,1);
else
    node_size = nodes(:,2);
    nodes = nodes(:,1);
end
[m,cols] = size(links);
if cols<3
    link_strength = ones(m,1);
else
    link_strength = links(:,3);
end

% Fix the node colors if we just specified color indices
[s1,s2] = size(node_colors);
if s1==n && s2==1
    color_index = node_colors;
    min_c = min(color_index);
    max_c = max(color_index);
    cmap = colormap;
    cmap(1,:) = [0 0 0]; %Make index 1 black
    n_color = size(cmap,1);
    color_val = (color_index - min_c)/(max_c-min_c);
    color_index = ceil( color_val*n_color );
    color_index(color_index==0) = 1;
    node_colors = zeros(n,3);
    for i = 1:n
        node_colors(i,:) = cmap(color_index(i),:);
    end
end

% prepare a node index
node_i = sparse(nodes,1,(1:n)',max(nodes),1);

% prepare the graph
hold on;
axis off;

% draw the links
for i=1:m
    link = node_i(links(i,1:2));
    X = locs(link,1);
    Y = locs(link,2);
    if link_strength(i)>0
        line( X, Y, 'LineWidth', link_strength(i)*base_sizes.link_width,'color',link_colors );
    end
end

% draw the nodes
if length(node_labels)>1
    if all(size(node_labels)==[1 1])
        node_labels = nodes;
    end
    for i=1:n
        label = node_labels(i);
        if iscell(label)
            label = label{1};
        end
        if ~ischar(label)
            label = num2str(label);
        end
        text(locs(i,1),locs(i,2),label,'VerticalAlignment','Middle','HorizontalAlignment','Center','BackgroundColor','w');
    end
else
    for i=1:n
        if size(node_colors,1)<n
            c = node_colors(1,:);
        else
            c = node_colors(i,:);
        end
        size_i = base_sizes.node_size*node_size(i);
        if size_i>0
            plot(locs(i,1),locs(i,2),'.','MarkerSize',size_i,'color',c);
        end
    end
end


% vert
function x = vert(x)

[rows,cols] = size(x);

if rows < cols
    x = x.';
end

function x = normalize(x)

if any(x<0)
    x = x - min(x) + 0.1;
end
x = x / mean(x);

