function indices = find_max_k(numbers,k,ignore_zero)
% Find the indices of the k largest numbers in the input array
% The ignore_zero flag causes the function to ignore things smaller than
% zero

indices = nan(1,k);
numbers_mod = numbers;
for i = 1:k
    [~,ix] = max(numbers_mod);
    numbers_mod(ix) = -inf;
    indices(i) = ix;
end

if nargin>2 && ignore_zero
    lteq_zero = numbers(indices)<=0;
    if any(lteq_zero)
        indices(lteq_zero) = [];
    end
end
