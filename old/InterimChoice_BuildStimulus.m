function [stimulus,practice] = InterimChoice_BuildStimulus(theta,kappa)

if nargin < 2
    error('missing input argument(s).');
end

if ~isvector(theta) || ~isvector(kappa) || numel(theta) ~= numel(kappa)
    error('theta and kappa should have the same size.');
end
if length(unique(kappa)) > 1
    error('this function has not been tested for unequal kappas.');
end

addpath('./Toolbox/');

shuffle = @(x)x(randperm(numel(x)));
rsample = @(x)x(ceil(rand*numel(x)));

randvm_rad = @(siz,t,k)mod(randraw('vonmises',[t*2,k],siz)/2,pi);
randvm_deg = @(siz,t,k)randvm_rad(siz,t/180*pi,k)*180/pi;

pdfvm_rad = @(x,t,k)exp(k.*cos(2*(x-t)))./(pi*besseli(0,k));
pdfvm_deg = @(x,t,k)pdfvm_rad(x/180*pi,t/180*pi,k)/180*pi;

theta = sort(mod(theta,180),'descend');
kappa = max(kappa,0);

thetatol = 3;
kappatol = 0.04;

ntol = 2*3; % multiply ntol by 3 because three repetitions of the same trial

iid    = repmat([1:36],[1,3]);
task   = kron([0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2],ones(1,4));
categ  = kron([1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,3,3,3],ones(1,4));
color  = kron([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,1,2,3,1,2,3],ones(1,4));
nitemi = repmat([3,3,6,6],[1,27]);
nitemf = repmat([3,6,3,6],[1,27]);

i_final = [];

nblocs = 2;

for ibloc = 1:nblocs

    i_avail = { ...
        find(task == 0 & categ == 1 & nitemi == 3 & nitemf == 3), ...
        find(task == 0 & categ == 1 & nitemi == 3 & nitemf == 6), ...
        find(task == 0 & categ == 1 & nitemi == 6 & nitemf == 3), ...
        find(task == 0 & categ == 1 & nitemi == 6 & nitemf == 6), ...
        find(task == 0 & categ == 2 & nitemi == 3 & nitemf == 3), ...
        find(task == 0 & categ == 2 & nitemi == 3 & nitemf == 6), ...
        find(task == 0 & categ == 2 & nitemi == 6 & nitemf == 3), ...
        find(task == 0 & categ == 2 & nitemi == 6 & nitemf == 6), ...
        find(task == 0 & categ == 3 & nitemi == 3 & nitemf == 3), ...
        find(task == 0 & categ == 3 & nitemi == 3 & nitemf == 6), ...
        find(task == 0 & categ == 3 & nitemi == 6 & nitemf == 3), ...
        find(task == 0 & categ == 3 & nitemi == 6 & nitemf == 6), ...
        ...
        find(task == 1 & categ == 1 & nitemi == 3 & nitemf == 3), ...
        find(task == 1 & categ == 1 & nitemi == 3 & nitemf == 6), ...
        find(task == 1 & categ == 1 & nitemi == 6 & nitemf == 3), ...
        find(task == 1 & categ == 1 & nitemi == 6 & nitemf == 6), ...
        find(task == 1 & categ == 2 & nitemi == 3 & nitemf == 3), ...
        find(task == 1 & categ == 2 & nitemi == 3 & nitemf == 6), ...
        find(task == 1 & categ == 2 & nitemi == 6 & nitemf == 3), ...
        find(task == 1 & categ == 2 & nitemi == 6 & nitemf == 6), ...
        find(task == 1 & categ == 3 & nitemi == 3 & nitemf == 3), ...
        find(task == 1 & categ == 3 & nitemi == 3 & nitemf == 6), ...
        find(task == 1 & categ == 3 & nitemi == 6 & nitemf == 3), ...
        find(task == 1 & categ == 3 & nitemi == 6 & nitemf == 6), ...
        ...
        find(task == 2 & categ == 1 & nitemi == 3 & nitemf == 3), ...
        find(task == 2 & categ == 1 & nitemi == 3 & nitemf == 6), ...
        find(task == 2 & categ == 1 & nitemi == 6 & nitemf == 3), ...
        find(task == 2 & categ == 1 & nitemi == 6 & nitemf == 6), ...
        find(task == 2 & categ == 2 & nitemi == 3 & nitemf == 3), ...
        find(task == 2 & categ == 2 & nitemi == 3 & nitemf == 6), ...
        find(task == 2 & categ == 2 & nitemi == 6 & nitemf == 3), ...
        find(task == 2 & categ == 2 & nitemi == 6 & nitemf == 6), ...
        find(task == 2 & categ == 3 & nitemi == 3 & nitemf == 3), ...
        find(task == 2 & categ == 3 & nitemi == 3 & nitemf == 6), ...
        find(task == 2 & categ == 3 & nitemi == 6 & nitemf == 3), ...
        find(task == 2 & categ == 3 & nitemi == 6 & nitemf == 6)};
    
    for i = 1:3
        
        while true
            i_sampl = [];
            for j = 1:length(i_avail)
                i_sampl = cat(2,i_sampl,rsample(i_avail{j}));
            end
            if ...
                    all(hist(color(i_sampl),[0,1,2,3]) == [24,4,4,4]) && ...
                    nnz(color(i_sampl) == categ(i_sampl)) == 4
                break
            end
        end
        
        while true
            i_sampl = shuffle(i_sampl);
            i_color = i_sampl(color(i_sampl) > 0);
            if ...
                    ~HasConsecutiveValues(task(i_sampl),4) && ...
                    ~HasConsecutiveValues(categ(i_sampl),4) && ...
                    ~HasConsecutiveValues(color(i_sampl),4,[0]) && ...
                    ~HasConsecutiveValues(nitemi(i_sampl),4) && ...
                    ~HasConsecutiveValues(nitemf(i_sampl),4) && ...
                    ~HasConsecutiveValues(color(i_color) == categ(i_color),2,[false])
                break
            end
        end
        
        i_final = cat(2,i_final,i_sampl);
        for j = 1:length(i_avail)
            i_avail{j} = setdiff(i_avail{j},i_sampl);
        end
        
    end

