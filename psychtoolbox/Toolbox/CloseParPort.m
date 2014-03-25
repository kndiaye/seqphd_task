function CloseParPort()

global PAR_PORT
if isempty(PAR_PORT)
    error('Parallel port interface not open.');
end

if PAR_PORT == 1
    Matport('Outp',888,0);
    Matport('DisablePorts',888,890);
    Matport('SetFastMode',0);
end

clear global PAR_PORT

end