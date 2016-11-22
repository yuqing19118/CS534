clear;

% read input images
A =  imread('images/A.jpg');
Aprime =  imread('images/Aprime.jpg');
B =  imread('images/B.jpg');

% RGB to YIQ color space
yiqA = rgb2ntsc(A);
yiqAprime = rgb2ntsc(Aprime);
yiqB = rgb2ntsc(B);

% get Y (luminance) channel
yA = yiqA(:,:,1);
yAprime = yiqAprime(:,:,1);
yB = yiqB(:,:,1);

% get luminance remapped A, Aprime
[ remapA, remapAprime ] = LuminanceRemapping( yA, yAprime, yB );

% compute Gaussian Pyramids for A, Aprime, B
gpA = ComputeGaussianPyramid(yA);
gpAprime = ComputeGaussianPyramid(yAprime);
gpB = ComputeGaussianPyramid(yB);

% compute features for A, Aprime, B
featuresA = ComputeFeatures(gpA);
featuresAprime = ComputeFeatures(gpAprime);
featuresB = ComputeFeatures(gpB);