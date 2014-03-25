function [Passation,errormsg] = seqPD_Experiment(participant)
global DEBUG IOReadWrite_handle
Passation=[];
errormsg =[];

% Define various parameters
seqPD_TaskParameters;

fprintf('\n');
fprintf('====================================\n');
fprintf('======= START OF THE SESSION =======\n');
fprintf('====================================\n');
fprintf('\n');

Passation.Participant = participant;
Passation.DataFolder = fullfile(...
    fileparts(fileparts(mfilename('fullpath'))),...
    'data', ...
    participant.identifier);
fprintf('Data folder should be: %s\n', Passation.DataFolder);
if DEBUG
    % When debugging, save in temporary folder
    %Passation.DataFolder = fullfile(fileparts(tempname));
end
[Data] = ImportSequences(Passation);
if isempty(Data)
    % Cancel
    error('seqPD:Cancel','Cancelled by experimenter');
end
Passation.Data = Data;

if ~exist(fileparts(Passation.DataFolder),'dir')
    fprintf('Creating folder: %s\n', Passation.DataFolder);
    mkdir((Passation.DataFolder));
end
Passation.Filename=fullfile(...
    Passation.DataFolder,...
    sprintf('seqPD_%s',datestr(now,'yyyymmdd-HHMM')));
fprintf('Saving session data in: %s\n', Passation.Filename);

% Prepare logging variables
nblocs = length(Data.Sequence);
response       = [];
response.resp = cell(1,nblocs); % response
response.rt   = cell(1,nblocs); % response time (s)
response.accu = cell(1,nblocs); % response accuracy

timecode       = [];
timecode.start = cell(1,nblocs); % start of bloc
timecode.cueonset  = cell(1,nblocs); % onset of cue
timecode.stimonset = cell(1,nblocs); % onset of stim
timecode.resptime  = cell(1,nblocs); % response time

is_training = false;
if participant.with_training
    % Training data set
    is_training = true;
    ntrials = training.ntrials;
    Data.Sequence  = num2cell(randi(3,[1,ntrials]),2)';
    Data.Target    = num2cell(randi(3),2)';
    Data.Side      = num2cell(randi(2),2)';
end

%% Let's start playing with Psychtoolbox now!!
if ~DEBUG
    %HideCursor=[];
    %FlushEvents=[];
    %ListenChar=@(x)(x);
    HideCursor;
    FlushEvents;
    ListenChar(2);
end

% Open a new Psychtoolbox Screen
video = OpenPTBScreen;
% And display an empty grey screen
Screen('FillRect',video.h,lumibg);
Screen('Flip',video.h);

% Make the textures for each shape
[texcue, cuerec, texstim, stimrec]=CreateTextures(video,stimulusfile);

% Start the eyetracker
if participant.with_eyetracker
    eyelink=InitializeEyeTracker(video,eyelink);
end

if participant.with_response_lumina
    % Open port to be used with LUMINA buttons
    % NB : Baud rate is set to 115200
    IOPort('CloseAll')
    [hport] = IOPort('OpenSerialPort','COM1');
    IOPort('ConfigureSerialPort',hport,'BaudRate=115200');
    IOPort('Purge',hport);
else
    hport = [];
end


