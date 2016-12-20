clear;

% read input images
A = imread('images/wcA.jpg');
Aprime = imread('images/wcAprime.jpg');
B = imread('images/wcB.jpg');

Bprime = CreateImageAnalogy(A, Aprime, B);

imwrite(Bprime, 'images/result.jpg', 'jpg');