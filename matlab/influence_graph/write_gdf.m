function outfile = write_gdf(nodes,nodelabels,links,directed,outfile)
% Write the nodes and links to a gdf (GUESS) data file
% usage: outfile = write_gdf(nodes,nodelabels,links,directed,outfile)
%  nodes has the following columns: id, x, y
%  nodelabels are a set of names/labels for the nodes
%  links has the following columns: from, to, weight
%  directed is a binary indicator
%  outfile is the name of the output file

%% process inputs
n = size(nodes,1);
m = size(links,1);
if isempty(nodelabels)
    for i=1:n
        nodelabels{i} = num2str(nodes(i));
    end
end
if nargin<4 || isempty(directed)
    directed=true;
end
if nargin<5 || isempty(outfile)
    outfile = 'graph.gdf';
end

%% open the output file
out = fopen(outfile,'w');
if out<0, error('open failed'); end

%% write out the nodes
% header
fprintf(out,'nodedef> name VARCHAR,label VARCHAR');
if size(nodes,2)>1
    fprintf(out,',x DOUBLE,y DOUBLE');
    x = nodes(:,2);
    y = nodes(:,3);
end
if size(nodes,2)>3
    fprintf(out,',size DOUBLE');
    node_size = nodes(:,4);
end
if size(nodes,2)>4
    fprintf(out,',color VARCHAR');
end
fprintf(out,'\n');
% data
for i = 1:n
    fprintf(out,'%d,%s',nodes(i,1),nodelabels{i});
    if size(nodes,2)>1
        fprintf(out,',%g,%g',x(i),y(i));
    end
    if size(nodes,2)>3
        fprintf(out,',%g',node_size(i));
    end
    if size(nodes,2)>4
        color = floor(nodes(:,4:6)*256);
        fprintf(out,',''%d,%d,%d''',color(1),color(2),color(3));
    end
    fprintf(out,'\n');
end
% write out the links
fprintf(out,'edgedef> node1 VARCHAR, node2 VARCHAR, weight DOUBLE\n');
weight = 1;
for i=1:m
    f = links(i,1);%;nodelabels{links(i,1)};
    t = links(i,2);%nodelabels{links(i,2)};
    if size(links,2)>2
        weight = links(i,3);
    end
    fprintf(out,'%d,%d,%g\n',f,t,weight);
end

%% close the file
fclose(out);
