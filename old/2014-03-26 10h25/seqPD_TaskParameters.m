%% initialize seqpd experiment

%% Machine used in DEBUG mode
DEBUG_machines = { ...
    'Puma-Ndiaye.local' ...
    'puma-ndiaye.lan' ...
    'MacBook-Air-de-Marine.local' ...
    'Bakunin.local' ...
    'pdelld420ab' ...
    %'HPC3F9'...
    };%'MALLET-11'};

SESSIONS = {
    'Comportement+MEG pre-op', 'preopmeg'; ...
    'Per-operative recordings','perop';...
    'LFP+MEG post-op',     'lfpmeg';
    'Comportement',        'comportement'};

%% Default Experiment flags
flags.with_training          = 0; % with initial training bloc?
flags.with_response_lumina   = now>datenum(2014,2,27,8,0,0); % Lumina buttons
flags.with_response_mouse    = 0; % "Lena"-Mouse buttons
flags.with_response_keyboard = 0; % Keyboard letters
flags.with_triggers   = 1; % send triggers on parallel port 
flags.with_eyetracker = strcmpi('HPC3F9',hostname()); % with eye-tracker?
flags.starting_block  = 1;
flags.pause_every_n_blocks = 2;

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
timing.cueduration = 5;
timing.interstim = @()0.3   +.2*(rand-.5);
timing.interseq = 5;
timing.startofblock = 1.5;
timing.response_release = .2;
timing.prefeedbackduration = .3;
timing.feedbackduration = 1;

%% keyboard/buttons inputs
KbName('UnifyKeyNames');
keywait = KbName('space'); % break waiting period
% break and restart current block:
keystop = KbName('ESCAPE');
% abort experiment:
if ispc
    keyquit = KbName('BackSpace');
elseif ismac
    keyquit = KbName('DELETE'); % break and restart current bloc
end
keyconfirm = KbName('Return');
keyredo = KbName('r');
% Response keys on KEYBOARD MODE
keyresp = KbName({'q','m'}); % response buttons ('L' 'R')
if ismac
    % i have to figure out why this is so...
    keyresp = [ 4 51 ];
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

trig.start      = 1;%255;

trig.cue.onset  = 64 ;
trig.cue.shape  = [ 0 8 16 ]; % 1-c / 2-s / 3-t
trig.cue.side = [ 0 32 ] ;

trig.stim.onset   =  1+2;
trig.stim.shape   = [ 0 8 16]; % 1-c / 2-s / 3-t
trig.stim.is_target = 16 ;

trig.resp.onset   =  1+4 ;
trig.resp.button  = [ 0 32 ];   % L / R
%trig.resp.is_correct = 64 ;

% Block number (iblock at the start of each block will be coded on 5 bits
trig.blockbits = 5; 

%% eyelink eye-tracker variable:
eyelink=[];

%% screen/display parameters
lumibg          = 0.0;
ppd             = 80;