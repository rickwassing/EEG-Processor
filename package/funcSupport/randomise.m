function [p, p_fwer] = randomise(Y, M, C, EE, ISE, J)

% By default, for now we'll define the multi-level block definitions 'B' as
% one variance group. When implementing multi-level models, we need to
% rethink this.
B = ones(size(M));

% For now, EE is true and ISE is false. I don't know for sure how to
% evaluate whether the models we use meet the assumptions
EE = true;
ISE = false;

for i = 1:size(C, 1) % For each contrast
    % Partition the model in variables of interest and nuisance variables
    [X,Z,eCm,eCx] = palm_partition(M, C(i, :)', 'Guttman');
    % Number of independent columns in the contrast
    s = rank(C(i, :));
    % Replace M for simplicity
    M = [X, Z];
    % Calculate the maximum permutations
    Ptree = palm_tree(B, M);
    Ptree
    if EE && ~ISE
        maxb = palm_maxshuf(Ptree, 'perms');
    elseif ~EE && ISE
        maxb = palm_maxshuf(Ptree, 'flips');
    elseif EE && ISE
        maxb = palm_maxshuf(Ptree, 'both');
    end
end

end