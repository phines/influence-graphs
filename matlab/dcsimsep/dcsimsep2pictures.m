function dcsimsep2pictures(ps,branch_outages,bus_outages,opt,dir_name)
% usage: dcsimsep2pictures(ps,branch_outages,bus_outages,opt,dir_name)
% Makes a sequence of jpg pictures for the simulation specified by:
%  ps,branch_outages,bus_outages,opt
% See dcsimsep for details

% Set up figure stuff
close all;
ScaleFactor = 1;
figure('Position',[200 200 1280 720]);
set(gcf,'PaperPositionMode','auto')
set(gcf, 'Color', 'w');

% Create a directory for the output
if nargin<5
    dir_name = 'dcsimsep_pictures';
end
% Make a directory for the outputs
mkdir(dir_name);

% Prepare and run the case:
ps = redispatch(ps);
ps = dcpf(ps);
[is_blackout,~,MW_lost,~,~,movie_data] = dcsimsep(ps,branch_outages,bus_outages,opt);


% Get some data
C = psconstants;
nodes = ps.bus_i(ps.bus(:,1)); % the first column is always the bus/node number
links = ps.bus_i(ps.branch(:,1:2)); % the first two columns in branch are the end points of the branch
locs  = ps.bus(:,C.bu.locs); % locations
x = locs(:,1);
y = locs(:,2);
n = length(nodes);
flow_limit = ps.branch(:,C.br.rateB);
link_status = movie_data.br_status(:,1);
max_load_shedding = max(movie_data.MW_lost);

% Start drawing the pictures
for i = 1:length(movie_data.t)
    t = movie_data.t(i);
    old_link_status = link_status;
    link_status = movie_data.br_status(:,i);
    br_out = find(~link_status & old_link_status);
    flow = movie_data.flows(:,i);
    sub_grids = movie_data.sub_grids(:,i);
    n_subs = length(unique(sub_grids));

    % Initialize the figure
    figure(1);
    % set up the top axis
    subplot(5,1,(1:4)); cla;
    axis off; hold on;
    axis([min(x),max(x),min(y),max(y)]);
    % draw the links
    plot_links(nodes,links,locs,flow,flow_limit,link_status);

    % Plot the nodes
    plot_nodes(locs,sub_grids);
    
    % Write something
    %title(sprintf(' t = %6.2f',t));
    fprintf(' t = %6.2f, n_sub = %d\n',t,n_subs);
    
    % Plot the amount of load shedding;
    subplot(5,1,5); cla;
    plot(movie_data.t(1:i),movie_data.MW_lost(1:i),'r-');
    hold on;
    plot(movie_data.t(i),movie_data.MW_lost(i),'ko');
    ylabel('Load shedding');
    xlabel('Time (seconds)');
    axis([0,max(movie_data.t),0,max(movie_data.MW_lost)]);
    set(gca,'box','off');

    drawnow
    figname = sprintf('%s/frame_%03d.jpg',dir_name,i);
    print(sprintf('-r%d',90*ScaleFactor), '-djpeg', figname );
    %pause(0.1);
end

function plot_links(~,links,locs,flow,flow_limit,link_status)

base_width = 50;
%GREY = [1 1 1]*.5;

m = size(links,1);

overloaded = find(abs(flow)>=flow_limit)';
outaged = find(~link_status)';
not_overloaded = find(link_status & abs(flow)<flow_limit)';

% Draw the not overloaded lines
for i=not_overloaded
    link = links(i,1:2);
    X = locs(link,1);
    Y = locs(link,2);
    width = max(abs(flow(i))/base_width,0.5);
    line( X, Y, 'color', 'g', 'linewidth', width);
end

% Draw the overloaded lines
for i = overloaded
    link = links(i,1:2);
    X = locs(link,1);
    Y = locs(link,2);
    width = max(abs(flow(i))/base_width,0.5);
    line( X, Y, 'color', 'r', 'linewidth', width);
end

% Draw the outaged lines
for i = outaged
    link = links(i,1:2);
    X = locs(link,1);
    Y = locs(link,2);
    line( X, Y, 'color', 'k', 'linewidth', 5 );
end

function plot_nodes(locs,sub_graphs)

n_sub = length(unique(sub_graphs));
map = colormap('hsv');
randseed(1); % deterministic randomness
R = randperm(size(map,1));
node_size = 15;

colors = map(R,:);
nc = length(colors);

for g = 1:n_sub
    % draw the nodes
    ci = mod(g,nc);
    if ci==0,ci=length(colors);end
    color = colors(ci,:);
    loc_set = locs(sub_graphs==g,:);
    plot(loc_set(:,1),loc_set(:,2),'.',...
        'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerSize',node_size);
end


