%% load the data
load polish_influence_graph

%% produce a graph
n = length(F.F0);

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

%% 