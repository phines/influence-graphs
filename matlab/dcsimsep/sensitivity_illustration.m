% Draw a graph showing the risk sensitivity
load risk_sensitivity;
load data/case2383_mod_ps;
ps = redispatch(ps);
ps = dcpf(ps);
C = psconstants;
nodes = ps.bus(:,1);
links = ps.branch(:,1:2);
locs  = ps.bus(:,C.bu.locs);
flows = abs(ps.branch(:,C.br.Pf));
flow_limit = abs(ps.branch(:,C.br.rateB));
%ratio = flows./flow_limit;
%ratio_mod = ratio/max(ratio);
%link_colors = 

% Draw the initial system
figure(1); clf;
sizes.node_size = 10;
sizes.link_width = 5;
link_widths = flows / max(flows) * 2;

draw_graph(nodes,[links link_widths],locs,[],'r','g',sizes);

%% Now draw the sensitivity
link_widths = dR_dPr'/1000;
link_widths(link_widths<0.01) = 0;

sizes.link_width = 1;
draw_graph(nodes,[links link_widths],locs,[],'r','y',sizes);
