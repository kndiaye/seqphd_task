run('seqPD_TaskParameters.m')
resp = 0;
trigger=@(x)(x)
stim=1;
side=1;
itrial=1;ibloc=1;   
target=1;
stopped=false;
tonset=GetSecs;
fprintf('\n');
t = NaN;
while ~resp && ~stopped
    % Stop by experimenter ?
    if CheckKeyPress(keystop)
        fprintf('... stopped!');
        stopped = true;
        %Screen('Flip',video.h);
        break;
    end
    % Now, if not, look at each response mode:
    if participant.with_response_lumina
        dat = IOPort('Read',hport);
        t = GetSecs;
        if any(ismember(dat,datresp))
            resp = find(datresp == dat(1));
        end
    end
    
    if resp > 0
        % Send "RESPONSE" trigger
        trigger(trig.resp.onset+trig.resp.button(resp));
        toffset = GetSecs;% Screen('Flip',video.h);
        rt = t-tonset;
        accu = ((stim==target)&&(resp==side)) ||...
            (   (stim~=target)&&(resp~=side));
        
        % Log data
        response.resp{ibloc}(itrial) = resp;
        response.rt{ibloc}(itrial) = rt;
        response.time{ibloc}(itrial) = t;
        response.accu{ibloc}(itrial) = accu;
        timecode.stim_offset{ibloc}(itrial) = toffset;
        timecode.resp_press{ibloc}(itrial) = t-tinit;
        
        % Display
        resptype    = 'N/A   ';
        if accu && stim==target
            resptype=('hit       ');
        elseif accu && stim~=target
            resptype=('c.rej.    ');
        elseif ~accu && stim==target
            resptype=('      miss');
        elseif ~accu && stim~=target
            resptype=('    f.pos.');
        end
        if DEBUG
            fprintf('\b\b\b\b\b\b');
        end
        fprintf('|RT:% 6dms',round(rt*1000));
        fprintf(' resp:[%d] = %s', resp, resptype);
        
        % Wait patient to release the buttons
        lastkeypress=t;
        k=0;
        fprintf(' [WAITING RELEASE] ');
        while k>0 || (t-lastkeypress) < timing.response_release
            if participant.with_response_keyboard
                [k,t]=CheckKeyPress(keyresp);
            end
            if participant.with_response_lumina
                dat = IOPort('Read',hport);
                t = GetSecs;
                k = ~isempty(dat);
            end
            if participant.with_response_mouse
                % TO DO
            end
            if k
                lastkeypress=t;
            end
        end
        fprintf('... ok!');
        timecode.resp_release{ibloc}(itrial) = t;
    elseif DEBUG
        fprintf('\b\b\b\b\b\b% 6d',round(1000*(GetSecs-tonset)));
    end
end

