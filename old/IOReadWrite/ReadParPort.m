function [data] = ReadParPort(data,address)
%  ReadParPort - Read LENA buttons connected on the parallel port
%
%       [data] = ReadParPort() reads the control bits of the parallel port
%       to detect if any LENA-buttons has been pressed. It would throw an
%       error if IoRead is unavailable.
%
%       [data] = ReadParPort(default) would return [default] instead of
%       throwing an error.
%
%  Authors:
%    Valentin Wyart (valentin.wyart@upmc.fr)
%    Karim NDIAYE (kndiaye01@yahoo.fr)

if 1
    global IOReadWrite_handle
    if isempty(IOReadWrite_handle)
        if nargin
            return
        else
            error('ReadParPort:NoIOPort','The parallel port (LPT1) is not open using IOReadWrite.');
        end
    end
    if nargin<2
        address = hex2dec('379');
    end
    buff = IOReadWrite_handle.read(address);
    data = sum(bitset(0, 1:5, [bitget(buff, 8) ~bitget(buff, 6) ~bitget(buff, 5) ~bitget(buff, 7) ~bitget(buff, 4)]));
return
    
else
    
    % Using Matport
    global PAR_PORT
    if isempty(PAR_PORT) || ~PAR_PORT
        if nargin
            return
        else
            error('read error: the parallel port (lpt1) is not open.');
        end
    end
    buff = matport('inp', 889);
end
% Using inportb (slow!!!)
% buff = inportb(889);