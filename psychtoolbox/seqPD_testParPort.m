

% Define various parameters
run('seqPD_TaskParameters');
addpath('ParPort64')

OpenParPort;
for i=1:5
WriteParPort(255);
fprintf('255 ');
WaitSecs(.25);
WriteParPort(0);
fprintf('0 ');
WaitSecs(.25);
end
for f=fieldnames(trig)'
    if isstruct(trig.(f{1}))
        for g=fieldnames(trig.(f{1}))'
        WriteParPort(sum(trig.(f{1}).(g{1})));
        WaitSecs(.05);
        WriteParPort(0);
        WaitSecs(.05);
        end
    else        
        WriteParPort(sum(trig.(f{1})));
        WaitSecs(.05);
        WriteParPort(0);
        WaitSecs(.05);
    end
end
fprintf('\n');

        