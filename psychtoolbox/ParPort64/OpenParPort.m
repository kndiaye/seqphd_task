function status=OpenParallelPort()
global ioObj;
% Detect running OS
if exist('computer','builtin')
    subfolder = computer;
elseif ispc
    subfolder = 'PCWIN';
else
    error('OpenParallelPort:CannotGetArchitecture',...
        'OpenParallelPort could not identify the running OS/architecture');
end
% subfolder = fullfile(pwd,subfolder);
% addpath(subfolder)
switch(subfolder)
    case 'PCWIN'
        ioObj.dll = @io32;
    case 'PCWIN64'
        ioObj.dll = @io64;
    otherwise
        %case {'GLNX86','GLNXA64', 'MACI64'}
    error('OpenParallelPort:UnknownArchitecture',...
        'OpenParallelPort does not know how to deal with the parallel port in this OS');
end
try
    ioObj.handle = ioObj.dll();
    status = ioObj.dll(ioObj.handle);    
catch ME
    rethrow(ME)
end
if (status ~= 0)
  if nargout>0
      % I assume the caller is okay with failure.
      warning('OpenParallelPort:Failed', 'Failed to access the parallel port!')
      return
  else
      error('OpenParallelPort:Failed', 'Failed to access the parallel port!')
  end
end
WriteParPort(0);
ReadParPort();
return
   
%read: byte = io32(cogent.io.ioObj,address);


return

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
