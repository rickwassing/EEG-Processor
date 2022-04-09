function EEG = mff_newset(mffData)

EEG = eeg_emptyset;

[fpath, fname] = fileparts(mffData.meta_file);

% get meta info
EEG.comments = ['Original file: ' mffData.meta_file];
EEG.setname  = fname;
EEG.filename = fname;
EEG.filepath = fpath;

EEG.nbchan   = mffData.signal_binaries(1).num_channels;
EEG.srate    = mffData.signal_binaries(1).channels.sampling_rate(1);
EEG.trials   = length(mffData.epochs);
EEG.pnts     = mffData.signal_binaries(1).channels.num_samples(1);
EEG.xmin     = 0;
 
EEG.times    = 0:1/EEG.srate:(EEG.pnts-1)/EEG.srate;
EEG.xmax     = EEG.times(end);