%% Here starts the task proper
ibloc = 1;
stopped = false;
% Loop over the (8) blocks
while ibloc <= nblocs && ~stopped
    stopped = false;
    seq = Data.Sequence{ibloc};
    target = Data.Target{ibloc};
    side   = Data.Side{ibloc};
    ntrials = length(seq);
    
    % create zeros arrays to save the data
    response.resp{ibloc} = NaN*zeros(1,ntrials);
    response.rt{ibloc}   = NaN*zeros(1,ntrials);
    response.accu{ibloc} = NaN*zeros(1,ntrials);
    
    timecode.start{ibloc}       = NaN;
    timecode.cue_onset{ibloc}   = NaN;
    timecode.cue_offset{ibloc}  = NaN;
    timecode.stim_onset{ibloc}  = NaN*zeros(1,ntrials);
    timecode.stim_offset{ibloc} = NaN*zeros(1,ntrials);
    timecode.resp_press{ibloc}  = NaN*zeros(1,ntrials);
    timecode.resp_release{ibloc}= NaN*zeros(1,ntrials);
  
    
    fprintf('STARTING NEW BLOC: %02d, target = %d, side = %d\n', ibloc, target, side)    
    
    if is_training
        DrawText(video.h,'Entrainement...', 'tm');
    end
    DrawText(video.h,{'Ca va demarrer.'});
    Screen('Flip',video.h);
    
    fprintf('Appuyez sur [espace] pour d�marrer le bloc pour le participant...');
    key = WaitKeyPress([keywait keystop],timing.startofblock);
    if isequal(key,2)
        stopped=true;
        break;
    end
    fprintf(' C''est parti !\n');
    
    if participant.with_eyetracker && ~is_training > 0
        Eyelink('OpenFile','seqPD');
        Eyelink('StartRecording');
    end
    
    % Initial time stamp:
    t = Screen('Flip',video.h);
    % Send trigger at the start of the bloc
    trigger(trig.start);
    tinit = t;
    
    timecode.start{ibloc} = tinit;
    if is_training
        DrawText(video.h,'Entrainement...', 'tm');
    end
    
    % Display cue designating the target shape and side of response
    Screen('DrawTexture',video.h,texcue{target},[],cuerec{side});
    Screen('DrawingFinished',video.h);
    tonset = Screen('Flip',video.h);
    timecode.cue_onset{ibloc}   = tonset;

    % Cue is displayed for X sec
    toffset = Screen('Flip',video.h,tonset+roundfp(timing.cueduration,video.ifi));
    timecode.cue_offset{ibloc}  = toffset;

    % Loop over trials
    itrial = 1;
    while itrial <= ntrials && ~stopped
        stim = seq(itrial);

        if is_training
            fprintf('** Training ** ');
        end
        fprintf('TRIAL: % 3d | Stim: %d',itrial,stim);        
        if stim==target
            fprintf('*');
        else
            fprintf(' ');
        end
        if DEBUG
            fprintf(' xxxxxx');
        end
        
        % Stop if experimenter is pressing on ESCAPE
        if CheckKeyPress(keystop)
            stopped = true;
            break
        end
        
        % Display the stimulus on screen
        Screen('DrawTexture',video.h,texstim{stim},[],stimrec);
        if is_training
            DrawText(video.h,'[Entrainement]', 't');
        end
        Screen('DrawingFinished',video.h);
        tonset = Screen('Flip',video.h,toffset+roundfp(timing.interstim(),video.ifi));
        % Send trigger right after stimulus display
        trigger(trig.stim.onset);
        timecode.stim_onset{ibloc}(itrial) = tonset;    
        
        if is_training
            DrawText(video.h,'[Entrainement]', 't');
        end                
        % Clear the response button port, to collect response
        if participant.with_response_lumina
            IOPort('Purge',hport);
        end
        
        resp = 0;
        t = NaN;
        while resp==0 && ~stopped
           % Stop by experimenter ?
            if CheckKeyPress(keystop)
                fprintf('... stopped!');
                stopped = true;
                Screen('Flip',video.h);
                break;
            end
            % Now, if not, look at each response mode:
            if participant.with_response_lumina
% changement ICI par Philippe @ 14:18 21/02/2014
%                dat = IOPort('Read',hport);
%                t   = GetSecs;
                [dat, t] = IOPort('Read',hport);
                t = t(1);
% fin changement -----------------------------
                if ~isempty(dat) && ismember(dat(1),datresp)
                    resp = find(datresp == dat(1));
                end
            end
            if ~resp && participant.with_response_mouse
                dat = ReadParPort();
                t   = GetSecs;
                if ~isempty(dat) && any(ismember(dat,datresp))
                    resp = find(datresp == dat(1));
                end
            end
            if ~resp && participant.with_response_keyboard
                [resp,t]=CheckKeyPress(keyresp);                
            end
