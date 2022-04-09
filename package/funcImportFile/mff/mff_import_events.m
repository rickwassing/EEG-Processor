function EEG = mff_import_events(EEG, mffName)

% Check if files exists
if exist(fullfile(mffName, 'info.xml'), 'file') == 0
    error('Could not find ''info.xml'' in the MFF package')
end
if exist(fullfile(mffName, 'Events_User Markup.xml'), 'file') == 0
    error('Could not find ''Events_User Markup.xml'' in the MFF package')
end

infoxml = parseXML(fullfile(mffName, 'info.xml'));

for f = 1:size(infoxml.Children,2)
    switch infoxml.Children(f).Name
        case 'recordTime'
            EEG.etc.amp_startdate = infoxml.Children(f).Children.Data;
    end
end

eventsxml = parseXML(fullfile(mffName, 'Events_User Markup.xml'));

EEG.event = struct;
evIdx     = 0;
for f = 1:size(eventsxml.Children, 2)
    switch eventsxml.Children(f).Name
        case 'event'
            evIdx = evIdx+1;
            thisEvent = eventsxml.Children(f).Children;
            for g = 1:size(thisEvent, 2)
                switch thisEvent(g).Name
                    case 'beginTime'
                        % Calculate the onset of the event in samples, i.e.
                        % (eventTime - startTime) * sampling rate + 1;
                        msdiff = mff_date_to_ms(thisEvent(g).Children.Data) - mff_date_to_ms(EEG.etc.amp_startdate);
                        EEG.event(evIdx).latency = (msdiff/1000) * EEG.srate + 1;
                    case 'duration'
                        EEG.event(evIdx).duration = (str2double(thisEvent(g).Children.Data) / 1000) * EEG.srate;
                    case 'code'
                        type = thisEvent(g).Children.Data;
                        type(~isstrprop(type, 'alphanum')) = '';
                        type = lower(matlab.lang.makeValidName(type));
                        EEG.event(evIdx).type = type;
                end
            end
    end
end