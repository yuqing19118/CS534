function [ rowprev, colprev ] = FindBorderCoords( row, col, img, level, pad )
% Dealing with borders; get appropriate feature vectors

% pad is 1 for 3x3, 2 for 5x5
% uncomment below for debugging

%{
pad = 1;
coords = cell(size(img{level},1),size(img{level},2));
for row = 1:size(img{level},1)
    for col = 1:size(img{level},2)
%}
% upper left corner
if (row <= pad + 1) && (col <= pad + 1)
    rowprev = pad + 1;
    colprev = pad + 1;
% upper right corner
elseif (row <= pad + 1) && (col >= size(img{level},2)-pad)
    rowprev = pad + 1;
    colprev = size(img{level},2) - pad;
% lower left corner
elseif (row >= size(img{level},1)-pad) && (col <= pad + 1)
    rowprev = size(img{level},1) - pad;
    colprev = pad + 1;
% lower right corner
elseif (row >= size(img{level},1)-pad) && (col >= size(img{level},2)-pad)
    rowprev = size(img{level},1) - pad;
    colprev = size(img{level},2) - pad;
% top rows
elseif row <= pad 
    rowprev = pad + 1;
    colprev = col;
% left cols
elseif col <= pad
    rowprev = row;
    colprev = pad + 1;
 % last rows
elseif row > size(img{level},1)-pad
    rowprev = size(img{level},1) - pad;
    colprev = col;
 % last cols
elseif col >= size(img{level},2)-pad
    rowprev = row;
    colprev = size(img{level},2) - pad;
% middle
else
    rowprev = row;
    colprev = col;
end
        %{
        coords{row, col} = [rowprev colprev];
    end
end
        %}

end

