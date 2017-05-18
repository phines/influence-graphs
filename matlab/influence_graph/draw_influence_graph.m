load case30x4_influence_graph;

% plot the actual branches in the system


% true links
for i = 1:m
    f = ps.bus_i(ps.branch(i,1));
    t = ps.bus_i(ps.branch(i,2));
    h = line([x(f) x(t)],[y(f) y(t)],'Color',[.9 .9 0.1],'LineWidth',0.5);
end
