function CreateNewDirectory(Path)

% Replace forward slashes with the OS default
Path = strrep(Path, '/', filesep);
% Run command
if ispc
    [status, cmdout] = system(['mkdir ', Path]);
else
    [status, cmdout] = system(['mkdir -p ', Path]);
end
% Check output of the command
if status ~= 0 && ~regexpIdx(cmdout, 'already exists')
    error('An unexpected error occurred when creating a new directory:\n%s.', cmdout)
elseif regexpIdx(cmdout, 'already exists')
    warning('No need for creating a new directory, it already exists:\n%s.', cmdout)
end

end
