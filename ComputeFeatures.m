function [ F ] = ComputeFeatures( P , dim )
% Computes features for input Gaussian Pyramid P

% F is a cell which contains a cell for each level of P
F = cell(1, size(P,2));

% padding of 2 for 5x5
if dim == 5
    pad = 2;
else
    % padding of 1 for 3x3
    pad = 1;
end

% maybe revise this to not use a loop for speed
for level = 1:size(P,2)
    width = size(P{level},1);
    length = size(P{level},2);
    features = cell(width, length);
    
    % fill inside first
    for r = 1 : width
        for c = 1 : length
            % get coords
            [ row, col ] = FindBorderCoords(r, c, P, level, pad);
            neighborhood = P{level}(row-pad:row+pad,col-pad:col+pad);
            featureVector = reshape(neighborhood.',1,[]);
            features{r,c} = featureVector;
        end
    end
    F{level} = features;
end

%{
% F is a cell which contains a cell for each level of P
F = cell(1, size(P,2));

% maybe revise this to not use a loop for speed
for level = 1:size(P,2)
    width = size(P{level},1);
    length = size(P{level},2);

    % think about how to define "fine" or "coarse" levels of pyramid?
    % change 30?
    % use 5x5 neighborhood
    if dim == 5
        % padding to add zeros around for border
        padded = zeros([width,length]+4);
        padded(3:end-2,3:end-2) = P{level};
        features = cell(width, length);
        for row = 3:size(padded,1)-2
            for col = 3:size(padded,2)-2
                neighborhood = padded(row-2:row+2,col-2:col+2);
                featureVector = reshape(neighborhood.',1,[]);
                features{row-2,col-2} = featureVector;
            end
        end
        F{level} = features;
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
%}

end
