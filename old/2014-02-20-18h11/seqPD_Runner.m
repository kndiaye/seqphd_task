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

% Handle various install on various Machines
[hostname, hostname]=system('hostname'); %#ok<ASGLU>
hostname=strtrim(hostname);
if isempty(DEBUG)
    DEBUG = false;
end
if any(strcmpi(hostname, DEBUG_machines))
    DEBUG=true;
end

% get participant information
if DEBUG
    participant.identifier = hostname;
end
argindlg = inputdlg({'Participant Identifier','Gender (M/F)','Age (y)','Handedness (L/R)'},'',1,...
    {participant.identifier, '', '', 'R'});
if isempty(argindlg)
    error('Experiment cancelled!');
end
participant.identifier = argindlg{1};
participant.gender     = argindlg{2};
participant.age        = argindlg{3};
participant.handedness = argindlg{4};
participant.date = datestr(now,'yyyymmdd-HHMM');

% set experiment flags
participant.with_buttons    = 0;
participant.with_keyboard   = 1;
participant.with_meg        = 0; % with MEG?
participant.with_eyetracker = 0; % with eye-tracker?
participant.with_mri        = 0; % with MRI?
participant.with_training   = 1; % with initial training bloc?
participant.with_feedback   = 0; % with informative feedback?
if DEBUG
    participant.with_mri = false;
    participant.with_buttons = 0;
    participant.with_keyboard = true;
end

fprintf('PARTICIPANT INFORMATION:\n\n');
disp(participant);



%% 2/ Test response buttons
if 0%participabut.with_u
    close('all');
    clc;
    datresp = seqPD_TestButtons;
end

%% 3/ Run experiment and save data
Screen('CloseAll');
close('all');

% Open Parallel Port for TTL markers & response buttons
if 0%participant.with_buttons
    global IOReadWrite_handle
    IOReadWrite_handle
    if isempty(IOReadWrite_handle)
        fprintf('Open Parallel Port...\n')
        evalin('base', [...
            'javaaddpath c:/users/expe/seqPD/psychtoolbox/IoReadWrite/usd/IOReadWrite.jar;'...
            'import usd.IOReadWrite;'...
            'global IOReadWrite_handle;'...
            'IOReadWrite_handle = IOReadWrite']);
    end
    ReadParPort
end

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
