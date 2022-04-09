function [ArgOut, Next, Warnings] = Analysis_PowerSpectralAnalysis(app, File, Settings)
% ---------------------------------------------------------
% Initialize
ArgOut = [];
Next = 'none';
Warnings = [];
% ---------------------------------------------------------
% Get data path
[filepath, filename, extension] = fileparts(File.Path);
% ---------------------------------------------------------
% Check if dataset exists
if exist(File.Path) == 0 %#ok<EXIST> 
    Warnings = [Warnings; {sprintf('Could not load dataset ''%s'', file not found.', filename)}];
    Warnings = [Warnings; {'-----'}];
    return
end
% ---------------------------------------------------------
% Load data
disp('>> BIDS: Loading dataset')
EEG = pop_loadset('filepath', filepath, 'filename', [filename, extension]);
% Initialize the output 
KeyVals = filename2struct(filename);
PSD = struct();
PSD.filename = [Settings.Filename, '.mat'];
PSD.filepath = ['./derivatives/EEG-output-fstlvl/sub-', KeyVals.sub, '/ses-', KeyVals.ses];
PSD.subject = KeyVals.sub;
PSD.session = KeyVals.ses;
PSD.task = KeyVals.task;
PSD.run = KeyVals.run;
PSD.group = '';
PSD.condition = '';
PSD.ref = EEG.ref;
% ---------------------------------------------------------
% Define parameters for the analysis
% Channel selection
ChanSel = strcmpi({EEG.chanlocs.type}, 'EEG');
% Window length in samples
WinLength = Settings.Window.Length * EEG.srate;
% Check if the window length is smaller than the epoch length
if WinLength > EEG.pnts
    fprintf('>> BIDS: Warning. The window length was longer than the number of datapoints. Window length was adjusted to %.3f seconds.\n', EEG.pnts/EEG.srate)
    Warnings = [Warnings; {sprintf('Window length was longer than the number of datapoints. Window length was adjusted to %.3f seconds.\n', EEG.pnts/EEG.srate)}];
    Warnings = [Warnings; {'-----'}];
    WinLength = EEG.pnts;
end
% Define window step
WinStep = floor(WinLength * (Settings.Window.Overlap/100));
% ---------------------------------------------------------
fprintf('>> BIDS: Running power-spectral analysis using Welch''s method on %i trials with windows of %.3f sec and %.1f%% overlap.\n', EEG.trials, WinLength/EEG.srate, 100*WinStep/WinLength)
% ---------------------------------------------------------
% Run
for i = 1:EEG.trials
    Data = squeeze(EEG.data(ChanSel, :, i));
    [Pow, Freq] = pwelch(Data', WinLength, WinStep, max([256, 2^nextpow2(WinLength)]), EEG.srate);
    if i == 1
        % Initialize the output matrix
        PSD.data = nan(sum(ChanSel), length(Freq), EEG.trials);
    end
    PSD.data(:, :, i) = Pow';
    PSD.freqs = Freq;
end
% ---------------------------------------------------------
% Calculate the average across trials or squeeze the dataset
if strcmpi(Settings.Output, 'average')
    % Average across trials, if the user requested to do this
    fprintf('>> BIDS: averaging power spectral density estimates across trials.\n')
    PSD.data = squeeze(mean(PSD.data, 3));
else
    % Try to squeeze the data, i.e. when there was only one trial
    PSD.data = squeeze(PSD.data);
end
% ---------------------------------------------------------
% Calculate the user-specified frequency bands
cnt = 0;
for i = 1:length(Settings.FreqDef)
    idx = PSD.freqs >= Settings.FreqDef(i).band(1) & PSD.freqs < Settings.FreqDef(i).band(2);
    if ~any(idx)
        continue
    end
    cnt = cnt+1;
    fprintf('>> BIDS: Integrating power spectral density for frequency band ''%s'' between %.1f - %.1f Hz.\n', Settings.FreqDef(i).label, Settings.FreqDef(i).band(1), Settings.FreqDef(i).band(2))
    PSD.bands(cnt).label = Settings.FreqDef(i).label;
    PSD.bands(cnt).freqrange = Settings.FreqDef(i).band;
    PSD.bands(cnt).data = squeeze(mean(PSD.data(:, idx, :), 2));
end
% ---------------------------------------------------------
% Save some more info
PSD.nbchan = sum(ChanSel);
PSD.trials = size(PSD.data, 3);
PSD.chanlocs = EEG.chanlocs(ChanSel);
PSD.chaninfo = EEG.chaninfo;
% ---------------------------------------------------------
% Get outlier channels
AvBands = cellfun(@(d) squeeze(mean(d, 2)), {PSD.bands.data}, 'UniformOutput', false);
Outliers = cellfun(@(d) asrow(find(bsxfun(@gt, abs(bsxfun(@minus, d, mean(d))), 3*std(d)))), AvBands, 'UniformOutput', false);
PSD.etc.rej_channels = {PSD.chanlocs(unique([Outliers{:}])).labels};
% ---------------------------------------------------------
% JSON
PSD.etc.JSON = struct();
PSD.etc.JSON.Desription = 'Power spectral density estimate of the EEG signal, found using Welch''s overlapped segment averaging estimator.';
PSD.etc.JSON.Sources = [EEG.filepath, '/', EEG.filename];
PSD.etc.JSON.TaskName = EEG.etc.JSON.TaskName;
PSD.etc.JSON.EEGReference = EEG.etc.JSON.EEGReference;
PSD.etc.JSON.EEGChannelCount = PSD.nbchan;
PSD.etc.JSON.ECGChannelCount = 0;
PSD.etc.JSON.EMGChannelCount = 0;
PSD.etc.JSON.EOGChannelCount = 0;
PSD.etc.JSON.MiscChannelCount = 0;
PSD.etc.JSON.TrialCount = PSD.trials;
PSD.etc.JSON.SpectralAnalysis = struct();
PSD.etc.JSON.SpectralAnalysis.ChannelSelection = {PSD.chanlocs.labels};
PSD.etc.JSON.SpectralAnalysis.SpectrogramType = 'pwelch';
PSD.etc.JSON.SpectralAnalysis.FrequencyStep = mean(abs(diff(PSD.freqs)));
PSD.etc.JSON.SpectralAnalysis.MaximumFrequency = PSD.freqs(end);
PSD.etc.JSON.SpectralAnalysis.WindowLength = Settings.Window.Length;
PSD.etc.JSON.SpectralAnalysis.WindowOverlap = Settings.Window.Overlap;
% ---------------------------------------------------------
% Save file to disk
PSD = SaveDataset(PSD, 'matrix');
% ---------------------------------------------------------
% Set output
ArgOut = PSD;
% What step to do next?
Next = 'AddFile';

end