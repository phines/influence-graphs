load ig_polish_results;
% Real data
f = fopen('cascade_sizes_real.data','w');
fprintf(f,'%d\n',cascade_sizes_real);
fclose(f);
% simulated data
f = fopen('cascade_sizes_sim.data','w');
fprintf(f,'%d\n',cascade_sizes_sim);
fclose(f);
