function [data,buttons] = ReadParPort()

global PAR_PORT
if isempty(PAR_PORT)
    error('Parallel port interface not open.');
end

if PAR_PORT == 1
    data = Matport('Inp',889);
    buttons = [bitget(data, 8),~bitget(data, 6),~bitget(data, 5),~bitget(data, 7),~bitget(data, 4)];
else
    data = 0;
    buttons = zeros(1,5);
end

end