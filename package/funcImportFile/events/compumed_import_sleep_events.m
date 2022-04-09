function [EEG, warnmsg] = compumed_import_sleep_events(EEG, eventFile, mffName)

disp('>> BIDS: Importing events from Scored Events file')
warnmsg = [];

if nargin < 3
    if ~isfield(EEG, 'etc')
        error('Dataset does not contain recording start date and time');
    elseif ~isfield(EEG.etc, 'rec_startdate')
        error('Dataset does not contain recording start date and time');
    end
else
    idxDate = regexp(mffName, '[0-9]{8}_[0-9]{6}');
    EEG.etc.rec_startdate = datenum(mffName(idxDate:idxDate+14), 'yyyymmdd_HHMMSS');
end

% Remove any sleep events that are currently in the events
if isstruct(EEG.event)
    if isfield(EEG.event, 'type')
        idx = regexpIdx({EEG.event.type}, 'Arousal|Apnea|Hypopnea|Limb|Snore|SpO2|RERA');
        if any(idx)
            warnmsg = 'Scored Events have been overwritten';
            EEG.event(idx) = [];
        end
    end
end

% get sleep events
opts   = detectImportOptions(eventFile);
opts   = setvartype(opts, {'char', 'double', 'char', 'char', 'char', 'char', 'char', 'char'});
events = readtable(eventFile, opts, 'ReadVariableNames', false);
events.Properties.VariableNames = [{'Onset'},{'Epoch'},{'Stage'},{'Type'},{'Duration'},{'Meta1'},{'Meta2'},{'x'}];

% calculate the relative time since beginning of the recording
add = 0;
for e = 1:size(events, 1)
    dstr = [datestr(EEG.etc.rec_startdate+add, 'yyyy-mm-dd') 'T' events.Onset{e}];
    while datenum(dstr, 'yyyy-mm-ddTHH:MM:SS') - EEG.etc.rec_startdate < 0
        add = add+1;
        dstr = [datestr(EEG.etc.rec_startdate+add, 'yyyy-mm-dd') 'T' events.Onset{e}];
    end
    EEG.event(end+1).latency = (datenum(dstr, 'yyyy-mm-ddTHH:MM:SS') - EEG.etc.rec_startdate) * 24*60*60*EEG.srate + 1;
    if isempty(regexp(events.Duration{e}, '\.', 'once'))
        EEG.event(end).duration = datenum(['0000-01-00T00:' events.Duration{e}], 'yyyy-mm-ddTHH:MM:SS') * 24*60*60*EEG.srate;
    else
        EEG.event(end).duration = datenum(['0000-01-00T00:' events.Duration{e}], 'yyyy-mm-ddTHH:MM:SS.FFF') * 24*60*60*EEG.srate;
    end
    type = events.Type{e};
    type(~isstrprop(type, 'alphanum')) = '';
    type = lower(matlab.lang.makeValidName(type));
    EEG.event(end).type = type;
end
EEG.etc.rec_startdate = datestr(EEG.etc.rec_startdate, 'yyyy-mm-ddTHH:MM:SS');