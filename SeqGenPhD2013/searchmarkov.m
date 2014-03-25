%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build MM for a given SeqLength that reach an a priori level of Im
% see MMdescriptor.m to set the input structure
% depend on pso.m for optimisation
    
function [M, D] = searchmarkov(descriptor, varargin)


    %% prepare input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FRepBnd       = descriptor.FRepetBound; % A tirer aléatoirement dans un 2e temps
    NState        = descriptor.NState;
    if isempty(varargin);
        TargetIm      = descriptor.ImTarget;
        disp(sprintf('no Im specified in input, will use value in descriptor struct'));
    else
        TargetIm      = varargin{1};
    end
    SeqLength     = descriptor.SeqLength;
    FBnd          = descriptor.FreqBound;
    %% compute %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MaxIm       = -log2(1/NState);
    Marginal    = FBnd(1) + (FBnd(2) - FBnd(1))*rand(1,2);
    Marginal(3) = 1 - sum(Marginal);
    H           = entrop(Marginal);
    
    FRepet  =  FRepBnd(1) + (FRepBnd(2) - FRepBnd(1))*rand(1,NState);
    
    LBVal   = (.5*ones(1,3));
    UBVal   = (1 - FRepet);
    InitVal = LBVal + (UBVal - LBVal).*rand(1,NState);  
    
    %% sanity check
    
    if TargetIm > MaxIm | TargetIm < 0; error('TargetIm > MaxIm'); end
    if NState~=3; error('searchmarkov only accomodates NState = 3 for now'); end
    
    %% find best MM yielding sequence with target Im
    costfun = @(param) abs(TargetIm - (H - condentrop(param, Marginal, FRepet)));
     
    %[param,fval] = fmincon(costfun, InitVal, [], [], [], [], LBVal, UBVal);      
     [param,fval] = fminsearchbnd(costfun, InitVal, LBVal, UBVal);      
     
     %% prepare output
%      res.endstate = {param,fval};
%      res.bestim       = H - condentrop(param, Marginal, FRepet);
     [M, D] = buildmat(param, Marginal, FRepet, SeqLength); 
%      [~, res.Ftarget]   = condentrop(param, Marginal, FRepet);      
end

function H = entrop(D)    
    H = - sum( D(D>0) .* log2(D(D>0)));
end

function [Hc, C] = condentrop(param, D, R)
    NState    = numel(D);
    
    C         = zeros(NState);
    C(eye(NState)==1) = R;
    % randomise which idx are attrbuted to param and conversly
    C([3 4 8]) = param; % param are high transitions values
    C([7 2 6]) = 1 - sum(C,2);  
    
    D  = repmat(D', 1, NState);
    Hc = -sum(C(C>0).*log2(C(C>0)).*D(C>0));
end 

function [C, D] = buildmat(param, D, R, SeqLength)
    Ntransition = SeqLength - 1;
    NState    = numel(D);
    C         = zeros(NState);
    idx = randperm(NState);
    D(idx(1:2)) = round(D(idx(1:2)).*Ntransition) ;
    D(idx(3))  = Ntransition - sum(D(idx(1:2)));
    
    C(eye(NState)==1) = round(R.*D);
    
    % randomise which idx are attrbuted to param and conversly
    C([4 8 3]) = round(param.*D);
    C([7 2 6]) = D' - sum(C,2);  
    
    if any(sum(C, 2) ~= D'); error('matrix parameter poorly conditionned'); end
end
