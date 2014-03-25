function [patch] = CreateGaussianAperture(diameter,envelopedev)

if nargin < 2
    error('Not enough input arguments.');
end

diameter = floor(diameter/2)*2;
[x,y] = meshgrid((1:diameter)-(diameter+1)/2);

patch = normalpdf(sqrt(x.^2+y.^2),0,envelopedev,false);

end