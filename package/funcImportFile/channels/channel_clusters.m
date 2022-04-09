function chanlocs = channel_clusters(chanlocs, DataType)

switch DataType
    case 'MFF'
        clusters = readtable('egi256_clusters.csv');
    otherwise
        return
end

for i = 1:length(chanlocs)
    idx = strcmpi(chanlocs(i).labels, clusters.chan);
    chanlocs(i).cluster = clusters.cluster(idx);
end
