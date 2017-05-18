function h = plot_ccdf(x,x_min,linestyle)
% plot ccdf
% usage: plot_ccdf(x,x_min,linestyle)

if nargin<2 || isempty(x_min)
    x_min = -Inf;
end

if nargin<3
    linestyle = 'b-';
end

n = length(x);
x = sort(x);
P = (n:-1:1)/n;
subset = (x>=x_min);
h = plot(x(subset),P(subset),linestyle);
set(gca,'xscale','log');
set(gca,'yscale','log');
%axis tight;


