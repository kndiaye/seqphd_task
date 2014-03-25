function [patch] = CreatePlaceholder3(diameter,width,anglelist,kappalist,lumibg)

if nargin < 5
    error('missing input argument(s).');
end

if numel(anglelist) ~= 3 || numel(kappalist) ~= 3
    error('invalid input argument(s).');
end

smoothfun = @(x,dx)dx(1)+diff(dx)./(1+99.^(-x));
pdfvm_rad = @(x,t,k)exp(k*cos(2*(x-t)))./(pi*besseli(0,k));
pdfvm_deg = @(x,t,k)pdfvm_rad(x/180*pi,t/180*pi,k)/180*pi;

diameter = floor(diameter/2)*2;
width = floor(width);

[x,y] = meshgrid((1:diameter)-(diameter+1)/2);
theta = mod(-atan2(y,x)*180/pi,180);

patchbg = lumibg*ones([diameter,diameter,3]);

patchfg = zeros([diameter,diameter,3]);
for i = 1:3, patchfg(:,:,i) = pdfvm_deg(theta,anglelist(i),kappalist(i)); end
patchfg = bsxfun(@rdivide,patchfg,sum(patchfg,3));
patchfg = patchfg/max(patchfg(:));

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2+width,[0,1]));
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2,[1,0]));
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa+patchbg.*(1-patchaa);

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2+width,[0,1]));
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2+width-2,[1,0]));
patchaa = 1-patchaa;
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa;

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2+2,[0,1]));
patchaa = min(patchaa,smoothfun(sqrt(x.^2+y.^2)-diameter/2,[1,0]));
patchaa = 1-patchaa;
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa;

patch = patchfg;

end