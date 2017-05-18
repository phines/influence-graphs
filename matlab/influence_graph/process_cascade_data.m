function out_fname = process_cascade_data(in_dir,file_root,delta_t,output_dir)

% Find all the csv files at file_root
files = dir([in_dir '/' file_root '*.csv']);
% prep an outfile
gen_file = sprintf('%s/generations.csv',output_dir);
% delete the file if it exists
if exist(gen_file,'file')
    delete(gen_file);
end

% loop through each of the files, processing into generations
for i = 1:length(files)
    %debug = 1
    fname = files(i).name;
    full_name = [in_dir '/' fname];
    fprintf('Processing file %s\n',full_name);
    data = csvread(full_name);
    event_type = data(:,1);
    out_time = data(:,2);
    br_no = data(:,3);    
    out_fname = group_generations(event_type,out_time,br_no,delta_t,gen_file);
end

