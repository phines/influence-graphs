function draw_ig2(ps,G_lambda)
% usage: draw_ig2(ps,G_lambda)

WIDTH_BASE = 1;
LIGHT_GRAY = [1 1 1]*.7;
n = size(G_lambda,1);

%% Constants and stuff
C = psconstants;
m = size(ps.branch,1);
%n = size(ps.bus,1);

%% get object locations
% node locations
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
% link locs
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
x_link = (x(F) + x(T))/2;
y_link = (y(F) + y(T))/2;

%% draw the actual power grid
disp('Drawing');
% draw the transmission lines
hold on;
axis off;
for i = 1:m
    f = ps.bus_i(ps.branch(i,1));
    t = ps.bus_i(ps.branch(i,2));
    line([x(f) x(t)],[y(f) y(t)],'Color',LIGHT_GRAY,'LineWidth',WIDTH_BASE);
    % link numbers
    %text(mean(x([f t]))+.02,mean(y([f t])),num2str(i));
end

%% Now draw the virtual links
[g_from,g_to,g_weight] = find(G_lambda);
for i = 1:length(g_from)
    f = g_from(i);
    t = g_to(i);
    width = g_weight(i)*WIDTH_BASE*100;
    start = [x_link(f) y_link(f)];
    stop  = [x_link(t) y_link(t)];
    arrow(start,stop,20,'Width',width);
    %line([x_link(f) x_link(t)],[ y_link(t)],'Color','k','LineWidth',width);
end

