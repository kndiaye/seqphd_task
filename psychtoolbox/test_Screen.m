if isempty(Screen('Windows'))
Screen('Preference', 'SkipSyncTests', 0);

video.h=Screen('OpenWindow', 0);
end
d=[];  
roundfp = @(dt,ifi)(round(dt/ifi)-0.5)*ifi
%dt=.1+rand/20
dt=.05
WaitSecs(.1);

while ~CheckKeyPress 
    
    Screen('FillRect',video.h,0);
    WriteParPort(1);
    WaitSecs(.01);
    WriteParPort(0);
    t1=Screen('Flip', video.h); 
    WriteParPort(1);
    ttl(1)=WaitSecs(.01);
    WriteParPort(0);
    %fprintf('%f: noir\n',GetSecs);
    
    Screen('FillRect',video.h,255);    
    Screen('DrawingFinished',video.h);
    [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip',video.h,t1+ifi*2.5);%+roundfp(dt,video.ifi));
    %fprintf('%f: blanc\n',GetSecs);
    WriteParPort(2);
     ttl(2)=WaitSecs(.01);
    WriteParPort(0);
    disp([diff(ttl) roundfp(dt,video.ifi) [VBLTimestamp StimulusOnsetTime FlipTimestamp]-t1   Missed Beampos])
   
    
    Screen('FillRect',video.h,0);
    Screen('Flip', video.h); 
    WaitSecs(.2);
        
    
end