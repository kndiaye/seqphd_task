function [button,tbutton] = WaitMouseClick(whichbuttons,timeout,waitrelease)

if nargin < 3 || isempty(waitrelease)
    waitrelease = true;
end
if nargin < 2 || isempty(timeout)
    timeout = 1;
end
if nargin < 1 || isempty(whichbuttons)
    whichbuttons = 1:3;
end

button = 0;
tbutton = inf;

t0 = GetSecs;
while true
    [xmouse,ymouse,buttons] = GetMouse;
    t = GetSecs;
    if t-t0 > timeout
        break
    end
    if any(buttons(whichbuttons) > 0)
        button = find(buttons(whichbuttons),1);
        tbutton = t;
        while waitrelease
            [xmouse,ymouse,buttons] = GetMouse;
            if all(buttons(whichbuttons) == 0)
                break
            end
        end
        break
    end
end

end