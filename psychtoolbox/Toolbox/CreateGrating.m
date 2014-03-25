function [patch] = CreateGrating(diameter,frequency,angle,phase,contrast)

if nargin < 5
    contrast = 1;
end
if nargin < 4
    error('Not enough input arguments.');
end

diameter = floor(diameter/2)*2;
[x,y] = meshgrid((1:diameter)-(diameter+1)/2);

patch = 0.5*contrast*cos(2*pi*(frequency*(sin(pi/180*angle)*x+cos(pi/180*angle)*y)+phase));

end