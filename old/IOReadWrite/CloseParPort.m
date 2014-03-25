function CloseParPort()
    %  CloseParPort
    %
    %  Purpose:
    %    Closes the parallel port (LPT1).
    %    Aborts if the parallel port is not open.
    %
    %  Usage:
    %    >> CloseParPort();
    %
    %  Author:
    %    Valentin Wyart (valentin.wyart@chups.jussieu.fr)
    
    global PAR_PORT
    if isempty(PAR_PORT) || ~PAR_PORT
        return
        % error('Close error: the parallel port (LPT1) is not open.');
    end
    clear global PAR_PORT
    
    Matport('Outp', 888, 0);
    Matport('Outp', 890, 0);
    
    Matport('DisablePorts', 888, 890);
    Matport('SetFastMode', 0);
    
end
