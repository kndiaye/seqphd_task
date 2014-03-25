function [doubletone] = CreateDoubleTone(tonefrequencies,tonedurations,voidduration,samplingrate,attenuation,noise)

if nargin < 6 || isempty(noise)
    noise = [];
end
if nargin < 5 || isempty(attenuation)
    attenuation = [];
end
if nargin < 4
    error('Not enough input arguments.');
end

tone1 = CreateSingleTone(tonefrequencies(1),tonedurations(1),samplingrate,attenuation,noise);
tone2 = CreateSingleTone(tonefrequencies(2),tonedurations(2),samplingrate,attenuation,noise);

void = [];
if voidduration > 0
    void = zeros(2,ceil(voidduration*samplingrate));
end

doubletone = [tone1,void,tone2];

end