function [ x, y ] = BestMatch( featuresA, featuresAprime, featuresB, gpA, gpAprime, gpB, gpBprime, flannA, flannB, s, level, row, col )
% BestMatch using FLANN and BestCoherenceMatch

[ xapp, yapp ] = BestApproximateMatch( gpA, gpB, flannA, flannB, 1, row, col );
[ xcoh, ycoh ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, s, level, row, col );

% get feature vectors
% get fvapp
if size(featuresAprime{level}{xapp, yapp},2) == 25
    neighborhood = zeros(1,25);
    neighborhood(:,1:12) = featuresAprime{level}{xapp, yapp}(:,1:12);
    fvapp = reshape(neighborhood,[5,5]).';
else
    neighborhood = zeros(1,9);
    neighborhood(:,1:4) = featuresAprime{level}{xapp, yapp}(:,1:4);
    fvapp = reshape(neighborhood,[3,3]).';
end

% get fvcoh
if size(featuresAprime{level}{xcoh, ycoh},2) == 25
    neighborhood = zeros(1,25);
    neighborhood(:,1:12) = featuresAprime{level}{xcoh, ycoh}(:,1:12);
    fvcoh = reshape(neighborhood,[5,5]).';
else
    neighborhood = zeros(1,9);
    neighborhood(:,1:4) = featuresAprime{level}{xcoh, ycoh}(:,1:4);
    fvcoh = reshape(neighborhood,[3,3]).';
end

% get feature vector in Bprime
featuresBprime = ComputeFeatures(gpBprime);
% get fvq
if size(featuresBprime{level}{row, col},2) == 25
    neighborhood = zeros(1,25);
    neighborhood(:,1:12) = featuresBprime{level}{row, col}(:,1:12);
    fvq = reshape(neighborhood,[5,5]).';
    gauss = fspecial('gaussian',5);
    gauss(3,4:end) = 0;
    gauss(4:end,:) = 0;
else
    neighborhood = zeros(1,9);
    neighborhood(:,1:4) = featuresBprime{level}{row, col}(:,1:4);
    fvq = reshape(neighborhood,[3,3]).';
    gauss = fspecial('gaussian',3);
    gauss(2,2:end) = 0;
    gauss(3:end,:) = 0;
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
