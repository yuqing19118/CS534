function [ F ] = InitializeSearchStructures( P )
% reformat structure for FLANN

% F is a cell which contains a cell for each level of P
F = cell(1, size(P,2));

% maybe revise this to not use a loop for speed
for level = 1:size(P,2)
    width = size(P{level},1);
    length = size(P{level},2);
    % get number of dimensions; either 9 or 25
    dims = size(P{level}{1, 1},2);
    formatted = zeros(dims,width * length);
    reshaped = reshape(P{level},1,[]);
    
    for col = 1:size(reshaped,2)
        formatted(:,col) = reshaped{col}';
    end
    F{level} = formatted;
end

