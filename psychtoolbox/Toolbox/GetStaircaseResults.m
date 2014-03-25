function [results] = GetStaircaseResults(staircase)

if nargin < 1
    error('Missing input argument.');
end

results = struct;

results.ptarget = staircase.ptarget;

results.n = staircase.i-1;

results.x = staircase.x(1:results.n);
results.r = staircase.r(1:results.n);
results.p = staircase.p(1:results.n);

results.nstp = length(find(staircase.istp <= results.n));
results.istp = staircase.istp(1:results.nstp);

end