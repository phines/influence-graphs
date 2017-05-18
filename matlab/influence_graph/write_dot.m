function write_dot(nodes,nodelabels,links,edgelabels,directed,outfile)
% usage: write_dot(nodes,nodelabels,links,edgelabels,directed,outfile)

%% process inputs
nodes = full(nodes);
links = full(links);
n = size(nodes,1);
m = size(links,1);
if isempty(nodelabels)
    for i=1:n
        nodelabels{i} = sprintf('v%d',i);
    end
end
if isempty(edgelabels)
    for j=1:m
        edgelabels{j} = sprintf('e%d',j);
    end
end
if nargin<4 || isempty(directed)
    directed=true;
end
if nargin<5 || isempty(outfile)
    outfile = 'graph.gdf';
end

% grab the location data
if size(nodes,2)>2
    x = nodes(:,2);
    y = nodes(:,3);
    locations = true;
else
    locations = false;
end
% grab the edge weight data
if size(links,2)>2
    weights = links(:,3);
    weighted = true;
else
    weighted = false;
end

% build a node index map
node_ix = sparse(nodes(:,1),1,(1:n)',max(nodes(:,1)),1);

%% open the output file
out = fopen(outfile,'w');
if out<0, error('open failed'); end

%% Write the header info
if directed
    fprintf(out,'digraph G {\n');
else
    fprintf(out,'graph G {\n');
end

%fprintf(out,'  center=5;\n');
% print some graph properties
%fprintf(out,'  size="10,10";\n');
%fprintf(out,'  epsilon="0.01";\n');
%fprintf(out,'  mclimit=1.0;\n');
%fprintf(out,'  splines=false;\n');
%fprintf(out,'  ratio=fill;\n');
%fprintf(out,'  overlap=scale;\n');
%fprintf(out,'  start=%d;\n',ceil(rand*1e9));

%% write node info
for i = 1:n
    fprintf(out,'  %s ',nodelabels{i});
    if locations
        fprintf(out,'[pos="%g,%g"]',x(i),y(i));
    end
    fprintf(out,';\n');
end

%% Link information
for j = 1:m
    f = nodelabels{node_ix(links(j,1))};
    t = nodelabels{node_ix(links(j,2))};
    % write the edge
    if directed
        fprintf(out,'  %s -> %s ',f,t);
    else
        fprintf(out,'  %s -- %s ',f,t);
    end
    fprintf(out,'[');
    % edge names
    fprintf(out,'label=%s',edgelabels{j});
    % write the weight
    if weighted
        fprintf(out,',weight=%.8f',weights(j));
    end
    fprintf(out,']');
    % finish
    fprintf(out,';\n');
end

%% Close the file
fprintf(out,'}\n');
fclose(out);
