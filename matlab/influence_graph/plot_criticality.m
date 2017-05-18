load polish_criticality;

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

%% Plot the pdf of delta_a_sum
figure(2); clf;
h = plot_pdf_pl(delta_a_sum,20,20,'r.-'); hold on;
set(gca,'fontsize',16);
xlabel('Relative impact of modifications, $\alpha_i$','Interpreter','latex');
ylabel('Probability density','Interpreter','latex');
%axis tight;
%axis([9e-9 1e-4 1e-4 1]);

box off;