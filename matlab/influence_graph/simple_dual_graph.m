% generate lists of cascade paths for ian dobson

%% load the data
C  = psconstants;
ps = case30_ps;
ps = updateps(ps);
ps = dcpf(ps);
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));
n_branch = size(ps.branch,1);
flow = abs(ps.branch(:,C.br.Pf));
flow_max = ps.branch(:,C.br.rateA);
hist(flow./flow_max,20);
% find the midpoints for each link
bus_locs = ps.bus(:,C.bu.locs);
F_locs = bus_locs(F,:);
T_locs = bus_locs(T,:);
br_locs = (F_locs + T_locs)/2;
figure(1); clf;
drawps(ps,.1);


%% show the dual graph
figure(2); clf; hold on;
GREY = [1 1 1]*.5;
% plot each transmission line
for i = 1:n_branch
    X = [F_locs(i,1) T_locs(i,1)];
    Y = [F_locs(i,2) T_locs(i,2)];
    h = line(X,Y,'color',GREY,'linestyle','--');
end

%{
% plot the dual links
for i = 1:n_branch
    f = F(i);
    t = T(i);
    is_neighbor = (F==f | T==f) | (F==t | T==t);
    is_neighbor(i) = false;
    
    neighbors = find(is_neighbor)';
    for ng = neighbors
        X = [br_locs(ng,1) br_locs(i,1)];
        Y = [br_locs(ng,2) br_locs(i,2)];
        line(X,Y,'color','r');
    end
end
%}

% plot the center point of each line
plot(br_locs(:,1),br_locs(:,2),'.','markersize',20);


axis off
