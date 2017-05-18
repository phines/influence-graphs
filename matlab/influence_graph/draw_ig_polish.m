%% Draw the physical network
% Load stuff
addpath('../dcsimsep');
addpath('../dcsimsep/data');
opt = psoptions;
C = psconstants;
% load the case data
load case2383_mod_ps;
% location data
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
% draw the physical graph
figure(1); clf;
nodes = ps.bus(:,1);
links = ps.branch(:,1:2);
draw_graph(nodes,links,[x y],[],[.5 .5 .5]);
%(nodes,links,locs,node_labels,node_colors,link_colors)

%% crit branches
crit_data = [...
    9	11	4	33.485
16	7	5	107.98
18	309	5	45.502
19	309	5	45.502
38	17	11	41.181
90	29	32	35.431
261	1649	115	36.831
789	505	493	34.758
1029	683	679	47.413
2423	1881	1873	30.668
];

f = ps.bus_i(ps.branch(:,1));
t = ps.bus_i(ps.branch(:,2));
x_link = (x(f) + x(t))/2;
y_link = (y(f) + y(t))/2;

ss=[18 19];%crit_data(crit_data(:,4)>40,1);
plot(x_link(ss),y_link(ss),'rx');
    

%% draw the influence graph
f = ps.bus_i(ps.branch(:,1));
t = ps.bus_i(ps.branch(:,2));
x_link = (x(f) + x(t))/2;
y_link = (y(f) + y(t))/2;
m = length(f);
