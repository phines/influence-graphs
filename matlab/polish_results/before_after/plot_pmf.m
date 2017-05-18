function h = plot_pmf(x,min_per_bin,linestyle)
% plots a binned pmf
% will make sure that each point represents at least min_per_bin data

% assumes that the inputs are integers
% force this to be the case:
x = round(x);
n = length(x);
min_x = min(x);
max_x = max(x);
x_axis =  min_x:1:max_x;
nx = length(x_axis);
probability = nan(1,nx);

for i = 1:nx
    xi = x_axis(i);
    ni = sum(x==xi);
    if ni>=min_per_bin
        probability(i) = ni/n;
    else
        range = xi;
        mid_i = i;
        while ni<min_per_bin
            if i+2>nx
                break;
            end
            range = [range x_axis(i+1) x_axis(i+2)]; %#ok<AGROW>
            mid_i = mid_i + 1;
            ni = ni + sum(x_axis(i+1)==x) + sum(x_axis(i+2)==x);
            %xi = mean(range);
            %xi_max = max(range);
            i = i + 2; %#ok<FXSET>
        end
        probability(mid_i) = ni/n;
    end
end
remove_set = isnan(probability);
probability(remove_set) = [];
x_axis(remove_set) = [];

h = plot(x_axis,probability,linestyle);
set(gca,'xscale','log')
set(gca,'yscale','log')
