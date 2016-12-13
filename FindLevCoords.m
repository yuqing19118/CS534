function [ r, c ] = FindLevCoords( row, col, img, level )
% Finding corresponding pixels in previous 3x3 level

% uncomment below for debugging
%{
coords = cell(size(img{level},1),size(img{level},2));
for row = 1:size(img{level},1)
    for col = 1:size(img{level},2)
%}

rows = size(img{level},1);
cols = size(img{level},2);
if (row <= 3) && (col <= 3)
    r = 3;
    c = 3;
% upper right corner
elseif (row <= 3) && (col >= cols-1)
    r = 3;
    c = cols-2;
% lower left corner
elseif (row >= rows-1) && (col <= 3)
    r = rows-2;
    c = 3;
% lower right corner
elseif (row >= rows-1) && (col >= cols-1)
    r = rows-2;
    c = cols-2;  
% first rows
elseif row <= 3
    r = 3;
    c = col;
% first columns
elseif col <= 3
    r = row;
    c = 3;
% last rows
elseif (row >= rows-1)
    r = rows-2;
    c = col;
% last column
elseif (col >= cols-1)
    r = row;
    c = cols-2;
% middle
else
    r = row;
    c = col;
end

%{  
        coords{row, col} = [r c];
    end
end
%}
end

