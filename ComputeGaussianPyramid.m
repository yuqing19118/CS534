function [ P ] = ComputeGaussianPyramid( Y )
% Computes Gaussian Pyramid for input Y channel

% keeping track of the minimum dimension size
dim = min(size(Y,1),size(Y,2));

% initialize pyramid, lowest level is L (highest resolution)
P = {Y};
% l denotes level of pyramid
l = 2;
% Yl is current level of pyramid
Yl = Y;

% set 27 kind of arbitrarily... what smallest pyramid size should be set?
while dim >= 27
    Yl = impyramid(Yl, 'reduce');
    P{l} = Yl;
	l = l + 1;
    dim = dim / 2;
end

end

