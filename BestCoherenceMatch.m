function [ best_coh_row,best_coh_col ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresA3x3, featuresA5x5, featuresAprime3x3, featuresAprime5x5, featuresB3x3, featuresB5x5, s, level, qrow, qcol )

fvq = MakeF(qrow, qcol, featuresB3x3, gpBprime, featuresB5x5, gpBprime, level, true);

mindist = inf;
[boundrow, boundcol]=size(gpA{level});

% default values for best_coh_row and best_coh_col
best_coh_row = 1;
best_coh_col = 1;


for ri = qrow-2 : qrow+2
    for rj = qcol-2 : qcol+2
        % make sure we don't consider unsynthesized pixels; line 67 increments
        if (ri < qrow) || (ri == qrow && rj < qcol)
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
        else
            return;
        end
    end
end
end