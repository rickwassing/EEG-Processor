cd /Volumes/research-data/PRJ-dasa
files = dir('sourcedata/wimr*/eeg/**/dasa*mwt*.mff');
hypnos = dir('sourcedata/wimr*/eeg/**/*mwt*nogram.txt');
events = dir('sourcedata/wimr*/eeg/**/*mwt*vents.txt');
geoscan = dir('sourcedata/wimr*/geoscan/dasa*.txt');
%%
clc
for i = 1:length(files)
    try
        % Key vals
        SubIdx = regexp(files(i).name, '[0-9]');
        Import.Subject = strrep(files(i).name(SubIdx:SubIdx+6), '-', '');
        Import.Session = 'baseline';
        Import.Task = 'mwt';
        RunIdx = regexp(files(i).name, 'ses');
        Import.Run = str2double(files(i).name(RunIdx+3));
        % Data
        Import.FileType = 'EEG';
        Import.DataFile.Type = 'MFF';
        Import.DataFile.Path = [files(i).folder, filesep, files(i).name];
        % Channels
        GeoIdx = find(regexpIdx({geoscan.name}, Import.Subject(1:3)), 1, 'last');
        if any(GeoIdx)
            Import.Channels.Type = 'Geoscan';
            Import.Channels.Path = [geoscan(GeoIdx).folder, filesep, geoscan(GeoIdx).name];
        else
            Import.Channels.Type = 'GSN-HydroCel-257.sfp';
            Import.Channels.Path = which('GSN-HydroCel-257.sfp');
        end
        Import.Events.Do = true;
        HypnoIdx = regexpIdx({hypnos.name}, [Import.Subject(1:3), '-']) & regexpIdx({hypnos.name}, ['ses', num2str(Import.Run)]);
        Import.Events.HypnoPath = [hypnos(HypnoIdx).folder, filesep, hypnos(HypnoIdx).name];
        EventIdx = regexpIdx({events.name}, [Import.Subject(1:3), '-']) & regexpIdx({events.name}, ['ses', num2str(Import.Run)]);
        if ~any(EventIdx)
            Import.Events.EventsPath = '';
        else
            Import.Events.EventsPath = [events(EventIdx).folder, filesep, events(EventIdx).name];
        end
        Import.Events.WonambiXMLPath = '';
        Import.Processing.DoResample = false;
        Import.Processing.DoFilter = true;
        Import.Processing.FilterSettings.Fs = 500;
        Import.Processing.FilterSettings.DoBandpass = true;
        Import.Processing.FilterSettings.DoNotch = true;
        Import.Processing.FilterSettings.Highpass = 0.1;
        Import.Processing.FilterSettings.Lowpass = 60;
        Import.Processing.FilterSettings.Notch = 50;
        Import.Processing.FilterSettings.WindowType = 'Hamming';
        Import.Processing.FilterSettings.TransitionBW = 0.2;
        Import.Processing.FilterSettings.FilterOrder = 8250;
        Import.Processing.DoSpectrogram = false;
        Import.Processing.DoICA = false;
        Import.SaveAs.Type = 256;
        Import.SaveAs.Path = ['./rawdata/sub-', Import.Subject,'/eeg/sub-', Import.Subject,'_ses-baseline_task-mwt_run-', num2str(Import.Run),'_eeg'];
        if exist([Import.SaveAs.Path, '.set'], 'file') ~= 0
            continue
        end
        fprintf('>> ==============================\n')
        fprintf('>> BIDS: IMPORTING MWT ''%s'' - file %i of %i\n', files(i).name, i, length(files))
        [~, ~, Warnings] = ImportFile(Import);
        disp(Warnings)
    catch ME
        printME(ME)
    end
end
%%
files = dir('sourcedata/wimr*/eeg/raw/mff/dasa*-drive*.mff');
for i = 53:length(files)
    try
        % Key vals
        SubIdx = regexp(files(i).name, '[0-9]');
        Import.Subject = strrep(files(i).name(SubIdx:SubIdx+6), '-', '');
        Import.Session = 'baseline';
        Import.Task = 'drive';
        RunIdx = regexp(files(i).name, 'drive');
        Import.Run = str2double(files(i).name(RunIdx+5));
        % Data
        Import.FileType = 'EEG';
        Import.DataFile.Type = 'MFF';
        Import.DataFile.Path = [files(i).folder, filesep, files(i).name];
        % Channels
        GeoIdx = find(regexpIdx({geoscan.name}, Import.Subject(1:3)), 1, 'last');
        if any(GeoIdx)
            Import.Channels.Type = 'Geoscan';
            Import.Channels.Path = [geoscan(GeoIdx).folder, filesep, geoscan(GeoIdx).name];
        else
            Import.Channels.Type = 'Template';
            Import.Channels.Path = which('GSN-HydroCel-257.sfp');
        end
        Import.Events.Do = false;
        Import.Events.HypnoPath = '';
        Import.Events.EventsPath = '';
        Import.Events.WonambiXMLPath = '';
        Import.Processing.DoResample = false;
        Import.Processing.DoFilter = true;
        Import.Processing.FilterSettings.Fs = 500;
        Import.Processing.FilterSettings.DoBandpass = true;
        Import.Processing.FilterSettings.DoNotch = true;
        Import.Processing.FilterSettings.Highpass = 0.1;
        Import.Processing.FilterSettings.Lowpass = 60;
        Import.Processing.FilterSettings.Notch = 50;
        Import.Processing.FilterSettings.WindowType = 'Hamming';
        Import.Processing.FilterSettings.TransitionBW = 0.2;
        Import.Processing.FilterSettings.FilterOrder = 8250;
        Import.Processing.DoSpectrogram = false;
        Import.Processing.DoICA = false;
        Import.SaveAs.Type = 256;
        Import.SaveAs.Path = ['./rawdata/sub-', Import.Subject,'/eeg/sub-', Import.Subject,'_ses-baseline_task-drive_run-', num2str(Import.Run),'_eeg'];
        fprintf('>> ==============================\n')
        fprintf('>> BIDS: IMPORTING AUSED DRIVE ''%s'' - file %i of %i\n', files(i).name, i, length(files))
        [~, ~, Warnings] = ImportFile(Import);
        disp(Warnings)
    catch ME
        printME(ME)
    end
end


