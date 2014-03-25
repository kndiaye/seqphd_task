%%%%%%%%%%%%%%%%% build sequence for new experiment %%%%%%%%%%%%%%%%%%%%%%%
%% Ph Domenech, 2013
% - correction of some minor bugs on feb 2014
% - implement optim on S=>A transition on feb 2014

%  set sequence / experiment variables in descriptor.m
clc;
clear all;
delete(gcp);
if exist('/Users/Marine')
    rng('default') 
    %matlabpool open 2;
else    
    matlabpool open 4; %2
end

startingtime = tic;
%% 1. load task/sequence description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('/Users/Marine')
    cwdpath = '/Users/Marine/.dropbox-two/Dropbox/seqPD/matlab/SeqGenPhD2013';
else
    cwdpath = '/Users/erack/Dropbox/bebg_misc/seqpd/matlab/SeqGenPhD2013';
end
addpath(cwdpath);
taskdescriptor;

%% 2. generate a MM spanning the space of admissible Im %%%%%%%%%%%%%%%%%%%
ImTarget = experiment.ImBnd(1):experiment.ImStep:experiment.ImBnd(2);

for i = 1:(numel(ImTarget)*experiment.NMarkovPerStep)
%parfor i = 1:(numel(ImTarget)*experiment.NMarkovPerStep)
    im = mod(i, numel(ImTarget)) + 1;    
    M(:,:,i) = searchmarkov(descriptor, ImTarget(im));    
end

%% 3. generate a pool of sequence from MM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('generate sequence pool');
stic = tic;
rng(now);

NSeqPool = size(M,3)*experiment.NSeqPerMM;
seq  = nan(NSeqPool, descriptor.SeqLength);
pred = nan(NSeqPool, descriptor.SeqLength);
target = nan(NSeqPool, 1);

switch descriptor.flags
case 'stimulus2stimulus'    
    for i=1:NSeqPool       
    %parfor i=1:NSeqPool       
        idx = mod(i, size(M,3)) + 1;    
        [seq(i,:), pred(i,:)] = tracesequence(M(:,:,idx));    
    end
case 'stimulus2action'        
    for i=1:NSeqPool       
    %parfor i=1:NSeqPool       
        idx = mod(i, size(M,3)) + 1;    
        [seq(i,:), pred(i,:), target(i)] = tracesequence_action(M(:,:,idx));    
    end    
end

fprintf('sequence pool size is %d... \n', NSeqPool);
fprintf('took %0.5f to build sequence pool ... \n', toc(stic));

%% 4. sample experiment from sequence pool (nexperiment << nsequencepool) %
disp('resample from sequence pool')
stic = tic;
stic2 = stic;
nbin=100;
for i=1:experiment.NSampleXp
%parfor i=1:experiment.NSampleXp
   emory(i,:) = randi(size(pred, 1), [1, experiment.NSeqPerXp]);
   sub        = pred(emory(i,:), 2:descriptor.SeqLength);   
   x          = hist(sub(:), nbin);
   dev(i)     = sum(abs(x - round(sum(x)/nbin)));   
   stddev(i)  = diff(prctile(sub(:), [.1 99]));
   prop(i)    = sum(sub(:)<=0)/numel(sub);   
if mod(i, 10000)==0; fprintf('%0.5f secondes par samples ... \n', toc(stic)/10000); stic = tic; end
end

% centre réduit les critères d'optimisation: uniformité, spread, skew
stddev = stddev - mean(stddev);
stddev = stddev /std(stddev);
stddev = stddev - min(stddev) + 1;

dev = dev - mean(dev);
dev = dev /std(dev);
dev = dev - min(dev) + 1;

prop = prop - mean(prop);
prop = prop /std(prop);
prop = prop - min(prop) + 1;

[~, idx]   = sort(dev./(stddev.*prop));

fprintf('took %0.5f to build %d sequence bundle from seq pool ... \n', toc(stic2), experiment.NSampleXp);

%% 5. build experiment %%%%%%%%
disp('build experiment')

for Nxp  = 1:experiment.NExperience;
      ongoingidx = idx(Nxp);        
      xx         = seq(emory(ongoingidx,:), :);
      xtarget    = target(emory(ongoingidx,:));
        
    for NSeq = 1:experiment.NSeqPerXp

        Experience(Nxp).Sequence{NSeq} = xx(NSeq, :); 
        Experience(Nxp).Target{NSeq}   = xtarget(NSeq); 
        x = Experience(Nxp).Sequence{NSeq};
        
        % -----------------------------------------------------
        % NOTE: je laisse ce calcul pour compatibilite avec les versions
        % precedentes de la tache, mais pas necessaire car tout est recalcule
        % lors de l'analyse des resultats, et que je n'ai pas implemente
        % ici le flag pour calculer la pred S=>A quand celle-ci est
        % utilisee pour selectionner les sequences
        YN = zeros(descriptor.NState) + 1/descriptor.NState;
        M = sum(YN,2); 
        M(x(1)) = M(x(1)) + 1;
        M = M / sum(M);
        Y = bsxfun(@rdivide, YN, sum(YN,2));
        
        % first element ---------------------------------------------------
        Experience(Nxp).IdealSurp(NSeq).Stim.Actual(1) = -log2(M(x(1)));                
        for outcome=1:max(x)
            f(1, outcome) = -log2(M(outcome));
        end
        
        % all the other elements in the sequence --------------------------
        for l=2:descriptor.SeqLength

            % compute some metrics from ex-ante stats
            Experience(Nxp).IdealPred(NSeq).Stim.Actual(l) = log2(Y(x(l-1), x(l))/M(x(l)));         
            Experience(Nxp).IdealSurp(NSeq).Stim.Actual(l) = -log2(M(x(l)));
            for outcome=1:max(x)
                f(l, outcome) = -log2(M(outcome));
            end

            Experience(Nxp).IdealCtxtEntropy(NSeq, l) = -sum(Y(x(l-1), :).*log2(Y(x(l-1), :)));

            % update transition matrix and marginals
            YN(x(l-1), x(l)) = YN(x(l-1), x(l)) + 1;                
            M = sum(YN,2); M = M / sum(M);
            Y = bsxfun(@rdivide, YN, sum(YN,2));

        end     
           
        Experience(Nxp).IdealEntropy{NSeq}     = sum(2.^(-f).*f, 2);
            
    end
end

%% 6. save results

save(fullfile(experiment.ResultDir, experiment.ResultFilename), 'Experience');
disp(sprintf('%d experiment, including %d sequences \n', experiment.NExperience, experiment.NSeqPerXp));
fprintf('took %0.5f s to run ... \n', toc(startingtime));

matlabpool close;