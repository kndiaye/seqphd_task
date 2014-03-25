% M = [0 8 4 4;
%      4 0 4 8;
%      8 4 0 4;
%      4 4 8 0];


%% StartState = 2;

NState    = length(M); 
SeqLength = sum(sum(M)); % note: ICI on devrait corriger pour l'état initial

%% calcul Entropy %%%%%%%%%

D = sum(M,2)/SeqLength;
H = - sum( D(D>0) .* log2(D(D>0)));

%% calcul Entropy conditionnelle

C = M ./ repmat(sum(M,2), 1, NState);
D = repmat(D, 1, NState);
Hc = -sum(C(C>0).*log2(C(C>0)).*D(C>0));

%% calcul de l'information mutuelle
Im = H-Hc;

%%
disp(M)
disp(Im)