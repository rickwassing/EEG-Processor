function [EEG, urpibchanlocs, urpibdata] = Import_ChannelLocations(EEG, FileType, FullFilePath, DataType)

if ~isempty(EEG.chanlocs)
    % Remove EEG chanlocs
    idx = strcmpi({EEG.chanlocs.type}, 'EEG');
    urpibchanlocs = EEG.chanlocs(~idx);
    if ndims(EEG.data) == 3
        urpibdata = EEG.data(~idx, :, :);
    else
        urpibdata = EEG.data(~idx, :);
    end
    EEG.chanlocs(:) = [];
else
    urpibchanlocs = struct();
    urpibdata = [];
end
switch FileType
    case 'Geoscan'
        disp('>> BIDS: Importing channel locations from geoscan file')
        T = now;
        [chanlocs, EEG.chaninfo.ndchanlocs] = geoscan_to_chanlocs(FullFilePath);
        if (strcmpi(DataType, 'COMPU257'))
            N = 257;
            for i = 1:length(chanlocs)
                chanlocs(i).labels = EEG.urchanlocs(i).labels;
            end
        else
            N = length(chanlocs);
        end
        fnames = fieldnames(chanlocs);
        for i = 1:N
            k = length(EEG.chanlocs)+1;
            for j = 1:length(fnames)
                EEG.chanlocs(k).(fnames{j}) = chanlocs(i).(fnames{j});
            end
        end
        EEG.chaninfo.filename = FullFilePath;
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
    otherwise
        disp('>> BIDS: Importing channel locations from template file')
        T = now;
        [chanlocs, EEG.chaninfo.ndchanlocs] = template_to_chanlocs(which(FileType));
        % Copy over the fields to the EEG struct
        fnames = fieldnames(chanlocs);
        for i = 1:length(chanlocs)
            k = length(EEG.chanlocs)+1;
            for j = 1:length(fnames)
                EEG.chanlocs(k).(fnames{j}) = chanlocs(i).(fnames{j});
            end
        end
        EEG.chaninfo.filename = which(FileType);
        fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))
end
if isempty(EEG.chanlocs)
    error('%s: Unexpected error with importing channel locations from %s.', EEG.filename, EEG.chaninfo.filename)
end
% Add the channel clusters
EEG.chanlocs = channel_clusters(EEG.chanlocs, DataType);
% Finally, add the unit to the chanlocs
for i = 1:length(EEG.chanlocs)
    EEG.chanlocs(i).unit = 'uV';
end

end
