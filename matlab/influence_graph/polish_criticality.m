%% Load the data and build the influence graphs
clear all
load ig_polish_results;

H0 = build_Glambda(F.F0,G,false);
H1 = build_Glambda(F.F1,G,false);
EPS = 1E-5;
subset = sum(H0)>EPS | sum(H1)>EPS;

%% Write the two influence graphs to files
%{
[from,to,weight] = find(H0);
m_igraph = length(from);
f = fopen('polish_igraph_H0.csv','w');
fprintf(f,'from node, to node, edge weight\n');
for i = 1:m_igraph
    fprintf(f,'%d,%d,%g\n',from(i),to(i),weight(i));
end
fclose(f);

[from,to,weight] = find(H1);
m_igraph = length(from);
f = fopen('polish_igraph_H1.csv','w');
fprintf(f,'from node, to node, edge weight\n');
for i = 1:m_igraph
    fprintf(f,'%d,%d,%g\n',from(i),to(i),weight(i));
end
fclose(f);
%}

%% Compute the overall size measure a
m = size(H0,1);
p0 = 1/8760 * ones(m,1);
perturbation_size = 0.5;
[delta_a_sum,delta_a] = compute_criticality(H0,H1,p0,perturbation_size,'cols',subset);

% top 5, 10, 20
[~,index] = sort(delta_a_sum,'descend');
top_20_org = index(1:20)

%% temp calculation for reviewer 2
[delta_a_sum_mod,delta_a_mod] = compute_criticality(H0,zeros(size(H1)),p0,perturbation_size,'cols',subset);

% top 5, 10, 20
[~,index] = sort(delta_a_sum_mod,'descend');
top_20_mod = index(1:20)


%% make a figure for reviewer 2
figure(1); clf;
plot(delta_a_sum,delta_a_sum_mod,'ro');
set(gca,'fontsize',16);
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('$\alpha$ as described in the paper','interpreter','latex');
ylabel('$\alpha$ assuming that $\mathbf{H}_{1+}=0$','interpreter','latex');

return

%save polish_criticality delta_a_sum delta_a top_20

%% Look at the top k most critical, via incremental perturbations
%{
k = 10;
[upgrades,alpha] = top_k_upgrades(H0,H1,p0,perturbation_size,'cols',subset,k);
for ix = 1:k
    j = upgrades(ix);
    fprintf('%4d: %.6e\n',j,alpha(ix));
end
%}


%% Plot the ccdf of delta_a_sum
figure(1); clf;
h = plot_ccdf(delta_a_sum,1e-10,'k-');
set(gca,'fontsize',16);
set(gca,'yscale','log');
set(h,'linewidth',2);
xlabel('Impact of reductions in component propagation rates, $x$','Interpreter','latex');
ylabel('$\Pr( \alpha_{i} \geq x )$','Interpreter','latex');
%axis tight;
axis([9e-9 1e-4 1e-4 1]);

%% Print out the larger ones
mx = max(abs(delta_a_sum));
subset = find(abs(delta_a_sum)>mx/2);
fprintf('Branch, delta a\n');
for i = subset'
    fprintf('%d,%g\n',i,delta_a_sum(i));
end

%% Plot the relationship between F0, F1 and delta_a_sum
figure(2); clf;
loglog(F.F0,abs(delta_a_sum),'.');
xlabel('F0');
ylabel('Perturbation impact');

figure(3); clf;
loglog(F.F1,abs(delta_a_sum),'.');
xlabel('F1');
ylabel('Perturbation impact');


