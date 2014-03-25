function OpenParPort()

global PAR_PORT
if ~isempty(PAR_PORT) && PAR_PORT == 1
    error('Parallel port interface already open.');
end

Matport('LicenseInfo', 'Valentin Wyart', 13104);

if Matport('GetLPTPortAddress', 1) == 0
    error('Unable to find parallel port address.');
end

Matport('SetFastMode',1);
Matport('EnablePorts',888,890);
Matport('Outp',888,0);

if Matport('Inp',888) ~= 0
    CloseParPort;
    error('Unable to open parallel port interface.');
end
PAR_PORT = 1;

end