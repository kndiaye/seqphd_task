function WriteParPort(data, mask)

	global ioObj;
    
    if nargin < 2
        mask = 255;
    end
    if nargin < 1
        return
    end
    
    buffer = bitand(data, mask);
    
    io32(ioObj, 888, buffer);
    
end
