function [patch] = CreatePlaceholder1(diameter,width,anglelist,kappalist,i,lumibg)

if nargin < 6
    error('missing input argument(s).');
end

if numel(anglelist) ~= 3 || numel(kappalist) ~= 3 || ~ismember(i,1:3)
    error('invalid input argument(s).');
end

showdir = false; % show direction?
showvar = false; % show circular variance?

smoothpix = @(x,dx)dx(1)+diff(dx)./(1+99.^(-x));
smoothdeg = @(x,dx)smoothpix(x/360*pi*diameter,dx);

circdist = @(x1,x2)mod(x2-x1+90,180)-90;

pdfvm_rad = @(x,t,k)exp(k*cos(2*(x-t)))./(pi*besseli(0,k));
pdfvm_deg = @(x,t,k)pdfvm_rad(x/180*pi,t/180*pi,k)/180*pi;

varvm = 1-besseli(1,kappalist(i))/besseli(0,kappalist(i));
maxvm = pdfvm_deg(0,0,kappalist(i))/pdfvm_deg(0,0,max(kappalist));

diameter = floor(diameter/2)*2;
width = floor(width);

[x,y] = meshgrid((1:diameter)-(diameter+1)/2);
theta = mod(-atan2(y,x)*180/pi,180);

patchbg = lumibg*ones([diameter,diameter,3]);

patchcg = zeros([diameter,diameter,3]);
patchcg(:,:,i) = 1;

patchfg = patchcg;

patchaa = pdfvm_deg(theta,anglelist(i),kappalist(i));
patchaa = patchaa/pdfvm_deg(0,0,max(kappalist));
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa+patchbg.*(1-patchaa);

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+width,[0,1]));
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2,[1,0]));
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa+patchbg.*(1-patchaa);

if showdir
    patchaa = ones(diameter,diameter);
    patchaa = min(patchaa,smoothpix(abs(sin(pi/180*anglelist(i))*x+cos(pi/180*anglelist(i))*y)-0.5*width/2,[1,0]));
    patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+width,[1,0]));
    patchaa = patchaa*maxvm;
    patchaa = repmat(patchaa,[1,1,3]);
    patchfg = patchcg.*patchaa+patchfg.*(1-patchaa);
end

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+width,[0,1]));
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+width-2,[1,0]));
patchaa = 1-patchaa;
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa;

patchaa = ones(diameter,diameter);
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+2,[0,1]));
patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2,[1,0]));
patchaa = 1-patchaa;
patchaa = repmat(patchaa,[1,1,3]);
patchfg = patchfg.*patchaa;

if showvar
    patchaa = ones(diameter,diameter);
    patchaa = min(patchaa,smoothdeg(abs(circdist(theta,anglelist(i)))-varvm*90,[1,0]));
    patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+2.0*width,[0,1]));
    patchaa = min(patchaa,smoothpix(sqrt(x.^2+y.^2)-diameter/2+1.5*width,[1,0]));
    patchaa = patchaa*maxvm;
    patchaa = repmat(patchaa,[1,1,3]);
    patchfg = patchcg.*patchaa+patchfg.*(1-patchaa);
end

patch = patchfg;

end