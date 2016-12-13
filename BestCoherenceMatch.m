function [ best_coh_row,best_coh_col ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, s, level, qrow, qcol )


L = size(gpBprime,2);

fvq = MakeF(qrow, qcol, featuresB3x3, gpBprime, featuresB5x5, gpBprime, level, true);

mindist = inf;
[boundrow, boundcol]=size(gpA{level});

% default values for best_coh_row and best_coh_col
best_coh_row = 1;
best_coh_col = 1;

% make sure we don't consider unsynthesized pixels; line 67 increments
count = 0;
for ri = qrow-2 : qrow+2
    for rj = qcol-2 : qcol+2
        
        if count < 12
            % find valid corresponding pixels; handles border
            [ row, col ] = FindLevCoords( ri, rj, s, level );
            sri = s{level}{row,col}(1,1);
            srj = s{level}{row,col}(1,2);
            matchrow = sri + (qrow - ri);
            matchcol = srj + (qcol - rj);

            % upper left corner
            if matchrow < 1 && matchcol < 1
                matchrow = 1;
                matchcol = 1;
            % upper right corner
            elseif matchrow < 1 && matchcol > boundcol
                matchrow = 1;
                matchcol = boundcol;
            % lower left corner
            elseif matchrow > boundrow && matchcol < 1
                matchrow = boundrow;
                matchcol = 1;
            % lower right corner
            elseif matchrow > boundrow && matchcol > boundcol
                matchrow = boundrow;
                matchcol = boundcol;
            % upper rows
            elseif matchrow < 1
                matchrow = 1;
            % lower rows
            elseif matchrow > boundrow
                matchrow = boundrow;
            % left cols
            elseif matchcol < 1
                matchcol = 1;
            % right cols
            elseif matchcol > boundcol
                matchcol = boundcol;
            end

            fsr = MakeF(matchrow, matchcol, featuresA3x3, featuresAprime3x3, featuresA5x5, featuresAprime5x5, level, false);

            dist = sum((fsr(:) - fvq(:)).^2);

            if dist < mindist
                mindist = dist;
                best_coh_row = matchrow;
                best_coh_col = matchcol;
            end
            
            count = count + 1;
        end
    end
end
end



% OLD
%{
function [ best_coh_row,best_coh_col ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, s, level, row, col )
% intialize feature vectors 
F_q = zeros(1,68);
F_sr = zeros(1,68);

% check if this level is the top level of the pyramid
if level >= size(gpBprime,2)
    % default values for best_coh_row and best_coh_col
    best_coh_row = 1;
    best_coh_col = 1;
else    
    % rowprev & colprev are corresponding pixels of row, col in previous level
    % which has half the resolution of the current level
    % upper left corner
    [ rowprev, colprev ] =  FindPrevLevCoords( row, col, gpBprime, level );
    
    % get feature vector [Bprevlev Bprimeprevlev Bthislev Bprimethislev]
    % revise line below
    F_q(1:9) = featuresB3x3{level+1}{rowprev,colprev};
    Bprimematrix3x3 = gpBprime{level+1}(rowprev-1:rowprev+1,colprev-1:colprev+1);
    F_q(10:18)=reshape(Bprimematrix3x3.',[1,9]);
    F_q(19:43)= featuresB5x5{level}{row,col};
    % revise lines below
    if row >= 3 && row <= size(gpBprime{level},1)-2 && col >= 3 && col <= size(gpBprime{level},2)-2
        Bprimematrix5x5 = gpBprime{level}(row-2:row+2,col-2:col+2);
    else
        Bprimematrix5x5 = zeros(5,5);
    end
    F_q(44:end) = reshape(Bprimematrix5x5.',[1,25]);
    
    mindist = inf;
    [boundrow, boundcol]=size(gpA{level});

    % default values for best_coh_row and best_coh_col
    best_coh_row = 1;
    best_coh_col = 1;
    
    % Loop over neighborhood around pixel in Aprime
    diff=2;
    
    count = 0;
    % stay inside bounds
    if (row > diff && row+diff < size(featuresAprime5x5{level},1)) && (col > diff && col+diff < size(featuresAprime5x5{level},2))
        for i = row-diff:row+diff 
            for j = col-diff:col+diff
                
                if count < 12
                    s_i = s{level}{i,j}(1,1);
                    s_j = s{level}{i,j}(1,2);

                    % A coherent pixel match for q
                    % A neighbor to our neighbor's match
                    F_match_row = s_i + (row - i);
                    F_match_col = s_j + (col - j); 
                    % may not be necessary
                    if F_match_row > boundrow || F_match_row < 1 || F_match_col > boundcol || F_match_col < 1
                       % fprintf('Error occurs and cannot continue at (%d, %d)\n', F_match_row , F_match_col );
                       F_match_row = 1;
                       F_match_col = 1; 
                    end

                    % Fill in F_sr values
                    F_match_rowprev = floor(F_match_row/2);
                    F_match_colprev = floor(F_match_col/2);
                    if F_match_rowprev == 0 || F_match_colprev == 0
                        F_match_rowprev=1;
                        F_match_colprev=1;
                    end

                    if (F_match_row > 3 && F_match_row<=size(gpAprime{level},2)-2) && (F_match_col > 3 && F_match_row<=size(gpAprime{level},2)-2)
                        F_sr(1:9) = featuresA3x3{level+1}{F_match_rowprev,F_match_colprev};
                        F_sr(10:18)= featuresAprime3x3{level+1}{F_match_rowprev,F_match_colprev};
                        F_sr(19:43)= featuresA5x5{level}{F_match_row,F_match_col};
                        F_sr(44:end)=featuresAprime5x5{level}{F_match_row,F_match_col};
                    end   

                    dist = sum((F_sr(:) - F_q(:)).^2);

                    if dist < mindist
                        mindist = dist;
                        best_coh_row = F_match_row;
                        best_coh_col = F_match_col;
                    end
                    
                    count = count + 1;
                end
            end
        end
    end
end
%}