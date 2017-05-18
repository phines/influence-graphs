function [nodes,links,x,y] = read_dot_file(outfile)
% will only read a dot file written by neato

%%
%node=1;
%branch=1;
x = [];
y = [];
nodes = [];
links = [];

fid = fopen(outfile,'r');
if (fid==0)
    error('Could not open the graph output file.');
end

line = fgetl(fid);
while ischar(line)
    
    % check to see if the line is a node line
    [out,count,err] = sscanf(line,'%d [height=%f,');
    if count>0 && isempty(err)
        node = out(1);
        %fprintf('Found node %d\n',out(1));
        nodes = cat(1,nodes,node);
        i = length(nodes);
        % Read the next line, which should have the position
        line = fgetl(fid);
        [out,count] = sscanf(line,' pos="%f,%f"');
        if count==2
            x(i) = out(1); %#ok<AGROW>
            y(i) = out(2); %#ok<AGROW>
        end
        
    else % find a link line
        [out,count,err] = sscanf(line,'%d -- %d %s,');
        if count>0 && isempty(err)
            %fprintf('Found link %d -- %d\n',out(1:2));
            link = out(1:2)';
            links = cat(1,links,link);
        end
    end
       %{
    if strfind(line,'pos="')
        [num,xi,yi] = strread(line,'%d [pos="%f,%f"',1);
        x(node) = xi;
        y(node) = yi;
        number(node) = num;
        node = node+1;
        % else if the line is a branch line
    elseif strfind(line,'[dir=');
        [f,t] = strread(line,'%d -- %d',1);
        from(branch) = f;
        to(branch)   = t;
        branch = branch + 1; 
    end
    %}
    line = fgetl(fid);
end

fclose(fid);

if size(x,1)==1
    x = x';
end
if size(y,1)==1
    y = y';
end

