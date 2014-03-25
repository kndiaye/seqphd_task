function [patch] = CreateCircle(diameter,width)

if nargin < 2
    error('Not enough input arguments.');
end

sigmoid = @(x,beta,lims)lims(1)+diff(lims)./(1+exp(-beta*x));

diameter = floor(diameter/2)*2;
[x,y] = meshgrid((1:diameter)-(diameter+1)/2);

patch = ones(diameter,diameter);
patch = min(patch,sigmoid(sqrt(x.^2+y.^2)-diameter/2,log(99),[1,0]));
patch = min(patch,sigmoid(sqrt(x.^2+y.^2)-diameter/2+width,log(99),[0,1]));

end