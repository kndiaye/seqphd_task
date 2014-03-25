function OpenParPort()

	global ioObj;

	%create IO32 interface object
clear io32;
ioObj = io32;

status = io32(ioObj);
if(status ~= 0)
    disp('OpenParPort : inpout32 installation failed!')
else
    disp('OpenParPort : inpout32 (re)installation successful.')
    io32(ioObj, 888, 0);

end
