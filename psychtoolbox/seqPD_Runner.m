%% 1/ Initialize matlab to run the experiment
diary;
clear('import')
close('all');
clc;
sca;
figure;

% initialise random number generator
seed = sum(100*clock);
rand('twister',seed);
%randn('state',seed);

% add toolbox to path
seqPDfolder = fileparts(mfilename('fullpath'));
cd(seqPDfolder);
addpath(seqPDfolder);
addpath(fullfile(seqPDfolder,'Toolbox'));
addpath(fullfile(seqPDfolder,'kndtoolbox'));
addpath(fullfile(seqPDfolder,'ParPort64'));
%addpath('./IOReadWrite/');
%C:\matlab_toolbox\CENIR\ParallelPort
set(0,'defaultfigurewindowstyle','docked');

%% Initialize variables etc.
clear('all');
clear('java');
global DEBUG

% Import Task parameters from m file
run('seqPD_TaskParameters.m')

global participant
participant = [];
% Participant Info
answer=inputdlg({'Participant ID?'},'Participant',1,{'TEST'});
if isempty(answer)
    error('Experiment cancelled during setup!');
end
participant.identifier = answer{1};

% Handles various setups on various Machines
participant.date = datestr(now,'yyyymmdd-HHMM');
participant.hostname=hostname();
fprintf('Running on machine: %s\n', participant.hostname);
if isempty(DEBUG)
    DEBUG = false;
end
if any(strcmpi(participant.hostname, DEBUG_machines))
    DEBUG=true;
    fprintf('This is supposed to be a DEBUG machine!\n');
end
if DEBUG
    % shorter timings
    timing.cueduration = 1.5;
    flags.with_response_keyboard = 1;
    if exist('/Users/ndiaye/','dir')
        flags.with_response_lumina = 0;
    end
end
[selection,ok] = listdlg(...
    'PromptString','Select a condition',...
    'SelectionMode','single',...
    'ListString',SESSIONS(:,1), ...
    'ListSize', [ 200 100 ], ...
    'InitialValue', 1+...
    double(DEBUG)*3+...
    (strmatch('perop',SESSIONS(:,2))-1)*strcmp('MALLET-11',participant.hostname));
if ~ok
     error('Experiment cancelled!');
end
participant.session = selection;
participant.session_name = SESSIONS{selection,2};

% Flags
participant.flags=flags;
% prompt = fieldnames(flags);
% answer=inputdlg(fieldnames(flags),'flags',1,...
%     arrayfun(@(x) eval(num2str(getfield(flags,x{1})),...
%     fieldnames(flags),'UniformOutput', 0));
% if isempty(answer)
%     error('Experiment cancelled!');
% end
% for i=1:numel(answer)
%     participant.flags.(prompt{i}) = str2double(answer{i});
% end

fprintf('PARTICIPANT INFORMATION:\n\n');
disp(participant);
disp(participant.flags);

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
    catch ME
        Priority(0);
        Screen('CloseAll');
        FlushEvents;
        ListenChar(0);
        ShowCursor;
        video = [];
        disp(ME)        
        rethrow(ME);
        diary('OFF')
        return
    end
end


% save data
save(Passation.Filename,'Passation');
diary off
if ~DEBUG
    % Let the experimenter add some comments?
    Passation.ExpostComments = inputdlg('Ex-post Commentary','Any comments?',5);
    % re-save
    save(Passation.Filename,'Passation')
end

% rethrow error message
if ~isempty(Passation.ErrorMsg)
    psychrethrow(Passation.ErrorMsg);
end
diary('OFF')
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
