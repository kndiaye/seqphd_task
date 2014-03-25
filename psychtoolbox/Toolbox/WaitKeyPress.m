function [key,tkey,dt] = WaitKeyPress(whichkeys,timeout,waitrelease)

if nargin < 3 || isempty(waitrelease)
    waitrelease = true;
end
if nargin < 2 || isempty(timeout)
    timeout = inf;
end
if nargin < 1 || isempty(whichkeys)
    whichkeys = 1:256;
end

key = 0;
tkey = inf;

t0 = GetSecs;
while true
    [iskeydown,t,keys] = KbCheck(-1);
    if t-t0 > timeout
        break
    end
    if any(keys(whichkeys) > 0)
        key = find(keys(whichkeys),1);
        tkey = t;
        while waitrelease
            [iskeydown,t,keys] = KbCheck(-1);
            if all(keys(whichkeys) == 0)
                dt = GetSecs-tkey;
                break
            end
        end
        break
    end
end

end