%% 1/ Initialise experiment

clear('all');
clear('import')
clear('java');
close('all');
clc;
global DEBUG
global participant

participant = [];

% initialise random number generator
seed = sum(100*clock);
rand('twister',seed);
%randn('state',seed);

run('seqPD_TaskParameters')

% Handle various setups on various Machines
[hostname, hostname]=system('hostname'); %#ok<ASGLU>
hostname=strtrim(hostname);
if isempty(DEBUG)
    DEBUG = false;
end
if any(strcmpi(hostname, DEBUG_machines))
    DEBUG=true;
end

%% 2/ boites de dialogue : Participant Info
participant.hostname = hostname;
participant.date = datestr(now,'yyyymmdd-HHMM');
answer=inputdlg({'Identifiant'},'Participant',1);
if isempty(answer)
    error('Experiment cancelled!');
end
participant.identifier = answer{1};

% Use the flags from the seqPD_TaskParameters
% shorter timings
if DEBUG
    timing.startwait   = .5;
    %timing.cueduration = 5;
    timing.startofblock = inf;
    flags.with_response_keyboard = 1;
    if exist('/Users/ndiaye/','dir')
        flags.with_response_lumina   = 0;
    end
end
participant.flags = flags;


[selection,ok] = listdlg(...
    'PromptString','Select a condition',...
    'SelectionMode','single',...
    'ListString',SESSIONS, ...
    'ListSize', [ 200 100 ] );
if ~ok
     error('Experiment cancelled!');
end
participant.session = selection;

fprintf('PARTICIPANT INFORMATION:\n\n');
disp(participant);


%% 3/ Run experiment and save data
Screen('CloseAll');
close('all');

if DEBUG
    % run experiment
    [Passation,Passation.ErrorMsg] = seqPD_Experiment(participant);
else
    try
        % run experiment
        [Passation,Passation.ErrorMsg] = seqPD_Experiment(participant);
    catch
        errormsg = lasterror;
        Priority(0);
        Screen('CloseAll');
        FlushEvents;
        ListenChar(0);
        ShowCursor;
        video = [];
        psychrethrow(errormsg);        
        return
    end
end


% save data
save(Passation.Filename,'Passation');
if ~DEBUG
    % Let the experimenter add some comments?
    Passation.ExpostComments = inputdlg('Ex-post Commentary','Any comments?',5);
    % re-save
    save(Passation.Filename,'Passation')
end
% rethrow error message
if ~isempty(Passation.ErrorMsg)
    rethrow(Passation.ErrorMsg);
end

%% THIS IS THE END

return
%
%
% % save data
% filename = sprintf('../Data/seqPD_%s_%s.mat',participant.identifier,participant.date);
% save(filename,'participant','stimulus','response','timecode');
%
% %% 5/ Convert EDF files to ASCII
%
% close('all');
% clc;
%
% if ~ispc
%     error('EDF-to-ASCII file conversion not supported!');
% end
%
% foldername = sprintf('../Data/%s',participant.identifier);
% if ~exist(foldername,'dir')
%     error('Data folder not found!');
% end
% d = dir(foldername);
% i = find(cellfun(@(s)~strcmp(s(1),'.')&&~isempty(findstr(s,'edf')),{d.name}));
%
% % go to data folder
% cwd = pwd;
% cd(foldername);
%
% for iedf = i
%
%     filename = d(iedf).name;
%     fprintf('CONVERTING EDF FILE %s... ',upper(filename));
%
%     % get events
%     status = system(sprintf('edf2asc -e %s',filename));
%     [ff,fn,fe] = fileparts(filename);
%     movefile([fn,'.asc'],[fn,'_events.asc']);
%
%     % get samples
%     status = system(sprintf('edf2asc -s %s',filename));
%     [ff,fn,fe] = fileparts(filename);
%     movefile([fn,'.asc'],[fn,'_samples.asc']);
%
%     fprintf('DONE!\n');
%
% end
%
% % go back to project folder
% cd(cwd);
%
