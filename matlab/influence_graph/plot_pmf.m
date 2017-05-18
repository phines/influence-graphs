function plot_pmf(x,marker,averaging_k)
% Plot an empirical ccdf of the data in X

if nargin<2
    marker = 'k-';
end

n = length(x);
min_x = min(x);
max_x = max(x);

% If we are just doing the simple method
x_axis = min_x:max_x;
Y_count = zeros(size(x_axis));
if nargin<3
    for i = 1:length(x_axis)
        Y_count(i) = sum(x==x_axis(i));
    end
else
    for i = (averaging_k+1):(length(x_axis)-averaging_k)
        lower_x = x_axis(i-averaging_k);
        upper_x = x_axis(i+averaging_k);
        Y_count(i) = sum(x>=lower_x & x<=upper_x);
    end
end

Y = Y_count / n;
assert(abs(sum(Y) - 1)<1e-6);

nz = x_axis>0;
plot(x_axis(nz),Y(nz),marker);
set(gca,'xscale','log');
set(gca,'yscale','log');
