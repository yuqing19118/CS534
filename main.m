clear;

% read input images
A = imread('images/bigA.jpg');
Aprime = imread('images/bigAprime.jpg');
B = imread('images/bigB.jpg');

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
featuresA3x3 = ComputeFeatures(gpA,3);
featuresA5x5 = ComputeFeatures(gpA,5);
featuresAprime3x3 = ComputeFeatures(gpAprime,3);
featuresAprime5x5 = ComputeFeatures(gpAprime,5);
featuresB3x3 = ComputeFeatures(gpB,3);
featuresB5x5 = ComputeFeatures(gpB,5);

flannA = InitializeSearchStructures(featuresA5x5);
flannB = InitializeSearchStructures(featuresB5x5);

%{
% compute Bprime, pixel by pixel
gpBprime = cell(1,size(featuresB,2));
for row = 1:size(featuresB{1},1)
    for col = 1:size(featuresB{1},2)
        [ x, y ] = BestApproximateMatch(gpA, gpB, flannA, flannB, 1, row, col);
        gpBprime{1}(row, col) = gpAprime{1}(x,y);
    end
end
%}

% trying the smallest level
% compute Bprime, pixel by pixel
gpBprime = cell(1,size(featuresB5x5,2));
% make gpBprime full of zeros
for level = 1:size(gpB,2)
    gpBprime{level} = zeros(size(gpB{level},1),size(gpB{level},2));
end

s = cell(1,size(featuresB5x5,2));
% make s full of zeros
for level = 1:size(gpB,2)
    for row = 1:size(gpB{level},1)
        for col = 1:size(gpB{level},2)
            s{level}{row, col} = zeros(1,2);
        end
    end
end

% image analogy, change level in 6 places in the following lines
for level = size(gpBprime,2): -1 : 5
    for row = 1:size(featuresB5x5{level},1)
        for col = 1:size(featuresB5x5{level},2)
            [ x, y ] = BestMatch(featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, gpA, gpAprime, gpB, gpBprime, flannA, flannB, s, level, row, col);
            gpBprime{level}(row, col) = gpAprime{level}(x,y);
            s{level}{row, col} = [ x y ];
        end
    end
end

% for all levels
%{
% compute Bprime, pixel by pixel
gpBprime = cell(1,size(featuresB,2));
s = cell(1,size(featuresB,2));
for level = size(gpBprime,2):1
    for row = 1:size(featuresB{level},1)
        for col = 1:size(featuresB{level},2)
            [ x, y ] = BestMatch(featuresA, featuresAprime, featuresB, gpBprime, flannA, flannB, s, level, row, col);
            gpBprime{level}(row, col) = gpAprime{level}(x,y);
            s{level}(row, col) = [ x, y ];
        end
    end
end
%}

% get Y channel of Bprime
yBprime = gpBprime{1};
% combine with original IQ channels
yiqBprime = cat(3, yBprime,yiqB(:,:,2),yiqB(:,:,3));

% YIQ to RGB
Bprime = ntsc2rgb(yiqBprime);
%imwrite(Bprime, 'images/bigBprime.jpg', 'jpg');


yBprime = gpBprime{2};
resize = imresize(B,size(gpBprime{4}));
yiqBsmall = rgb2ntsc(resize);
yiqBprime = cat(3, yBprime,yiqBsmall(:,:,2),yiqBsmall(:,:,3));
Bprime = ntsc2rgb(yiqBprime);
imshow(Bprime);
imwrite(Bprime, 'images/bigBprimelevel2.jpg', 'jpg');
