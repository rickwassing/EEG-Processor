function PHEN = readPhenotype(Input)

PHEN = table();
PHEN.participant_id = cellfun(@(i) i.KeyVals.sub, Input, 'UniformOutput', false);
PHEN = readAndAppend(PHEN, 'participants.tsv');
% Load any other phenotype data
files = dir('phenotype/*');
for i = 1:length(files)
    PHEN = readAndAppend(PHEN, fullfile(files(i).folder, files(i).name));
end

    function acro = extractAcronym(fname)
        [~, fname] = fileparts(fname);
        acro = strsplit(strrep(fname, '-', '_'), '_');
        if length(acro) > 1
            acro = cellfun(@(s) s(1), acro);
        elseif length(acro) == 1 && length(acro{1}) > 3
            acro = acro{1:3};
        else
            acro = acro{:};
        end
        acro = [upper(acro), '_'];
    end
    function p = readAndAppend(p, filepath)
        % Load file if it exists
        if exist(filepath, 'file') ~= 2
            return
        end
        % Detect import options and set the default for date, time etc to
        % character cell arrays
        opts = detectImportOptions(filepath, ...
            'FileType', 'text', ...
            'TextType', 'char', ...
            'DatetimeType', 'text', ...
            'DurationType', 'text', ...
            'HexType', 'text', ...
            'BinaryType', 'int64');
        % Continue only if 'participant_id' is in the list of variable names
        if ~ismember('participant_id', opts.VariableNames)
            return
        end
        % Set the variable type for participant_id to char
        opts = setvartype(opts, {'participant_id'}, 'char');
        % Read the data
        tmp = readtable(filepath, opts);
        % Check that the variable names do not already exist
        VarNames = tmp.Properties.VariableNames;
        VarNames(strcmpi(VarNames, 'participant_id')) = [];
        % If any variable name already exist, prepend with the acronym for
        % this phenotype
        if any(ismember(VarNames, p.Properties.VariableNames))
            acro = extractAcronym(filepath);
            for v = 1:length(tmp.Properties.VariableNames)
                if strcmpi(tmp.Properties.VariableNames{v}, 'participant_id')
                    continue
                end
                tmp.Properties.VariableNames{v} = [acro, tmp.Properties.VariableNames{v}];
            end
        end
        % Join the tables
        p = outerjoin(p, tmp, ...
            'Type', 'left', ...
            'Keys', 'participant_id', ...
            'MergeKeys', true);
    end
end