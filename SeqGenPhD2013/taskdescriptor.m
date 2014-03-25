%% Markov chain descriptor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SeqGen only accomodate 1 order MM with NState = 3 for the moment

%resultfilename = 'test.mat';

%% possible flags are:
% 1. stimulus2stimulus
% 2. stimulus2action
descriptor.flags = 'stimulus2action';

%%
descriptor.NState    = 3; % Nbre d'état
descriptor.SeqLength = 100; % longueur d'une sequence
descriptor.FRepetBound = [.01 .08]; % min-max de frequence de repetetion 
descriptor.ImTarget  = 0.1;            % DEPRECATED   
descriptor.FreqBound = .33 + [-.05, +0.05]; %  probabilite marginale

%% Experiment descriptor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('/Users/Marine')
    experiment.ResultDir      = '/Users/Marine/.dropbox-two/Dropbox/seqPD/sequences/marine';
else
    experiment.ResultDir      = '/Users/erack/Dropbox/BEBG_MISC/seqPD/matlab/sequences';
end
experiment.NSampleXp      = 10^6; % taille de la collection d'experience à partir de laquelle on tire
experiment.NExperience    = 1; % Nbre d'experience generee
experiment.NSeqPerXp      = 16;% Nbre de sequence par experience
experiment.ImBnd          = [0.2, 2/3]*-log2(1/descriptor.NState); % gamme mutuelle pour generer les sequence /r valeur max theorique
experiment.ImStep         = .05;
experiment.NMarkovPerStep = 20; % Nbre de chaine de markov genere par step
experiment.NSeqPerMM      = 20; % Nbre de sequence par chaine

experiment.ResultFilename = sprintf('sequence_%dxp_%dseq_%dlength_%s.mat', ...
    experiment.NExperience, experiment.NSeqPerXp, descriptor.SeqLength, ...
    datestr(now,30));