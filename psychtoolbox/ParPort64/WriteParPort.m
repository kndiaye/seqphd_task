function WriteParPort(value, mask)
% Write value onto the parallel port (LPT1/&H378)
if nargin < 1
    return
elseif nargin < 2
    mask = 255;
end
global ioObj;
buffer = bitand(value, mask);
ioObj.dll(ioObj.handle,888,buffer);