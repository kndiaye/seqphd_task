function [observer] = InterimChoice_BuildIdealObserver(stimulus,bmax)

if nargin < 2
    bmax = inf;
end
if nargin < 1
    error('missing input argument(s).');
end

if isfield(stimulus,'n')
    error('input data should not be squeezed.');
end

pdfvm_rad = @(x,t,k)exp(k.*cos(2*(x-t)))./(pi*besseli(0,k));
pdfvm_deg = @(x,t,k)pdfvm_rad(x/180*pi,t/180*pi,k)/180*pi;

softmax = @(q,b,e,dim)e/size(q,dim)+(1-e)*bsxfun(@rdivide,exp(b*q),sum(exp(b*q),dim));
hardmax = @(q,e,dim)e/size(q,dim)+(1-e)*bsxfun(@eq,q,max(q,[],dim));

nblocs = length(stimulus.uid);

observer        = [];
observer.pposti = cell(1,nblocs);
observer.prespi = cell(1,nblocs);
observer.pcori  = cell(1,nblocs);
observer.ppostf = cell(1,nblocs);
observer.prespf = cell(1,nblocs);
observer.pcorf  = cell(1,nblocs);

for ibloc = 1:nblocs
    
    ntrials = length(stimulus.uid{ibloc});

    observer.pposti{ibloc} = zeros(3,ntrials);
    observer.prespi{ibloc} = zeros(3,ntrials);
    observer.pcori{ibloc}  = zeros(1,ntrials);
    observer.ppostf{ibloc} = zeros(3,ntrials);
    observer.prespf{ibloc} = zeros(3,ntrials);
    observer.pcorf{ibloc}  = zeros(1,ntrials);

    for itrial = 1:ntrials
        categ = stimulus.categ{ibloc}(itrial);
        psamp = cat(1, ...
            pdfvm_deg(stimulus.angle{ibloc}{itrial},stimulus.theta(1),stimulus.kappa(1)), ...
            pdfvm_deg(stimulus.angle{ibloc}{itrial},stimulus.theta(2),stimulus.kappa(2)), ...
            pdfvm_deg(stimulus.angle{ibloc}{itrial},stimulus.theta(3),stimulus.kappa(3)));
        ppost = ones(3,1);
        for iitem = 1:stimulus.nitems{ibloc}(itrial)
            ppost = ppost.*psamp(:,iitem);
            ppost = ppost/sum(ppost);
            if iitem == stimulus.nitemi{ibloc}(itrial)
                if isinf(bmax)
                    presp = hardmax(log(ppost),0,1);
                else
                    presp = softmax(log(ppost),bmax,0,1);
                end
                observer.pposti{ibloc}(:,itrial) = ppost;
                observer.prespi{ibloc}(:,itrial) = presp;
                observer.pcori{ibloc}(itrial) = presp(categ);
            end
        end
        if isinf(bmax)
            presp = hardmax(log(ppost),0,1);
        else
            presp = softmax(log(ppost),bmax,0,1);
        end
        observer.ppostf{ibloc}(:,itrial) = ppost;
        observer.prespf{ibloc}(:,itrial) = presp;
        observer.pcorf{ibloc}(itrial) = presp(categ);
    end
    
end

end