function [ x, y, which ] = BestMatch( featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, gpA, gpAprime, gpB, gpBprime, flannA, flannB, s, level, row, col )
% BestMatch using FLANN and BestCoherenceMatch

[ xapp, yapp ] = BestApproximateMatch( gpA, gpB, flannA, flannB, level, row, col );
[ xcoh, ycoh ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, s, level, row, col );

% get feature vectors
% find closest corresponding pixel in coarse level
xapp3x3 = floor(xapp/2);
yapp3x3 = floor(yapp/2);
% if first row and/or first col, set it to (1,1)
if xapp3x3 == 0 || yapp3x3 == 0 
    xapp3x3 = 1;
    yapp3x3 = 1;
end
% find closest corresponding pixel in coarse level
xcoh3x3 = floor(xcoh/2);
ycoh3x3 = floor(ycoh/2);
% if first row and/or first col, set it to (1,1)
if xcoh3x3 == 0 || ycoh3x3 == 0 
    xcoh3x3 = 1;
    ycoh3x3 = 1;
end

% get fvapp
if level < size(featuresA3x3,2) && xapp3x3 <= size(featuresA3x3{level+1},1) && yapp3x3 <= size(featuresA3x3{level+1},2)
    fvAapp3x3 = featuresA3x3{level+1}{xapp3x3, yapp3x3};
    fvAprimeapp3x3 = featuresAprime3x3{level+1}{xapp3x3, yapp3x3};
else
    fvAapp3x3 = zeros(1,9);
    fvAprimeapp3x3 = zeros(1,9);
end
fvAapp5x5 = featuresA5x5{level}{xapp, yapp};
fvAprimeapp5x5 = featuresAprime5x5{level}{xapp, yapp};
fvapp = [fvAapp3x3 fvAprimeapp3x3 fvAapp5x5 fvAprimeapp5x5];

% get fvcoh
if level < size(featuresA3x3,2) && xcoh3x3 <= size(featuresA3x3{level+1},1) && ycoh3x3 <= size(featuresA3x3{level+1},2)
    fvAcoh3x3 = featuresA3x3{level+1}{xcoh3x3, ycoh3x3};
    fvAprimecoh3x3 = featuresAprime3x3{level+1}{xcoh3x3, ycoh3x3};
else
    fvAcoh3x3 = zeros(1,9);
    fvAprimecoh3x3 = zeros(1,9);
end
fvAcoh5x5 = featuresA5x5{level}{xcoh, ycoh};
fvAprimecoh5x5 = featuresAprime5x5{level}{xcoh, ycoh};
fvcoh = [fvAcoh3x3 fvAprimecoh3x3 fvAcoh5x5 fvAprimecoh5x5];

% get fvq
% find closest corresponding pixel in coarse level
row3x3 = floor(row/2);
col3x3 = floor(col/2);
% if first row and/or first col, set it to (1,1)
if row3x3 == 0 || col3x3 == 0 || row3x3 == 1 || col3x3 == 1
    row3x3 = 3;
    col3x3 = 3;
end
if level < size(featuresB3x3,2) && row3x3 <= size(featuresB3x3{level+1},1) && col3x3 <= size(featuresB3x3{level+1},2)
    fvB3x3 = featuresB3x3{level+1}{row3x3, col3x3};
else
    fvB3x3 = zeros(1,9);
end
fvB5x5 = featuresB5x5{level}{row, col};

% avoid border pixels
if level < size(gpBprime,2) && row >= 3 && row < size(gpBprime{level},1)-1 && col >=3 && col < size(gpBprime{level},2)-1
    
    [ rowprev, colprev ] = FindPrevLevCoords( row, col, gpBprime, level );
    % get fvBprime
    fvBprimematrix3x3 = gpBprime{level+1}(rowprev-1:rowprev+1,colprev-1:colprev+1);
    fvBprime3x3 = reshape(fvBprimematrix3x3.',[1,9]);
    fvBprimematrix5x5 = gpBprime{level}(row-2:row+2,col-2:col+2);
    fvBprime5x5 = reshape(fvBprimematrix5x5.',[1,25]);
    fvq = [fvB3x3 fvBprime3x3 fvB5x5 fvBprime5x5];
else
    fvq = zeros(1,68);
end

% get Gaussian: 5x5 & 3x3
g3x3 = fspecial('gaussian',3);
g5x5 = fspecial('gaussian',5);
% reshape to a row vector
gvec3x3 = reshape(g3x3,[1,9]);
gvec5x5 = reshape(g5x5,[1,25]);
% make it match size of fvapp, fvcoh, fvq
gauss = [gvec3x3 gvec3x3 gvec5x5 gvec5x5];

dapp = sum(gauss(:,1:55).* (fvapp(:,1:55) - fvq(:,1:55)).^2);
dcoh = sum(gauss(:,1:55).* (fvcoh(:,1:55) - fvq(:,1:55)).^2);

% maybe change value of kappa
kappa = 2;
if dcoh <= dapp * (1 + 2^(level - size(gpB,2)) * kappa)
    x = xcoh;
    y = ycoh;
    which = 'coh';
else
    x = xapp;
    y = yapp;
    which = 'app';
end

end
