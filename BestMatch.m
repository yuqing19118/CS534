function [ x, y ] = BestMatch( featuresA, featuresAprime, featuresB, gpA, gpAprime, gpB, gpBprime, flannA, flannB, s, level, row, col )
% BestMatch using FLANN and BestCoherenceMatch

[ xapp, yapp ] = BestApproximateMatch( gpA, gpB, flannA, flannB, level, row, col );
[ xcoh, ycoh ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresAprime, s, level, row, col );

% get feature vectors

% get fvapp
if size(featuresA{level}{xapp, yapp},2) == 25
    neighborhood = featuresA{level}{xapp, yapp};
    fvapp = reshape(neighborhood,[5,5]).';
else
    neighborhood = featuresA{level}{xapp, yapp};
    fvapp = reshape(neighborhood,[3,3]).';
end

% get fvcoh
if size(featuresAprime{level}{xcoh, ycoh},2) == 25
    neighborhood = featuresA{level}{xcoh, ycoh};
    fvcoh = reshape(neighborhood,[5,5]).';
else
    neighborhood = featuresA{level}{xcoh, ycoh};
    fvcoh = reshape(neighborhood,[3,3]).';
end

% get window size: 5x5 or 3x3
diff=(sqrt(length(featuresAprime{level}{row,col}))-1)/2;

if (row > diff && row+diff < size(featuresAprime{level},1)) && (col > diff && col+diff < size(featuresAprime{level},2))
    % get fvq
    if diff == 2 % 5x5
        neighborhood = featuresB{level}{row, col};
        fvq = reshape(neighborhood,[5,5]).';
        gauss = fspecial('gaussian',5);
    else % 3x3
        neighborhood = featuresB{level}{row, col};
        fvq = reshape(neighborhood,[3,3]).';
        gauss = fspecial('gaussian',3);
    end
else
    if diff == 2
        fvq = zeros(5,5);
        gauss = fspecial('gaussian',5);
    else
        fvq = zeros(3,3);
        gauss = fspecial('gaussian',3);
    end
end

dapp = sum(gauss.* (fvapp - fvq)).^2;
dcoh = sum(gauss.* (fvcoh - fvq)).^2;

% maybe change value of kappa
kappa = 12;
if dcoh <= dapp * (1 + 2^(level - size(gpB,2) * kappa))
    x = xcoh;
    y = ycoh;
else
    x = xapp;
    y = yapp;
end

end
