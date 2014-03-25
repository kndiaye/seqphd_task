function [key,tkey] = CheckKeyPress(whichkeys)

if nargin < 1 || isempty(whichkeys)
    whichkeys = 1:256;
end

key = 0;
[iskeydown,tkey,keys] = KbCheck(-1);
if any(keys(whichkeys))
    key = find(keys(whichkeys),1);
end

end