%             
            if resp > 0
                % Send "RESPONSE" trigger
                trigger(trig.resp.onset+trig.resp.button(resp));
                toffset = Screen('Flip',video.h);                
                rt = t-tonset;                
                accu = ((stim==target)&&(resp==side)) ||...
                    (   (stim~=target)&&(resp~=side));
                
                % Log data                
                response.resp{ibloc}(itrial) = resp;
                response.rt{ibloc}(itrial) = rt;
                response.time{ibloc}(itrial) = t;                
                response.accu{ibloc}(itrial) = accu;
                timecode.stim_offset{ibloc}(itrial) = toffset;                
                timecode.resp_press{ibloc}(itrial) = t-tinit;
             
                % Display
                resptype    = 'N/A   ';
                if accu && stim==target
                    resptype=('hit       ');
                elseif accu && stim~=target
                    resptype=('c.rej.    ');
                elseif ~accu && stim==target
                    resptype=('      miss');
                elseif ~accu && stim~=target
                    resptype=('    f.pos.');
                end
                if DEBUG
                    fprintf('\b\b\b\b\b\b');
                end
                fprintf('|RT:% 6dms',round(rt*1000));
                fprintf(' resp:[%d] = %s', resp, resptype);
                
                % Wait patient to release the buttons
%                 lastkeypress=GetSecs;
%                 fprintf(' [WAITING RELEASE] '); 
%                 while resp || (t-lastkeypress) < timing.response_release
%                     if participant.with_response_keyboard
%                         resp = resp || CheckKeyPress(keyresp);
%                     end
%                     if participant.with_response_lumina
%                         dat = IOPort('Read',hport);
%                         resp = resp || ~isempty(dat);                        
%                     end                    
%                     if participant.with_response_mouse
%                         %TO DO
%                     end    
%                     t = GetSecs;
%                     if resp
%                         lastkeypress=t;                        
%                     end
%                 end
%                 fprintf('... ok!');
%                 timecode.resp_release{ibloc}(itrial) = lastkeypress;
            elseif DEBUG
                fprintf('\b\b\b\b\b\b% 6d',round(1000*(GetSecs-tonset)));
            end
        end        
        
        if is_training && ~stopped
            if itrial < training.nfeedbacktrials
                DrawText(video.h,'[Entrainement]', 't');
                t = Screen('Flip',video.h,toffset+timing.prefeedbackduration);
                DrawText(video.h,'[Entrainement]', 't');
                if accu
                    DrawText(video.h,'Correct !');
                else
                    DrawText(video.h,'Erreur !');
                    beep;
                end
                toffset = Screen('Flip',video.h);
                DrawText(video.h,'[Entrainement]', 't');
                toffset = Screen('Flip',video.h,toffset+timing.feedbackduration);
                
            end
        end
        
        % Save data in temporary file just in case...
        Passation.Data.Response = response;
        Passation.Data.Timecode = timecode;
        save([Passation.Filename '_tmp'],'Passation');
        
        % Go to next trial
        itrial = itrial + 1;
        fprintf('\n');
        
    end %loop on ibloc
    fprintf('\n');
    
    if is_training
        if ~stopped
            t=GetSecs;
            stopped = false;
            while (GetSecs()-t)<5 && ~stopped && ~stopped
                DrawText(video.h,{...
                    'Pr�parez-vous pour un autre bloc d''entrainement...',...
                    '[ "ESC" pour interrompre et passer a la suite ]',...
                    '',...
                    sprintf('%d',round(5-(GetSecs()-t)))});
                Screen('Flip',video.h,tonset);
                if CheckKeyPress(keystop)
                    stopped = true;
                end
            end
            Data.Sequence  = num2cell(randi(3,[1,ntrials]),2)';
            Data.Target    = num2cell(randi(3),2)';
            Data.Side      = num2cell(randi(2),2)';
        end
        
        if stopped
            % Training was manually stopped. Continue with the task?
            is_training = false;
            stopped=false;            
            DrawText(video.h,{...
                'Cette fois, nous allons passer' ...
                '� la t�che proprement dite.'},'tm');
            fprintf('On continue vers blocs de t�che...\n');
            WaitSecs(.3);            
            Data=Passation.Data;            
        end
    else
        OnlineMonitoring(Passation,'bloc',ibloc);
        ibloc = ibloc + 1;
    end
    
end

if participant.with_response_lumina
     % Close response port
    IOPort('Close',hport);    
