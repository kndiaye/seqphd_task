function [status,IOReadWrite_handle] = OpenParPort(verbose,address)
%  OpenParPort - Opens parallel port for PsychToolbox
%
%   [status] = OpenParPort(verbose)
%
%  Purpose:
%    Opens the parallel port (LPT1).
%    Aborts if the parallel port is already open or if the parallel port is
%    absent or unavailable.
%
%   [s] = OpenParPort(verbose) open parallel port in verbose mode
%
%  Usage:
%    >> OpenParPort();
%    >> OpenParPort(verbose);
%
%   Requires: Matport (the NTPort Library for MATLAB)
%
%  Author:
%    Valentin Wyart (valentin.wyart@chups.jussieu.fr)
status=0;
evalin('base', 'global IOReadWrite_handle;');
global IOReadWrite_handle;
if ~isempty(IOReadWrite_handle)
    if nargin<1
        verbose=1;
    end
    if verbose
        warning('OpenParPort:AlreadyOpen','Parallel port has already been opened. Close it before reopen it')
    end
    return
end
try
    folder = fileparts(mfilename('fullpath'));
    javaaddpath(fullfile(folder,'usd','IOReadWrite.jar'))
    try
        evalin('base', 'fprintf(''Importing IOReadWrite class... '');import usd.IOReadWrite;fprintf(''done\n'');');
    catch
        fprintf('uh oh... let''s clean some stuff\n');
        evalin('base', 'clear import; clear java; clear mex');
        javaaddpath(fullfile(folder,'usd','IOReadWrite.jar'))
        evalin('base', 'fprintf(''Importing IOReadWrite class... '');import usd.IOReadWrite;fprintf(''done\n'');');
    end
    evalin('base', 'global IOReadWrite_handle;fprintf(''Instantiating IOReadWrite_handle object\n'');');
end
import usd.IOReadWrite.*

IOReadWrite_handle = IOReadWrite;
assignin('base','IOReadWrite_handle',IOReadWrite_handle);

if nargin<1
    address = [hex2dec('378') hex2dec('379')];  %LPT1 Data & Status ports
end
for port = address
    if ~IOReadWrite_handle.installUserPort(port)
        fprintf('UserPort.sys initialization failed for port %d', port)
    end
end
return
% 
% global PAR_PORT
% if ~isempty(PAR_PORT)
%     return
%     % error('Open error: the parallel port (LPT1) is already open.');
% end
% PAR_PORT = [];
% try
%     Matport('LicenseInfo', 'Valentin Wyart', 13104);
% catch
%     warning('OpenParPort:MatportDLLNotFound','Can''t use Matport!');
%     status = 1;
%     return
% end
% PAR_PORT = 1;
% 
% add =  Matport('GetLPTPortAddress', 1);
% 
% if isequal(add,0)
%     clear global PAR_PORT
%     status = 2;
%     warning('OpenParPort:LPT1AddressUnknown','OpenParPort error: the parallel port (LPT1) is absent.');
% end
% 
% Matport('SetFastMode', 1);
% Matport('EnablePorts', 888, 890);
% 
% Matport('Outp', 888, 0);
% Matport('Outp', 890, 4);
% 
% if Matport('Inp', 888) ~= 0 || Matport('Inp', 890) ~= 4
%     CloseParPort;
%     warning('OpenParPort:LPT1Unavailable','OpenParPort error: the parallel port (LPT1) is unavailable.');
%     status = 2;
% end
% 
% return