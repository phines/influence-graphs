%% load the data
load polish_influence_graph

%% produce a graph
n = length(F.F0);

%{
% F0
P = (n:-1:1)./n;
x = sort(F.F0);

figure(1); clf;
plot(x,P,'k.-'); hold on;
set(gca,'FontSize',10);

% F1
P = (n:-1:1)./n;
x = sort(F.F1);

plot(x,P,'ko-','markersize',5);
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('X')
ylabel('Pr( \lambda_{i,f,k} \geq X )');
axis tight
h = gca;
set(h,'XTick',(10.^(-3:1)));

h = legend('\lambda_{f,1}','\lambda_{f,2+}');
set(h,'EdgeColor','w');

saveeps('f_ccdf',600)
%}

%% produce a heat map for g
%{
cmap = colormap;
nc = size(cmap,1);
%shading flat
figure(2); clf; hold on;
for i = 1:n
    for j = 1:n
        if G(i,j)>0
            % trace a square counter-clockwise, from the bottom left
            X = [i-1 i i i-1];
            Y = [j-1 j-1 j j];
            c_no = ceil(G(i,j) * nc);
            h = fill(X,Y,cmap(c_no,:),'MarkerEdgeColor','none','EdgeColor','none');
        end
    end
end
%}

%% plot the bo size data
casename = 'polish';
data = csvread(sprintf('../%s_results/k2/bo_sizes.csv',casename),1);
%%
size_MW = data(:,3);
size_brs = data(:,4);

figure(3); clf; hold on;
set(gca,'FontSize',12);
% MW
n = length(size_MW);
P = (n:-1:1)/n;
x = sort(size_MW);
plot(x(x>0),P(x>0),'k.-'); hold on;
% outages
x = sort(size_brs);
plot(x(x>0),P(x>0),'ko-','markersize',5);

set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('Event sizes, X');
ylabel('Pr( Size \geq X )');
% legend
h = legend('Sizes in MW','Sizes in # of outages');
set(h,'EdgeColor','w');
saveeps('f_ccdf',600)



