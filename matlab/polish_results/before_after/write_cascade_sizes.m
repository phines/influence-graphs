
before = csvread('../before/bo_sizes_loadprc_100.csv',2);
after  = csvread('../after2/bo_sizes_loadprc_100.csv',1);

n = size(before,1);
after_full = zeros(n,4);
after_full(:,1:2) = before(:,1:2);

for i = 1:size(after,1)
    l1 = after(i,1);
    l2 = after(i,2);
    ix = find( before(:,1)==l1 & before(:,2)==l2 );
    if isempty(ix)
        error('can''t find one');
    else
        after_full(ix,3:4) = after(i,3:4);
    end
end

f = fopen('bo_sizes_loadprc_100_mod.csv','w');
fprintf(f,'outage1, outage2, BO size (MW), BO size (branches)\n');
fprintf(f,'%d,%d,%.2f,%d\n',after_full');
fclose(f);

%% Write out a simple data file
cascade_sizes_after  = after_full(:,4)+2;
f = fopen('cascade_sizes_after.data','w');
fprintf(f,'%d\n',cascade_sizes_after);
fclose(f);

%% Make a figure
cascade_sizes_before = before(:,4)+2;
figure(1); clf; hold on;
plot_ccdf(cascade_sizes_after,'k-');
plot_ccdf(cascade_sizes_before,'r--');
axis tight;
box on;
axis([1 200 10e-7 10e-3]);