end

if stopped
    sufx = '_stopped';
else
    sufx = '';
end
Passation.Filename=[Passation.Filename sufx];

% Save data
save(Passation.Filename,'Passation');
%filename = sprintf('seqPD_%s_bloc%02d_%s%s.mat',participant.identifier,ibloc,datestr(now,'yyyymmdd-HHMM'),sufx);
%save(sprintf('%s/%s',foldername,filename),'participant','stimulus','response','timecode');

% Close video etc.
Priority(0);
Screen('CloseAll');
FlushEvents;
ListenChar(0);
ShowCursor;
video = [];


%
%% THIS IS THE END
return


%
% %save eye-tracker data
% if participant.with_eyetracker
%     filename = sprintf('UBBIC_MEG_%s_bloc%02d_%s%s.edf',participant.identifier,ibloc,datestr(now,'yyyymmdd-HHMM'),sufx);
%     Eyelink('StopRecording');
%     Eyelink('CloseFile');
%     nattempts = 0;
%     while nattempts < 10
%         nattempts = nattempts+1;
%         status = Eyelink('ReceiveFile',[],sprintf('%s/%s',foldername,filename));
%         if status > 0
%             break
%         end
%     end
%     if status <= 0
%         warning('Could not receive eye-tracker datafile %s!',filename);
%     end
% end
%
% % close response port
% if participant.with_meg
%     % close trigger port
%     CloseParPort;
%     % close response port
%     IOPort('Close',hport);
% end
% % close eye-tracker
% if participant.with_eyetracker
%     Eyelink('ShutDown');
% end
%
% if participant.with_mri
%     IOPort('Close',hport);
%     hport = [];
% end

% catch
%
%     errormsg = lasterror;
%
%     if exist('ibloc','var') && ibloc > 0
%
%         % save data
%         filename = sprintf('seqPD_%s_bloc%02d_%s_crash.mat',participant.identifier,ibloc,datestr(now,'yyyymmdd-HHMM'));
%         save(sprintf('%s/%s',foldername,filename),'participant','stimulus','response','timecode');
%
%         % save eye-tracker data
%         if participant.with_eye
%             filename = sprintf('UBBIC_MEG_%s_bloc%02d_%s_crash.edf',participant.identifier,ibloc,datestr(now,'yyyymmdd-HHMM'));
%             Eyelink('StopRecording');
%             Eyelink('CloseFile');
%             nattempts = 0;
%             while nattempts < 10
%                 nattempts = nattempts+1;
%                 status = Eyelink('ReceiveFile',[],sprintf('%s/%s',foldername,filename));
%                 if status > 0
%                     break
%                 end
%                 if status <= 0
%                     warning('Could not receive eye-tracker datafile %s!',filename);
%                 end
%             end
%             Eyelink('ShutDown');
%         end
%
%     end
%
%     if participant.with_meg
%         % close trigger port
%         CloseParPort;
%         % close response port
%         IOPort('Close',hport);
%     end
%
%     % close video
%     if exist('video','var') && ~isempty(video)
%         Priority(0);
%         Screen('CloseAll');
%         FlushEvents;
%         ListenChar(0);
%         ShowCursor;
%         video = [];
%     end
%
%     errormsg = lasterror;
%
%     % close response port
%     if participant.with_mri && exist('hport','var') && ~isempty(hport)
%         IOPort('Close',hport);
%         hport = [];
%     end
%
%
% end


function [E]=ImportSequences(Passation)
% Read sequences form file
global DEBUG;
E=[];
if nargin<1
    SequenceFile=[];
else
    % Try to find sequence file in participant data folder
    SequenceFile = dir(fullfile(Passation.DataFolder,'sequence*.mat'));
    SequenceFile = arrayfun(@(x)fullfile(Passation.DataFolder, x{1}),...
        {SequenceFile.name}, 'UniformOutput', 0);
end
if DEBUG
    [filename, pathname] = uigetfile('sequence*.mat', 'Pick a sequence MAT file');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel')
        return
    end
    SequenceFile=fullfile(pathname,filename);
end
if isempty(SequenceFile)
    error('seqPD:NoSequence', 'No sequence file found in in data folder %s', Passation.DataFolder)