end

iid    = iid(i_final);
task   = task(i_final);
categ  = categ(i_final);
color  = color(i_final);
nitemi = nitemi(i_final);
nitemf = nitemf(i_final);

ntrials = length(iid);

nitems = nitemi+nitemf;
nitems_all = unique(nitemi+nitemf);

thetatar = [0,60,120];
kappatar = kappa(1);
pctar = nan(3,1);
for i = 1:3
    angle = randvm_deg([1e6,nitems_all(i)],0,kappa(1));
    logpr = nan(3,1e6);
    for k = 1:3
        logpr(k,:) = sum(log(pdfvm_deg(angle,thetatar(k),kappatar)),2);
    end
    [~,k] = max(logpr,[],1);
    pctar(i) = mean(k == 1);
end

while true
    
    uid = zeros(1,ntrials);
    angle = cell(1,ntrials);
    
    uidcur = 1;
    for iidcur = 1:36
        i0 = shuffle(find(task == 0 & iid == iidcur));
        i1 = shuffle(find(task == 1 & iid == iidcur));
        i2 = shuffle(find(task == 2 & iid == iidcur));
        ni = length(i0);
        nitem_temp = nitemi(i0(1))+nitemf(i0(1));
        categ_temp = categ(i0(1));
        angle_temp = randvm_deg([ni,nitem_temp],theta(categ_temp),kappa(categ_temp));
        for ii = 1:ni
            uid([i0(ii),i1(ii),i2(ii)]) = uidcur;
            angle{i0(ii)} = angle_temp(ii,:);
            angle{i1(ii)} = angle_temp(ii,:);
            angle{i2(ii)} = angle_temp(ii,:);
            uidcur = uidcur+1;
        end
    end
    
    logpr = nan(3,ntrials);
    for k = 1:3
        logpr(k,:) = cellfun(@(x)sum(log(pdfvm_deg(x,theta(k),kappa(k)))),angle);
    end
    [~,k] = max(logpr,[],1);
    pcmax = nan(3,1);
    pctol = nan(3,1);
    for i = 1:3
        ifilt = find(nitemi+nitemf == nitems_all(i));
        nfilt = length(ifilt);
        pcmax(i) = mean(k(ifilt) == categ(ifilt));
        pctol(i) = (ntol/2)/nfilt;
    end
    
    if all(abs(pcmax-pctar) < pctol)
        break
    end
    
end

fprintf('\n');
fprintf('p[correct|n(samples)] >> target   = %s\n',num2str(pctar','%.3f '));
fprintf('                      >> obtained = %s\n',num2str(pcmax','%.3f '));
fprintf('\n');

nblocs = ntrials/36;

stimulus        = [];
stimulus.theta  = theta;
stimulus.kappa  = kappa;
stimulus.uid    = cell(1,nblocs);
stimulus.task   = cell(1,nblocs);
stimulus.categ  = cell(1,nblocs);
stimulus.color  = cell(1,nblocs);
stimulus.angle  = cell(1,nblocs);
stimulus.nitems = cell(1,nblocs);
stimulus.nitemi = cell(1,nblocs);
stimulus.nitemf = cell(1,nblocs);

for ibloc = 1:nblocs
    
    itrial = (ibloc-1)*36+[1:36];
    
    stimulus.uid{ibloc}    = uid(itrial);
    stimulus.task{ibloc}   = task(itrial);
    stimulus.categ{ibloc}  = categ(itrial);
    stimulus.color{ibloc}  = color(itrial);
    stimulus.angle{ibloc}  = angle(itrial);
    stimulus.nitems{ibloc} = nitemi(itrial)+nitemf(itrial);
    stimulus.nitemi{ibloc} = nitemi(itrial);
    stimulus.nitemf{ibloc} = nitemf(itrial);
    
end

practice = [];

fnames = fieldnames(stimulus);
for i = 1:length(fnames)
    if iscell(stimulus.(fnames{i}))
        practice.(fnames{i}) = stimulus.(fnames{i}){nblocs};
    end
end
practice.uid(:) = 0;

kfact = kron([3,2,1],ones(1,12));
for itrial = 1:36
    nitem_temp = practice.nitems(itrial);
    categ_temp = practice.categ(itrial);
    angle_temp = randvm_deg([1,nitem_temp],theta(categ_temp),kappa(categ_temp)*kfact(itrial));
    practice.angle{itrial} = angle_temp;
end

end