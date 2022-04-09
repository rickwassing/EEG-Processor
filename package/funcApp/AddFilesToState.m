function [Files, ids] = AddFilesToState(Files, SubId, newFiles, type, ids)
% ---------------------------------------------------------
% For each file, add it to the structure
randomSeeds = randperm(length(newFiles), length(newFiles));
for k = 1:length(newFiles)
    try
        % ---------------------------------------------------------
        % Find the associated JSON file
        [~, rootName] = fileparts(newFiles(k).name);
        jsonFile = dir([newFiles(k).folder, '/', rootName, '.json']);
        % ---------------------------------------------------------
        % Add it to the structure
        id = ['X', datestr(now, 'yyyymmddHHMMSSFFF'), num2str(randomSeeds(k))];
        ids = [ids; {id}]; %#ok<AGROW>
        Files.ids = [Files.ids; {id}];
        Files.Entities.(id).Path = strrep([newFiles(k).folder, '/', newFiles(k).name], '\', '/');
        Files.Entities.(id).SubId = SubId;
        Files.Entities.(id).Type = type;
        Files.Entities.(id).KeyVals = filename2struct(rootName);
        if isempty(jsonFile)
            Files.Entities.(id).JSON = struct();
        else
            Files.Entities.(id).JSON = json2struct([jsonFile(1).folder, '/', jsonFile(1).name]);
        end
        Files.Entities.(id).Status = 'idle';
    catch ME
        Files.Entities.(id).Status = 'error';
        Files.Entities.(id).ErrorMessage = ME;
    end
end
end
