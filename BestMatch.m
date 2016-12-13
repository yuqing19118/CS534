function [ x, y, which ] = BestMatch( featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, gpA, gpAprime, gpB, gpBprime, flannA, flannB, s, level, row, col )
% BestMatch using FLANN and BestCoherenceMatch

[ xapp, yapp ] = BestApproximateMatch( gpA, gpB, flannA, flannB, level, row, col );
[ xcoh, ycoh ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, s, level, row, col );

fvapp = MakeF(xapp, yapp, featuresA3x3, featuresAprime3x3, featuresA5x5, featuresAprime5x5, level, false);
fvcoh = MakeF(xcoh, ycoh, featuresA3x3, featuresAprime3x3, featuresA5x5, featuresAprime5x5, level, false);
fvq = MakeF(row, col, featuresB3x3, gpBprime, featuresB5x5, gpBprime, level, true);

% finest level
L = size(gpBprime,2);
% check if a coarser level exists
if level < L
    % get Gaussian: 5x5 & 3x3
    g3x3 = fspecial('gaussian',3);
    g5x5 = fspecial('gaussian',5);
    % reshape to a row vector
    gvec3x3 = reshape(g3x3,[1,9]);
    gvec5x5 = reshape(g5x5,[1,25]);
    % make it match size of fvapp, fvcoh, fvq
    gauss = [gvec3x3 gvec3x3 gvec5x5 gvec5x5];
else
    g5x5 = fspecial('gaussian',5);
    gvec5x5 = reshape(g5x5,[1,25]);
    gauss = [gvec5x5 gvec5x5];
end

% avoid using unsynthesized portion, so subtract 13 at the end
dapp = sum(gauss(:,1:end-13).* (fvapp(:,1:end-13) - fvq(:,1:end-13)).^2);
dcoh = sum(gauss(:,1:end-13).* (fvcoh(:,1:end-13) - fvq(:,1:end-13)).^2);

% maybe change value of kappa
kappa = 2;
if dcoh <= dapp * (1 + 2^(level - L) * kappa)
    x = xcoh;
    y = ycoh;
    which = 'coh';
else
    x = xapp;
    y = yapp;
    which = 'app';
end

end
