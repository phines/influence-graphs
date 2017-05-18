function [x,y] = graph_layout(nodes,links,link_len,node_locs,check_with_user)
% Usage: [x,y] = graph_layout(nodes,links,link_len,node_locs)
% Generate x and y coordinates in the range x,y \in [eps,1+eps] using
% "neato"  from the GraphViz project. In order to run this you will need to
% have 'neato' executable somewhere within your machine's search path.
%  nodes - list of node numbers     (size: n x 1)
%  links - list of edge end points  (size: m x 2)
%  link_len - ideal link lengths    (size: m x 1)
%  node_locs - ideal node locations (size: n x 2)


% prep the inputs
nodes = vertical(nodes);
links = vertical(links);
n = size(nodes,1);
m = size(links,1);
if nargin<3, link_len = [];  end
if nargin<4, node_locs = []; end
if nargin<5, check_with_user=false; end
% prep the outputs
x = zeros(n,1);
y = zeros(n,1);

neato_opts = '-v ';

%input and output file names:
infile  = '_Graph_.dot';
outfile = '_Layout_.dot';

% check to make sure that neato is available
if system('neato -V')~=0
    error('Could not run neato');
end

keep_trying = true;
while keep_trying
    % write the graph/dot file
    write_dot(nodes,node_locs,links,link_len,infile);
    
    % execute neato
    command = sprintf('neato %s -o %s %s',neato_opts,outfile,infile);
    system(command);
    if check_with_user
        % draw the graph
        command = sprintf('dot -Tpdf -o graph.pdf %s',outfile);
        system(command);
        open graph.pdf;
        a = input('Do you like this one? [y] > ','s');
        if isempty(a) || a(1)=='y' || a(1)=='Y'
            keep_trying=false;
        end
    else
        keep_trying=false;
    end
    
    % read the resulting output
    [nodes_neato,~,x_neato,y_neato] = read_dot_file(outfile);
    
    for ni = 1:length(nodes)
        name = nodes(ni);
        i_neato = find(nodes_neato==name);
        if ~isempty(i_neato)
            x(ni) = x_neato(i_neato);
            y(ni) = y_neato(i_neato);
        end
    end
end
% normalize x, y to the range [0,1]
%x = normalize(x);
%y = normalize(y);

% delete the temp files
delete(infile);
delete(outfile);

%% write_dot
function write_dot(~,node_locs,links,link_len,infile)

fid = fopen(infile,'w');
fprintf(fid,'  graph G {\n');
%fprintf(fid,'  center=5;\n');
% print some graph properties
%fprintf(fid,'  size="10,10";\n');
fprintf(fid,'  epsilon="0.01";\n');
fprintf(fid,'  mclimit=1.0;\n');
fprintf(fid,'  splines=false;\n');
%fprintf(fid,'  ratio=fill;\n');
%fprintf(fid,'  overlap=scale;\n');
%fprintf(fid,'  start=%d;\n',ceil(rand*1e9));

% node
if ~isempty(node_locs)
    fprintf(fid,'  %d [pos="%g,%g"];\n',node_locs');
end
% branches
if ~isempty(link_len)
    for j=1:size(links,1)
        fprintf(fid,'  %d -- %d [dir="none", len=%g];\n',...
            links(j,1), links(j,2), link_len(j) );
    end
else
    for j=1:size(links,1)
        fprintf(fid,'  %d -- %d [dir="none"];\n',...
            links(j,1), links(j,2) );
    end
end

fprintf(fid,'}\n');
fclose(fid);

function vec = normalize(vec)
%eps = 1e-3;

vec = vec - min(vec);
vec = vec / max(vec);
% move to the range [eps 1-eps]
%vec = (vec + eps) / (1+2*eps);

function x = vertical(x)

[rows,cols] = size(x);

if rows < cols
    x = x.';
end


