function [patch] = CreateGabor(diameter,envelopedev,frequency,angle,phase,contrast)

if nargin < 6
    contrast = 1;
end
if nargin < 5
    error('Not enough input arguments.');
end

patch = CreateGrating(diameter,frequency,angle,phase,contrast);
patch = patch.*CreateGaussianAperture(diameter,envelopedev);
patch = patch.*CreateCircularAperture(diameter);

end