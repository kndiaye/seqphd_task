function [patch] = CreateCircularAperture(diameter)

if nargin < 1
    error('Not enough input arguments.');
end

sigmoid = @(x,beta,lims)lims(1)+diff(lims)./(1+exp(-beta*x));

diameter = floor(diameter/2)*2;
[x,y] = meshgrid((1:diameter)-(diameter+1)/2);

patch = sigmoid(sqrt(x.^2+y.^2)-diameter/2,log(99),[1,0]);

end