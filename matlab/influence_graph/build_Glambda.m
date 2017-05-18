function G_lambda = build_Glambda(lambda,G,do_plot,nodenames)
% Combine G and lambda
WIDTH_BASE = 10;

if nargin<3
    do_plot=false;
end

n = length(lambda);

% do this one row at a time
G_lambda = zeros(n,n);
for i = 1:n
    g_i = G(i,:);
    g_lambda_i = 1 - exp(-lambda(i)*g_i);
    if any(g_lambda_i>1 | g_lambda_i<0)
        disp('Error computing Glambda');
        keyboard
    end
    G_lambda(i,:) = g_lambda_i;
end

if do_plot
    if nargin<4
        for i = 1:n
            nodenames{i} = num2str(i);
        end
    end
    % Find the nodes and edges
    [g_from,g_to,g_weight] = find(G_lambda);
    % Write the edge file
    fid = fopen('ig_links.csv','w');
    if fid<=0, error('open failed'); end
    fprintf(fid,'from,to,width\n');
    for i = 1:length(g_from)
        f = nodenames{g_from(i)};
        t = nodenames{g_to(i)};
        width = g_weight(i)*WIDTH_BASE;
        fprintf(fid,'%s,%s,%g\n',f,t,width);
    end
    fclose(fid);
    % Write the node file
    fid = fopen('ig_nodes.csv','w');
    fprintf(fid,'id,vsize\n');
    if fid<=0, error('open failed'); end
    for i = 1:n
        %f = ps.branch(i,1);
        %t = ps.branch(i,2);
        %vsize = ig_F(i);
        vsize = 5;
        fprintf(fid,'%s,%g\n',nodenames{i},vsize);
    end
    fclose(fid);
    disp('Wrote igraph to ig_links.csv and ig_nodes.csv');
    disp('Trying to plot in R');
    system('./plot_graph.r');
    system('open graph.pdf');
end

