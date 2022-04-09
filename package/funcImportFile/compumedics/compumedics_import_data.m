function EEG = compumedics_import_data(FullFilePath)

EEG = pop_biosig(FullFilePath);
% insert start date
EEG.etc.rec_startdate = datenum(EEG.etc.T0);
% Insert reference channel
EEG.chanlocs(end+1).labels = 'REF';
if ndims(EEG.data) == 3
    EEG.data(end+1, :, :) = zeros(1, EEG.pnts, EEG.trials, 'single');
else
    EEG.data(end+1, :) = zeros(1, EEG.pnts, 'single');
end
EEG.nbchan = size(EEG.data, 1);
% The PIB channels are intermixed with the EEG channels, so we need
% to extract them and place them at the end of the rows
pibchans = ...
    regexpIdx({EEG.chanlocs.labels}, 'BP [0-9]*') | ...
    strcmpi({EEG.chanlocs.labels}, 'SpO2') | ...
    strcmpi({EEG.chanlocs.labels}, 'VEOU') | ...
    strcmpi({EEG.chanlocs.labels}, 'HEOR');
EEG.chanlocs = [EEG.chanlocs(~pibchans); EEG.chanlocs(pibchans)];
if ndims(EEG.data) == 3
    EEG.data = [EEG.data(~pibchans, :, :); EEG.data(pibchans, :, :)];
else
    EEG.data = [EEG.data(~pibchans, :); EEG.data(pibchans, :)];
end
pibchans = sort(pibchans);
for i = 1:EEG.nbchan
    if pibchans(i)
        EEG.chanlocs(i).type = 'PNS';
    else
        EEG.chanlocs(i).type = 'EEG';
        EEG.chanlocs(i).ref = 'REF';
    end
end
EEG.urchanlocs = EEG.chanlocs;

% Rename the physiology channels
pnsSets = pns_workspaces();
for i = 1:length(EEG.chanlocs)
    if strcmpi(EEG.chanlocs(i).type, 'EEG')
        continue
    end
    idxLabel = strcmpi({pnsSets.labels}, EEG.chanlocs(i).labels);
    if ~any(idxLabel)
        continue
    else
        EEG.chanlocs(i).labels = pnsSets(idxLabel).relabel;
        EEG.chanlocs(i).type = pnsSets(idxLabel).type;
    end
end


end