function [noccurences] = HasConsecutiveValues(x,nconsecutive,xexcluded)

if nargin < 3
    xexcluded = [];
end
if nargin < 2
    nconsecutive = 2;
end
if nargin < 1
    error('Wrong input argument list.');
end

x = x(:);
d = [1;diff(x)] ~= 0;
n = diff([find(d);length(x)+1]);
y = x(d);

if ~isempty(xexcluded)
    if length(xexcluded) == 1
        i = (y ~= xexcluded);
    else
        i = ~ismember(y,xexcluded);
    end
    n = n(i);
end

noccurences = nnz(n >= nconsecutive);

end