function [ remapA, remapAprime ] = LuminanceRemapping( yA, yAprime, yB )
% luminance remapping for A, Aprime

% remap luminance channel of A
remapA = (std2(yB)/std2(yA)) * (yA-mean2(yA)) + mean2(yB);
% remap luminance channel of Aprime for consistency
remapAprime = (std2(yB)/std2(yAprime)) * (yA-mean2(yAprime)) + mean2(yB);

end