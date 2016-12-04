function [ best_coh_row,best_coh_col ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, s, level, row, col )


% Best coherencematch
F_q = ComputeFeatures(gpBprime){level}{row,col};
mindist = inf;
[boundrow, boundcol,~]=size(gpA{level});


% Loop over neighborhood
for i = 1:max(s(row,col),1)
  for j = 1:max(s(row,col),2)
    
    % Done, (i,j) is the original pixel
    if i == row && j == col
    %done

       break
    end
       s_i = s{level}(i,j,1);
       s_j = s{level}(i,j,2);
    
    % A coherent pixel match for q
    % A neighbor to our neighbor's match
    F_match_row = s_i + (row - i);
    F_match_col = s_j + (col - j); 
    % may not be necessary
    if F_match_row > boundrow || F_match_row < 1 || F_match_col > boundcol || F_match_col < 1
%       fprintf(`Error occurs and cannot continue at (%d, %d)\n', F_match_row , F_match_col );
    end
    
    % Grab the corresponding pixels from gpAprime. 
    Featurematrix_aprime=ComputeFeatures(gpAprime){level}(F_match_row,F_match_col);

      dist = sum((Featurematrix_aprime(:) - F_q(:)).^2);
      
     if dist < mindist
      mindist = dist;
      best_coh_row = F_match_row;
      best_coh_col = F_match_col;
    end
  end
end
end