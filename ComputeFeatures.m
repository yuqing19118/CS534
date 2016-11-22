function [ F ] = ComputeFeatures( P )
% Computes features for input Gaussian Pyramid P

% F is a cell which contains a cell for each level of P
F = cell(1, size(P,2));

% maybe revise this to not use a loop for speed
for level = 1:size(P,2)
    width = size(P{level},1);
    length = size(P{level},2);
    dim = min(width, length);

    % think about how to define "fine" or "coarse" levels of pyramid?
    % change 30?
    % use 5x5 neighborhood
    if size(dim) >= 30
        % padding to add zeros around for border
        padded = zeros([width,length]+4);
        padded(3:end-2,3:end-2) = P{level};
        features = cell(width, length);
        for row = 3:size(padded,1)-2
            for col = 3:size(padded,2)-2
                neighborhood = padded(row-2:row+2,col-2:col+2);
                featureVector = neighborhood(:)';
                features{row-2,col-2} = featureVector;
            end
        end
        F{levels} = features;
    % use 3x3 neighborhood
    else
        % padding to add zeros around for border
        padded = zeros([width,length]+2);
        padded(2:end-1,2:end-1) = P{level};
        features = cell(width, length);
        for row = 2:size(padded,1)-1
            for col = 2:size(padded,2)-1
                neighborhood = padded(row-1:row+1,col-1:col+1);
                featureVector = reshape(neighborhood.',1,[]);
                features{row-1,col-1} = featureVector;
            end
        end
        F{level} = features;
    end
end

end
