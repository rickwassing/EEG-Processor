function EEG = SaveDataset(EEG, Part)

if nargin < 2
    Part = 'all';
end

T = now;

% ---------------------------------------------------------
% Create Directory if it does not exist yet
if exist(EEG.filepath, 'dir') == 0
    CreateNewDirectory(EEG.filepath)
end
% ---------------------------------------------------------
% Save dataset
if strcmpi(Part, 'all')
    fprintf('>> BIDS: Saving dataset to ''%s''\n', EEG.setname)
    EEG = pop_saveset(EEG, [EEG.filepath, '/', EEG.filename]);
    EEG.filepath = strrep(EEG.filepath, filesep, '/');
end
% ---------------------------------------------------------
% Save Header 
if strcmpi(Part, 'header')
    fprintf('>> BIDS: Saving header info to ''%s''\n', EEG.setname)
    save([EEG.filepath, '/', EEG.filename], '-v7.3', '-mat', 'EEG');
end
% ---------------------------------------------------------
% Save structure with generic matrix as data 
if strcmpi(Part, 'matrix')
    fprintf('>> BIDS: Saving matrix dataset to ''%s''\n', EEG.filename)
    save([EEG.filepath, '/', EEG.filename], '-v7.3', '-mat', 'EEG');
end
% ---------------------------------------------------------
% Save Sidecar files
fprintf('>> BIDS: Saving sidecar files\n')
% -----
% Get keys and values
[~, Filename] = fileparts(EEG.filename);
KeysValues = filename2struct(Filename);
Keys = fieldnames(KeysValues); Keys(end) = [];
Values = struct2cell(KeysValues); Values(end) = [];
% -----
% Generate filenames for all the sidecar files
BaseFilename = cellfun(@(k, v) [k, '-', v, '_'], Keys, Values, 'UniformOutput', false);
JSONFilename = [EEG.filepath, '/', Filename, '.json'];
ChannelFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'channels.tsv'}], '')];
ElectrodesFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'electrodes.tsv'}], '')];
CoordFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'coordsystem.json'}], '')];
EventsFilename = [EEG.filepath, '/', strjoin([BaseFilename; {'events.tsv'}], '')];
% -----
% Save Sidecar Files
if isfield(EEG.etc, 'JSON')
    struct2json(EEG.etc.JSON, JSONFilename);
end
if isfield(EEG, 'chanlocs')
    writeChannelsTSV(EEG, ChannelFilename);
    writeElectrodesTSV(EEG, ElectrodesFilename);
end
if isfield(EEG, 'chaninfo')
    writeCoordinateSystemJSON(EEG, CoordFilename);
end
if isfield(EEG, 'event')
    writeEventsTSV(EEG, EventsFilename);
end
% ---------------------------------------------------------
% Print how long it took
fprintf(' - Finished in %s\n', datestr(now-T, 'HH:MM:SS'))

end
