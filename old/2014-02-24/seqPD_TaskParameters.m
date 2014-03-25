%% initialize seqpd experiment
% add toolbox to path
addpath('./toolbox/');
addpath('./kndtoolbox/');
addpath('./IOReadWrite/');

%% Machine used in DEBUG mode
DEBUG_machines = { ...
    'Puma-Ndiaye.local' ...
    'puma-ndiaye.lan' ...
    'MacBook-Air-de-Marine.local' ...
    'Bakunin.local' ...
    'pdelld420ab' ...
    }%'MALLET-11'};

SESSIONS = {'Comportement pre-op','Perop','LFP+MEG post-op','comportement'};

%% Experiment flags
flags.with_training   = 1; % with initial training bloc?
flags.with_response_lumina   = 1;
flags.with_response_mouse    = 0;
flags.with_response_keyboard = 0;
flags.with_meg        = 0; % with MEG?
flags.with_eyetracker = 0; % with eye-tracker?


%% Useful inline functions
% Easier screen-blink compatible timing
% Typical use:
%       >> Screen('Flip',video.h,last_flip+roundfp(duration,ifi));
roundfp = @(dt,ifi)(round(dt/ifi)-0.5)*ifi;

%% Stimuli
shapes = { 'circle' 'square' 'triangle' };
fprintf('codes for shapes are hard-coded here:\n');
fprintf('[1] %s%s - [2] %s%s - [3] %s%s \n',...
    upper(shapes{1}(1)),shapes{1}(2:end),...
    upper(shapes{2}(1)),shapes{2}(2:end),...
    upper(shapes{3}(1)),shapes{3}(2:end));
stimulusfile = cell(1,length(shapes));
for i=1:length(shapes)
    stimulusfile{i} = fullfile(fileparts(mfilename('fullpath')),'..','stimuli',[shapes{i},'.bmp']);
end

%% Timing of events
timing.startwait   = 10.000; % wait period at beginning of odd-numbered blocs
timing.cueduration = 5;
timing.interstim = @()0.3   +.2*(rand-.5);
timing.interseq = 5;
timing.startofblock = 1.5;
timing.response_release = .2;
timing.prefeedbackduration = .3;
timing.feedbackduration = 1;

%% keyboard/buttons inputs
KbName('unifykeynames');
keywait = KbName('space'); % break waiting period
keystop = KbName('escape'); % break and restart current bloc
%keyquit = KbName('b'); % abort experiment
keyresp = KbName({'q','m'}); % response buttons ('L' 'R')
if ismac
    % i have to figure out why this is so...
    keyresp = [ 4 51 ];
    %keyquit = [ keyquit 5 ];
end
% Lumina buttons codes:
%  |     Y[50] |  | G[51]     |
%  | B[49]     |  |     R[52] |
datresp = [50,51]; % codes of lumina response buttons (Left, Right)
lptresp = [4,8]; % codes of mouse buttons on parallel port (Left, Right)


%% training parameters
training.ntrials = 20;
training.nfeedbacktrials = 10;

%% triggers
% values sent to recording sytems on the parallel port

trig.start      = 255;

trig.cue.onset  = 16;
trig.cue.shape  = [ 2 4 8 ]; % 1-c / 2-s / 3-t

trig.stim.onset   =  32;
trig.stim.shape   = [ 2 4 8 ]; % 1-c / 2-s / 3-t
trig.stim.is_target = 1 ;

trig.resp.onset   = 64;
trig.resp.button  = [ 2 4 ];   % L / R
trig.resp.is_correct = 1 ;

%% eyelink eye-tracker variable:
eyelink=[];

%% screen/display parameters
lumibg          = 0.0;
ppd             = 80;