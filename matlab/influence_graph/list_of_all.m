function list = list_of_all(n,k)
% usage: list = list_of_all(n,k)
% simple function to produce of list of all combinations of k items chosen from a set
%  of n elements
% currently works only for 2 or 3.

if nargin<2
    k = 2;
end

if k==2
    nk = n*(n-1)/2;
    list = zeros(nk,2);
    counter = 1;
    for i=1:n
        for j=(i+1):n
            list(counter,1) = i;
            list(counter,2) = j;
            counter = counter+1;
        end
    end
elseif k==3
    nk = n*(n-1)*(n-2)/6; % n choose k
    list = zeros(nk,3);
    counter = 1;
    for i=1:n
        for j=(i+1):n
            for p=(j+1):n
                list(counter,1) = i;
                list(counter,2) = j;
                list(counter,3) = p;
                counter = counter+1;
            end
        end
    end
else
    error('only works for k=2 or 3');    
end