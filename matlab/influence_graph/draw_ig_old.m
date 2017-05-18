%% load the data
clear all
load case30x4_influence_graph
%load ../dcsimsep/case2383_mod_ps;
C = psconstants;
m = size(ps.branch);
thresh = 1e-4;
igraph_F = F;

%% find the link locations
disp('finding the link locations');
% node locations
x = ps.bus(:,C.bu.locX);
y = ps.bus(:,C.bu.locY);
% link locs
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
x_link = (x(F) + x(T))/2;
y_link = (y(F) + y(T))/2;

%% draw the actual graph
disp('Drawing');
% nodes
figure(1); clf;
%
hold on;
% true links
for i = 1:m
    f = ps.bus_i(ps.branch(i,1));
    t = ps.bus_i(ps.branch(i,2));
    h = line([x(f) x(t)],[y(f) y(t)],'Color',[.9 .9 .9],'LineWidth',0.5);
    % link numbers
    %text(mean(x([f t]))+.02,mean(y([f t])),num2str(i));
end

%% draw virtual links
%
figure(1);
i_graph = sparse(G);
[from,to,weights] = find(i_graph);
mx_wt = max(weights);
cmap = colormap;
nc = size(cmap,1);
for i = 1:length(weights)
    if weights(i)>thresh
        c_no = ceil(weights(i)/mx_wt * nc);
        color = cmap(c_no,:);
        f = from(i);
        t = to(i);
        %thickness = weights(i)*100;
        %line(x_link([f t]),y_link([f t]),'Color',color,'LineWidth',thickness);
        from_end = [x_link(f) y_link(f)];
        to_end = [x_link(t) y_link(t)];
        h = arrow(from_end,to_end,'Length',8);
        set(h,'FaceColor',color);
        set(h,'EdgeColor',color);
    end
end
colorbar;

%% Mark the links with their relative weights in F1
% plot the node centers
%marker_sizes = sqrt(mean([igraph_F.F0;igraph_F.F1],1)) * 50;
marker_sizes = sqrt(igraph_F.F1) * 50;
for i = 1:m
    sz = marker_sizes(i);
    if sz>0
        plot(x_link(i),y_link(i),'k.','MarkerSize',sz);
    end
end
axis off;

%figure(1);
%title('graph showing links with a weight of 1000 or greater');
return

%% draw a histogram of the link weights
% histogram of link weights
figure(2); clf;
[bin_counts,bin_xlocs] = hist(weights,100);
P = bin_counts/sum(bin_counts);
plot(bin_xlocs,P,'o');
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('Link weights');
ylabel('Probability mass');
title('Probability mass function of link weights');

%% look at the degree of the graph
degree = sum(i_graph);
figure(3); clf;
m = length(degree);
P = (m:-1:1)/m;
plot(sort(degree),P);
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('Influence degree of transmission lines in the network');
ylabel('Cumulative probability');

