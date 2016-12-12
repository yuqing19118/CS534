function [ x, y ] = BestApproximateMatch(gpA, gpB, flannA, flannB, level, row, col)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% dataset is corresponding level of image A
dataset = flannA{level};

% get test set (feature vector of pixel q)
pixel = sub2ind(size(gpB{level}), row, col);
testset = flannB{level}(:,pixel);

% set default params; tweak these?
params.algorithm = 'kdtree';
params.trees = 1;
params.checks = 1;

% do FLANN search to find NN in A
result = flann_search(dataset,testset,1,params);

% convert back to x, y coordinates
[ x, y ] = ind2sub(size(gpB{level}),result);

end