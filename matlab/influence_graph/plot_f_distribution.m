% load ig_polish_results; sub_plot = 2; pos = 0.06; tit = '\Deltat = 30 s';
% load ig_polish_results_delta_t_5; sub_plot = 1; tit = '\Deltat = 15 s';
load ig_polish_results_delta_t_20; sub_plot = 3; d_pos = 0.12; tit = '\Deltat = 60 s';

%% Plot the cdf;
figure(5); clf;
set(gca,'FontSize',18);
hold on;
h1 = plot_ccdf(F.F0,[],'r.-');
h2 = plot_ccdf(F.F1,[],'bv--');
set(h1,'linewidth',2);
set(h1,'markersize',30);
set(h2,'linewidth',2);
set(h2,'markersize',8);
set(h2,'MarkerFaceColor','b');
axis tight
box on;
legend('\lambda_{i,0}','\lambda_{i,1+}');
legend boxoff;
set(gca,'xtick',10.^(-3:1));

xlabel('Component-wise branching rate ($\lambda$)','interpreter','latex');
ylabel('Probability that $\lambda_{i,m} \geq \lambda$','interpreter','latex');

%% Plot the pdf
figure(6); 
subplot(1,3,sub_plot); cla
h1 = plot_pdf_pl(F.F0,20,26,'r.-'); hold on;
h2 = plot_pdf_pl(F.F1,20,26,'b.-');
axis tight
axis([1e-4 10 1e-3 1e4]);
set(gca,'fontsize',18);
legend('\lambda_{i,0}','\lambda_{i,1+}');
legend boxoff;
xlabel('Component-wise propagation rate ($\lambda$)','interpreter','latex');
if sub_plot==1 
    ylabel('Probability density','interpreter','latex');
else
    pos = get(gca,'Position'); pos(1) = pos(1) - d_pos;
    set(gca,'Position',pos);
end
set(gca,'xtick',10.^(-4:1));
set(gca,'ytick',10.^(-3:4));
box off;
text(1e-2,3e3,tit)
