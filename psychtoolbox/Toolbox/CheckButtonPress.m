function [button] = CheckButtonPress(whichbuttons)

if nargin < 1
    whichbuttons = 1:5;
end

button = 0;
[data,buttons] = ReadParPort;
if any(buttons(whichbuttons))
    button = find(buttons(whichbuttons), 1);
end
