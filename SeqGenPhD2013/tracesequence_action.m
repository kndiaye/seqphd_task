%% build sequence from Markov Chain - approximate algorithm

function [seq, pred, Target] = tracesequence_action(M)

    % initialize a few variables %%%%%%%%%%%%%%%%
    SeqLength  = sum(sum(M)) + 1; % nombre de transition O1 + 1
    NState     = size(M, 1);
    StartState = randi(NState, 1, 1);
    Target     = randi(NState, 1, 1);
    A = M;
    Fobs = ones(1, NState);       % observed frequencies
    Tobs = ones(NState)/NState;   % observed transitions
    seq  = nan(1, SeqLength); 
    pred = nan(1, SeqLength); 

    % first element in the sequence %%%%%%%%%%%%%%%%
    idx = 1;
    InState = StartState;
    seq(1)  = StartState;
    Fobs(InState) = Fobs(InState) + 1;

    while sum(~isnan(seq))<SeqLength;

        % draw next sequence state %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if sum( M(InState,:)) ==0    
            M(InState,:) = A(InState,:);        
        end

        P = M(InState,:) / sum(M(InState,:));
        OutState = find(rand(1) <= cumsum(P), 1, 'first');
        M(InState, OutState) = M(InState, OutState) - 1;

        % store sequence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        idx      = idx+1;
        seq(idx) = OutState;         
        % compute surp and pred for current state %%%%%%%%%%%%%%%%
        % note: we use ex-ante predictability / i.e before the outcome
        % of the current decision is being observed AND Fobs/Tobs updated            
        allpred   = additionalcomputation(Fobs, Tobs, Target);           
        pred(idx) = allpred(seq(idx-1), 1+(seq(idx)~=Target)); % Target in col1 / Non Target in col2   
        
        % update surprise and predictability estimates %%%%%%%%%%       
        Fobs(OutState)          = Fobs(OutState) + 1;
        Tobs(InState, OutState) = Tobs(InState, OutState) + 1;
        
        % update State %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
        InState  = OutState;  
        
    end

end

function allpred = additionalcomputation(Fobs, Tobs, Target)   % modif ICI pour renvoyer toutes les mesures pertinentes 
    NState  = numel(Fobs);  
    allfreq = Fobs ./ sum(Fobs);        
      
    Tobs      = [Tobs(:,Target) sum(Tobs(:,setdiff(1:NState, Target)), 2)]; 
    Tobs(:,2) = Tobs(:,2) - 1/NState;
    allpc     = bsxfun(@rdivide, Tobs, sum(Tobs,2));     % check HERE  
    
    allfreq = repmat(allfreq', 1, 2);    
    allpred = reshape(log2(allpc./allfreq), NState, 2);            
end