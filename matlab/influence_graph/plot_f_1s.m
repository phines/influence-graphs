% load the data
disp('Loading data');
load polish_generations_data;
outages_after_one_counts = [];

%% Process
disp('Processing');
% go through each generation, finding the ones with only one outage
ng = size(generations,2);
for g = 1:(ng-1)
    % figure out how many in this generation
    n_out_this = sum(generations(:,g)>0);
    % If there is only one, figure out how many in the next generation
    if n_out_this==1
        n_out_next = sum(generations(:,g+1)>0);
        outages_after_one_counts = ...
            [outages_after_one_counts n_out_next]; %#ok<AGROW>
    end
end

%% Now plot
figure(1); clf;
set(gca,'fontsize',14);
n_max = max(outages_after_one_counts);
counts = zeros(1,n_max);
x = 0:n_max+1;
for i = 1:length(x)
    counts(i) = sum(outages_after_one_counts==x(i));
end

probability = counts / sum(counts);
subplot(2,1,1);
set(gca,'fontsize',16);
plot(x,probability,'k.','MarkerSize',8);
set(gca,'yscale','log');
xlabel('No. of outages in next gen.');
ylabel('Probability');
axis([0 150 1e-4 1]);
set(gca,'ytick',10.^(-4:1:0));

subplot(2,1,2);
set(gca,'fontsize',16);
plot(x,probability,'k.','MarkerSize',8);
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('No. of outages in next gen.');
ylabel('Probability');
axis([1 150 1e-4 1]);
set(gca,'ytick',10.^(-4:1:0));
