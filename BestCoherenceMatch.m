function [ best_coh_row,best_coh_col ] = BestCoherenceMatch( gpA, gpAprime, gpB, gpBprime, featuresAprime, s, level, row, col )

% get window size: 5x5 or 3x3
diff=(sqrt(length(featuresAprime{level}{row,col}))-1)/2;

% get F_q
if diff == 2
    F_q = zeros(5,5);
else
    F_q = zeros(3,3);
end

if (row > diff && row+diff < size(featuresAprime{level},1)) && (col > diff && col+diff < size(featuresAprime{level},2))
    % get F_q
    if diff == 2
        F_q = gpBprime{level}(row-2:row+2,col-2:col+2);
    else
        F_q = gpBprime{level}(row-1:row+1,col-1:col+1);
    end
end

mindist = inf;
[boundrow, boundcol]=size(gpA{level});

% default values for best_coh_row and best_coh_col
best_coh_row = 1;
best_coh_col = 1;

% Loop over neighborhood
if (row > diff && row+diff < size(featuresAprime{level},1)) && (col > diff && col+diff < size(featuresAprime{level},2))
 for i = row-diff:row+diff 
   for j = col-diff:col+diff
    
 
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
    
    % Grab the corresponding pixels from gpAprime. 
    Featurematrix_aprime=featuresAprime{level}{F_match_row,F_match_col};

      dist = sum((Featurematrix_aprime(:) - F_q(:)).^2);
      
     if dist < mindist
      mindist = dist;
      best_coh_row = F_match_row;
      best_coh_col = F_match_col;
     end
    end
 end
end
end
