% test the single contingency graph

% load the data
ps = case30_ps;
ps = updateps(ps);
ps = dcpf(ps);
C = psconstants;
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
nodes = ps.bus(:,1);
links = ps.branch(:,1:2);
locs = ps.bus(:,C.bu.locs);

% now find the single contingency links
branch_outages = list_of_all(size(links,1));
[c_nodes,c_links] = make_n_1_1_graph(ps);

%% draw the ps
figure(1); clf; hold on;
drawps(ps,0.05);

% find the midpoints for each link
F_locs = locs(F,:);
T_locs = locs(T,:);
br_locs = (F_locs + T_locs)/2;

% show the midpoints
%plot(br_locs(:,1),br_locs(:,2),'g.','markersize',10);

% draw arrows for each link
for i = 1:length(c_links)
    f = c_links(i,1);
    t = c_links(i,2);
    arrow(br_locs(f,:),br_locs(t,:),'Width',2);
end

%% figure 2, n-1-1 graph
figure(2); clf; hold on;
% draw grey dots at each bus
%plot(locs(:,1),locs(:,2),'.','markersize',20,'color',[.3 .3 .3]);
% draw blue dots at each link
plot(br_locs(:,1),br_locs(:,2),'.','markersize',20);
% draw arrows for each link
for i = 1:length(c_links)
    f = c_links(i,1);
    t = c_links(i,2);
    arrow(br_locs(f,:),br_locs(t,:),'Width',0.5);
end
axis off

return
% plot the transmission lines on top
plot(br_locs(:,1),br_locs(:,2),'g.','markersize',20);

%%
figure(3);
draw_graph(c_nodes,c_links);

return

