% merge all the polish results with the correct order. This is used to
% merge the raw data that is currently on Google Drive.
clear all;
njobs = 50;
nbr = 2896;
n_allk2 = nbr*(nbr-1)/2;
bo_sizes = nan(n_allk2,4);
fid = fopen('bo_sizes_loadprc_100.csv','w');
fprintf(fid,'dcsimsep results for all n-2''s on the polish system (after scopf)\n');
fprintf(fid,'outages, BO size (MW), BO size (branches)\n');
fclose(fid);
for i = 1:njobs
    progressbar(i/njobs)
    file_name = sprintf('raw_data/bo_sizes_loadprc_100_%d.csv',i);
    data = csvread(file_name,1);
    dlmwrite('bo_sizes_loadprc_100.csv',data,'-append');
end
    

