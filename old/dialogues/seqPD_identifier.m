%boite de dialogue Participant.Identifier
prompt={'Identifiant'};
name='Participant';
numlines=1;
answer=inputdlg(prompt,name,numlines);
if isempty(answer)
    error('Experiment cancelled!');
end
participant.identifier = answer;
participant.date = datestr(now,'yyyymmdd-HHMM');