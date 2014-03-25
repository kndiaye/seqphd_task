function [datresp] = InterimChoice_TestButtons()

addpath('./Toolbox/');

catresp = {'majeur gauche','index gauche','index droit','majeur droit'}; % response buttons
datresp = zeros(1,4); % codes of response buttons

KbName('UnifyKeyNames');
keyquit = KbName('ESCAPE'); % abort test

hport = [];
try
     
    % listen to key events
    FlushEvents;
    ListenChar(2);
    
    % open response port
    hport = IOPort('OpenSerialPort','COM1');
    IOPort('ConfigureSerialPort',hport,'BaudRate=115200');
    IOPort('Purge',hport);
    
    % wait 1 s
    WaitSecs(1.000);
    
    % test response buttons
    fprintf('\n\n\n');
    aborted = false;
    for i = 1:4
        fprintf('WAITING FOR [%s] BUTTON... ',catresp{i});
        dat = [];
        while isempty(dat)
            if CheckKeyPress(keyquit)
                fprintf('ABORTED!\n');
                aborted = true;
                break
            end
            dat = IOPort('Read',hport);
        end
        IOPort('Purge',hport);
        datresp(i) = dat(1);
        fprintf('%d\n',datresp(i));
    end
    fprintf('\n\n\n');
    
    % close response port
    IOPort('Close',hport);
    
    % stop listening to key events
    FlushEvents;
    ListenChar(0);
    
    if aborted
        datresp = [];
    end
    
catch
    LE = lasterror
    
    % stop listening to key events
    FlushEvents;
    ListenChar(0);
  
    % close response port
    if isequal(LE.stack(1).name,mfilename)% && LE.stack(1).line==19
        IOPort('CloseAll');
    else
        IOPort('Close',hport);
    end
    
    psychrethrow(lasterror);
    
end

end