function [ F ] = MakeF( x, y, coarse, coarseprime, fine, fineprime, level, fq )
% a function to make fvapp, fvcoh, fvq for BestMatch

% find closest corresponding pixel in coarse level
x3x3 = floor(x/2);
y3x3 = floor(y/2);

% handle borders; don't need to worry about other corners, last row, last
% col since floor rounds down
% if first row & first col, set it to (1,1)
if x3x3 == 0 && y3x3 == 0 
    x3x3 = 1;
    y3x3 = 1;
% if in first row
elseif x3x3 == 0
    x3x3 = 1;
% if in first col
elseif y3x3 == 0
    y3x3 = 1;
end

if fq == false % making fvapp or fvcoh
    % finest level
    L = size(coarse,2);
    % make fv: either fvapp, fvcoh, fvq depending on input
    % check if a coarser level exists
    if level < L
        fvcoarse3x3 = coarse{level+1}{x3x3, y3x3};
        fvcoarseprime3x3 = coarseprime{level+1}{x3x3, y3x3};
        fvfine5x5 = fine{level}{x, y};
        fvfineprime5x5 = fineprime{level}{x, y};
        F = [fvcoarse3x3 fvcoarseprime3x3 fvfine5x5 fvfineprime5x5];
    else % at top level, just use current level
        fvfine5x5 = fine{level}{x, y};
        fvfineprime5x5 = fineprime{level}{x, y};
        F = [fvfine5x5 fvfineprime5x5];
    end
else % making fvq
    % finest level
    L = size(coarse,2);
    % check if a coarser level exists
    if level < L
        fvcoarse3x3 = coarse{level+1}{x3x3, y3x3};
        % get coordinates of coarser level
        [ rowprev, colprev ] = FindPrevLevCoords( x, y, coarseprime, level );
        fvcoarseprimematrix = coarseprime{level+1}(rowprev-1:rowprev+1,colprev-1:colprev+1);
        fvcoarseprime3x3 = reshape(fvcoarseprimematrix.',[1,9]);
        fvfine5x5 = fine{level}{x, y};
        % get coordinates for this level
        [ row, col ] = FindLevCoords( x, y, fineprime, level );
        fvfineprimematrix = fineprime{level}(row-2:row+2,col-2:col+2);
        fvfineprime5x5 = reshape(fvfineprimematrix.',[1,25]);
        F = [fvcoarse3x3 fvcoarseprime3x3 fvfine5x5 fvfineprime5x5];
    else % at top level, just use current level
        fvfine5x5 = fine{level}{x, y};
        % get coordinates for this level
        [ row, col ] = FindLevCoords( x, y, fineprime, level );
        fvfineprimematrix = fineprime{level}(row-2:row+2,col-2:col+2);
        fvfineprime5x5 = reshape(fvfineprimematrix.',[1,25]);
        F = [fvfine5x5 fvfineprime5x5];
    end
end

end

