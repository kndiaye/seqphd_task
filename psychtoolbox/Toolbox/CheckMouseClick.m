function [button] = CheckMouseClick(whichbuttons)

if nargin < 1 || isempty(whichbuttons)
    whichbuttons = 1:3;
end

button = 0;
[xmouse,ymouse,buttons] = GetMouse;
if any(buttons(whichbuttons))
    button = find(buttons(whichbuttons),1);
end

end