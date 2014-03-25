function WriteParPort(data, mask, address)
%  WriteParPort - Write data on parallel port
%
%  Purpose:
%    Write one byte (8 bits) of data to the parallel port (LPT1).
%    Aborts if the parallel port is not open.
%
%  Usage:
%    >> WriteParPort(data, [mask], [address]);
%
%  Input arguments:
%    data = input data
%    mask = input mask
%
%  Author:
%    Valentin Wyart (valentin.wyart@chups.jussieu.fr)
%    Karim N'Diaye

global IOReadWrite_handle
if isempty(IOReadWrite_handle)
    warning('WritePort:NoIOReadWrite_handle','The parallel port (LPT1) is not open using IOReadWrite.');
    return
end
if nargin < 1
    error('Not enough input arguments.');
end
if nargin < 2
    mask = uint8(255);
end
if nargin < 3
    address = hex2dec('378');
end
data=data(:);
if isequal(mask,uint8(255))
    buff = any([bitget(data(:),1) bitget(data(:),2) bitget(data(:),3) bitget(data(:),4) bitget(data(:),5) bitget(data(:),6) bitget(data(:),7) bitget(data(:),8)]);
else
    buff = uint8(0);
    for i=1:numel(data)
        buff = bitor(buff, uint8(data(i)));
        buff = bitand(buff, mask);
    end
end
IOReadWrite_handle.write(address, double(buff(1)));
for i=2:numel(buff)
    IOReadWrite_handle.write(address, double(buff(1)));
end
return

% global PAR_PORT
% if isempty(PAR_PORT) || ~PAR_PORT
%     return
%     % error('Write error: the parallel port (LPT1) is not open.');
% end
% 
% if nargin < 1
%     error('Not enough input arguments.');
% elseif nargin < 2
%     mask = uint8(255);
% end
% data=data(:)
% if isequal(mask,uint8(255))
%     buff = any([bitget(data(:),1) bitget(data(:),2) bitget(data(:),3) bitget(data(:),4) bitget(data(:),5) bitget(data(:),6) bitget(data(:),7) bitget(data(:),8)]);
% else
%     buff = uint8(0);
%     for i=1:numel(data)
%         buff = bitor(buff, uint8(data(i)));
%         buff = bitand(buff, mask);
%     end
% end
% Matport('Outp', 888, double(buff));
% 
% end
