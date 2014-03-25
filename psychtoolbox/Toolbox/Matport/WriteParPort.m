function WriteParPort(data)

global PAR_PORT
if isempty(PAR_PORT)
    error('Parallel port interface not open.');
end

if nargin < 1
    error('Wrong input argument list.');
end

if PAR_PORT == 1
    Matport('Outp',888,data);
end

end