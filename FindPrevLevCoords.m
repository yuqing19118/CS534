function [ rowprev, colprev ] = FindPrevLevCoords( row, col, img, level )
% Finding corresponding pixels in previous 3x3 level



if (row == 1 || row == 2 || row == 3) && (col == 1 || col == 2 || col == 3)
    rowprev = 2;
    colprev = 2;
% upper right corner
elseif(row == 1 || row == 2 || row == 3) && col == size(img{level},2)
    rowprev = 2;
    colprev = floor(col/2) - 1;
% lower left corner
elseif row == size(img{level},1) && (col == 1 || col == 2 || col == 3)
    rowprev = floor(row/2) - 1;
    colprev = 2;
% lower right corner
elseif row == size(img{level},1) && col == size(img{level},2)
    rowprev = floor(row/2) - 1;
    colprev = floor(col/2) - 1;  
% first rows
elseif row == 1 || row == 2 || row == 3
    rowprev = 2;
    colprev = floor(col/2);
% first columns
elseif col == 1 || col == 2 || col == 3
    rowprev = floor(row/2);
    colprev = 2;
% last row
elseif row == size(img{level},1)
    rowprev = floor(row/2) - 1;
    colprev = floor(col/2);
% last column
elseif col == size(img{level},2)
    rowprev = floor(row/2);
    colprev = floor(col/2) - 1;
% middle
else
    rowprev = floor(row/2);
    colprev = floor(col/2);
end

end

