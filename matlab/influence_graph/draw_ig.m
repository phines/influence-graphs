function draw_ig(ps,ig_F,ig_G,files_only)
% usage: draw_ig(ps,F,G)

WIDTH_BASE = 10;
n = length(ig_F);
if nargin<4
    files_only=false;
end

%% Constants and stuff
C = psconstants;
m = size(ps.branch,1);
%n = size(ps.bus,1);

%% find the link locations
%disp('finding the link locations');
% node locations
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
% link locs
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
x_link = (x(F) + x(T))/2;
y_link = (y(F) + y(T))/2;

%% draw the actual graph
if ~files_only
    disp('Drawing');
    % draw the transmission lines
    hold on;
    axis off;
    for i = 1:m
        f = ps.bus_i(ps.branch(i,1));
        t = ps.bus_i(ps.branch(i,2));
        line([x(f) x(t)],[y(f) y(t)],'Color',[.9 .9 .9],'LineWidth',0.5);
        % link numbers
        %text(mean(x([f t]))+.02,mean(y([f t])),num2str(i));
    end
end

%% Now draw the virtual links
[g_from,g_to,g_weight] = find(ig_G);
if ~files_only
    for i = 1:length(g_from)
        f = g_from(i);
        t = g_to(i);
        width = g_weight(i)*WIDTH_BASE;
        line([x_link(f) x_link(t)],[y_link(f) y_link(t)],'Color','k','LineWidth',width);
    end
end

%% Also write the results to gdf and dot files
% Build the nodes matrix
nodes = zeros(n,4);
node_ix = union(g_from,g_to);
nodes(:,1) = node_ix;
nodes(:,2) = x_link;
nodes(:,3) = y_link;
nodes(:,4) = ig_F;
% Make the node names
for i = 1:m
    f = ps.branch(i,1);
    t = ps.branch(i,2);
    nodenames{i} = sprintf('%d-%d',f,t); %#ok<AGROW>
end
% Build the links matrix
links = [g_from,g_to,g_weight];
write_gdf(nodes,nodenames,links,1,'ig_6bus.gdf');
write_dot(nodes,nodenames,links,1,'ig_6bus.dot');

%% Also try to plot the thing using qgraph
% Write the edge file
fid = fopen('ig_links.csv','w');
if fid<=0, error('open failed'); end
fprintf(fid,'from,to,width\n');
for i = 1:length(g_from)
    f = nodenames{g_from(i)};
    t = nodenames{g_to(i)};
    width = g_weight(i)*WIDTH_BASE;
    fprintf(fid,'%s,%s,%g\n',f,t,width);
end
fclose(fid);
% Write the node file
fid = fopen('ig_nodes.csv','w');
fprintf(fid,'Id,x,y,vsize\n');
if fid<=0, error('open failed'); end
for i = 1:m
    %f = ps.branch(i,1);
    %t = ps.branch(i,2);
    vsize = ig_F(i);
    %vsize = 5;
    fprintf(fid,'%s,%d,%g,%g\n',nodenames{i},x_link(i),y_link(i),vsize);
end
fclose(fid);
disp('Wrote igraph to ig_links.csv and ig_nodes.csv');
disp('Trying to plot in R');
system('./plot_graph.r');
system('open graph.pdf');

%error('Not really working');