end
if iscell(SequenceFile)
    if numel(SequenceFile)>1
        error('seqPD:MultipleSequence','Multiple sequence files in data folder %s', Passation.DataFolder)
    else
        SequenceFile = SequenceFile{1};
    end
end
fprintf('Using stimulus sequence from Experience #%d in file: %s\n', i, SequenceFile);
load(SequenceFile)

E = Experience;
E.SequenceFile = SequenceFile;
if ~isfield(E, 'Target')
    error('seqPD:NoTarget','No target defined in sequence file');
    %E.Target = num2cell([ 1 1  2 2  3 3  1 1  2 2  3 3 ]);
end
if ~isfield(E, 'Side')
    t=cell2mat(Experience.Target);
    E.Side=zeros(1,numel(t));
    for j = unique(t(:)')
        n=sum(t==j);
        E.Side(t==j)=randpick(repmat(1:2,1,ceil(n/2)),n);
    end
    E.Side = num2cell(E.Side);
end

function trigger(trig)
global participant
if participant.with_meg
    WriteParPort(trig);
    WaitSecs('UntilTime',t+0.010);
    WriteParPort(0);
end

function video = OpenPTBScreen()
global DEBUG
ppd=evalin('caller', 'ppd');
%Screen('Preference','VisualDebuglevel',3);
PsychImaging('PrepareConfiguration');
%PsychImaging('AddTask','General','UseFastOffscreenWindows');
%PsychImaging('AddTask','General','NormalizedHighresColorRange');

% By default we display on the auxillary monitor (ie. not the main one=0)
video.i = max(Screen('Screens'));
frame = []; % full screen
video.res = Screen('Resolution',video.i);
if DEBUG
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end
if video.i<=1
    if DEBUG
        % In DEBUG mode, we may use the main one, and not full screen
        frame = [ video.res.width/2 150 video.res.width/2+800 750];
    else
        error('seqPD:SingleMonitor', 'seqPD should run on dual monitor display')
    end
end

% Now open a Psychtoolbox Window
if isempty(frame)
    video.h = PsychImaging('OpenWindow',video.i);
else
    video.h = PsychImaging('OpenWindow',video.i,0,frame);
end
[video.x,video.y] = Screen('WindowSize',video.h);
Screen('TextFont',video.h,'Arial');
Screen('TextSize',video.h,round(0.33*ppd));
Screen('TextStyle',video.h,0);
video.ifi = 0.0167;
if DEBUG
    return
end
Priority(MaxPriority(video.h));
return
% Some further setup
%Screen('ColorRange',video.h,255);
video.ifi = Screen('GetFlipInterval',video.h,100,50e-6,10);
Screen('BlendFunction',video.h,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
Priority(MaxPriority(video.h));


function [texcue, cuerec, texstim, stimrec]=CreateTextures(video,stimulusfile)
% Load the pictures of the cue and stims in graphical memory
fprintf('Reading Image files into Textures...\n');
texstim = cell(1,3);
texcue = cell(1,3);
for i=1:3
    bmp = double(imread(stimulusfile{i}));
    % Stimuli textures:
    texstim{i} = Screen('MakeTexture',video.h,bmp);
    % Change black pixels to yellow for cues
    % First, list the black pixels
    k2y = find(all(bmp==0,3));
    bmp=permute(bmp,[3 1 2]);
    % We don't use yellow background (we keep it black)
    % Yellow in RGB is: 255 255 10
    bmp([1 2],k2y)=0; %255;
    bmp(3,k2y)=0;%10;
    bmp=permute(bmp,[2 3 1]);
    % Instead we add a white border to cues
    bmp(1  ,  :,:)=255;
    bmp(end,  :,:)=255;
    bmp(:  ,  1,:)=255;
    bmp(:  ,end,:)=255;
    
    % Cues textures:
    texcue{i} = Screen('MakeTexture',video.h,bmp);
    clear('k2y','bmp');
end
% Rectangular position of stimuli/cues textures on screen
% Manually set w/h of 241 pixels from BMP files
cuerec{1} = CenterRectOnPoint([0 0 241 241],video.x*1/4,video.y*2/3);
cuerec{2} = CenterRectOnPoint([0 0 241 241],video.x*3/4,video.y*2/3);
stimrec   = CenterRectOnPoint([0 0 241 241],video.x/2,video.y/2);

function el=InitializeEyeTracker(video,el)
% Start the Eyelink eye tracker
if nargin<2
    el=[];
end
if isempty(el)
    if EyelinkInit() ~= 1
        error('Could not initialize EyeLink connection!');
    end
    el = EyelinkInitDefaults(video.h);
end
EyelinkDoTrackerSetup(el);


function hport=OpenParallelPort
global DEBUG
% open trigger port
OpenParPort;
ReadParPort;
global DEBUG;
if DEBUG
    return
end
% Test each response buttons
fprintf('\n\n\n');
fprintf('TESTING RESPONSE BUTTONS...\n');
for i = 1:2
    fprintf('WAITING FOR [%s] BUTTON... ',lptresp{i});
    dat = [];
    while isempty(dat)
        if CheckKeyPress(keyquit)
            fprintf('ABORTED!\n');
            error('Experiment aborted!');
        end
        dat = ReadParPort();
    end
    if dat(1) == lptresp(i)
        fprintf('OK!\n');
    else
        fprintf('ERROR! (found %d)\n',dat(1));
        error('Invalid configuration of [%s] button!',i);
    end
end
fprintf('\n\n\n');

% 
% % Open Parallel Port for TTL markers & response buttons
% if 0%participant.with_buttons
%     global IOReadWrite_handle
%     IOReadWrite_handle
%     if isempty(IOReadWrite_handle)
%         fprintf('Open Parallel Port...\n')
%         evalin('base', [...
%             'javaaddpath c:/users/expe/seqPD/psychtoolbox/IoReadWrite/usd/IOReadWrite.jar;'...
%             'import usd.IOReadWrite;'...
%             'global IOReadWrite_handle;'...
%             'IOReadWrite_handle = IOReadWrite']);
%     end
%     ReadParPort
% end




function obj=PrepareLog(obj,n)
if nargin<2
    n=1;
end
switch obj
    case 'newbloc'
        obj=struct(...
            'target',NaN,...
            'side',NaN,...
            'starttime',NaN,...
            'cue_onset',NaN,...
            'cue_offset',NaN,...
            'trial',[]);
    case 'newtrial'
        obj=struct(...
            'stim',NaN,...
            'stim_onset',NaN,...
            'resp',NaN,...
            'resp_time',NaN,...
            'rt',NaN,...
            'accu',NaN);
end
obj=repmat(obj,[n 1]);


function OnlineMonitoring(info,stage,ibloc)
% Output text on-line en console: Acc locale: n=10 essais
% Rep target/nontarget
% info header
% graphe
% + RT/predicVve info (pour les hits)
% + sVm (eg. Bleu,S>S)
% + acVon (rouge,S>A)
if isfield(info,'Data')
    P=info;
    log =P.Data.Log;
    assignin('base','P',P)
    
else
    log=info;           
end
accbloc = 100*mean([log.bloc(end).trial.accu]);
acctask = NaN;
assignin('base','log',log)
switch stage
    case 'bloc'
        fprintf('Accuracy for bloc: %f%% / whole task: %f%%',accbloc,acctask);
        fprintf('\n');
        try
            rt = 1000*[P.Data.Log.bloc(ibloc).trial.rt];
            accu = [P.Data.Log.bloc(ibloc).trial.accu];
            pred = [P.Data.IdealPred(ibloc).Stim.Actual];
            % Plot RT/Pred for hits only
            edges=prctile(pred(accu==1),[0:20:99]);
            [c,i_c]=histc(pred(accu==1),edges);
            bar(1:5,groupfun(rt(accu==1),i_c,'mean'));
            xlabel('Predictability')
            ylabel('Reaction Time (ms)')
            
            barerrorbar(1:5,...
                groupfun(rt(accu==1),i_c,'mean'),...
                groupfun(rt(accu==1),i_c,'stderr'));
            xlabel('Predictability')
            ylabel('Reaction Time (ms)')
        end
end
