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
    % stay inside bounds
    if (row > diff && row+diff < size(featuresAprime5x5{level},1)) && (col > diff && col+diff < size(featuresAprime5x5{level},2))
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
            end
        end
    end
end

        
        
    
    
  
%{
% Fill in F_q values
rowprev = floor(row/2);
colprev = floor(col/2);
if rowprev == 0 || colprev == 0 || rowprev == 1 || colprev == 1
    rowprev=2;
    colprev=2;
end
% Make sure those indices are inside the bound
if (level > size(gpBprime,2) && row > 3 && rowprev < size(gpBprime{level+1},1) && row<size(gpBprime{level},1)-3)... 
    && (col > 3 && colprev < size(gpBprime{level+1},2) && col <size(gpBprime{level},2)-3) 
    F_q(1:9) = featuresB3x3{level+1}{rowprev,colprev};
    Bprimematrix3x3 = gpBprime{level+1}(rowprev-1:rowprev+1,colprev-1:colprev+1);
    F_q(10:18)=reshape(Bprimematrix3x3.',[1,9]);
    F_q(19:43)= featuresB5x5{level}{row,col};
    Bprimematrix5x5= gpBprime{level}(row-2:row+2,col-2:col+2);
    F_q(44:end)=reshape(Bprimematrix5x5.',[1,25]);
end

mindist = inf;
[boundrow, boundcol]=size(gpA{level});

% default values for best_coh_row and best_coh_col
best_coh_row = 1;
best_coh_col = 1;

% Loop over neighborhood around pixel in Aprime
diff=2;
if (row > diff && row+diff < size(featuresAprime5x5{level},1)) && (col > diff && col+diff < size(featuresAprime5x5{level},2))
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
    
 % Fill in F_sr values
F_match_rowprev = floor(F_match_row/2);
F_match_colprev = floor(F_match_col/2);
if F_match_rowprev == 0 || F_match_colprev == 0
    F_match_rowprev=1;
    F_match_colprev=1;
end
if (level > size(gpBprime,2) && F_match_row > 3 && F_match_row<=size(gpAprime{level},2)-2) && (F_match_col > 3 && F_match_row<=size(gpAprime{level},2)-2)
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
    end
 end
end
end
%}

%rewriting
%{
% get F_q
F_q = zeros(1,68);
F_sr = zeros(1,68);

% Fill in F_q values
rowprev = floor(row/2);
colprev = floor(col/2);
if rowprev == 0 || colprev == 0 || rowprev == 1 || colprev == 1
    rowprev=2;
    colprev=2;
end
% Make sure those indices are inside the bound
if (level > size(gpBprime,2) && row > 3 && rowprev < size(gpBprime{level+1},1) && row<size(gpBprime{level},1)-3)... 
    && (col > 3 && colprev < size(gpBprime{level+1},2) && col <size(gpBprime{level},2)-3) 
    F_q(1:9) = featuresB3x3{level+1}{rowprev,colprev};
    Bprimematrix3x3 = gpBprime{level+1}(rowprev-1:rowprev+1,colprev-1:colprev+1);
    F_q(10:18)=reshape(Bprimematrix3x3.',[1,9]);
    F_q(19:43)= featuresB5x5{level}{row,col};
    Bprimematrix5x5= gpBprime{level}(row-2:row+2,col-2:col+2);
    F_q(44:end)=reshape(Bprimematrix5x5.',[1,25]);
end

mindist = inf;
[boundrow, boundcol]=size(gpA{level});

% default values for best_coh_row and best_coh_col
best_coh_row = 1;
best_coh_col = 1;

% Loop over neighborhood around pixel in Aprime
diff=2;
if (row > diff && row+diff < size(featuresAprime5x5{level},1)) && (col > diff && col+diff < size(featuresAprime5x5{level},2))
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
    
 % Fill in F_sr values
F_match_rowprev = floor(F_match_row/2);
F_match_colprev = floor(F_match_col/2);
if F_match_rowprev == 0 || F_match_colprev == 0
    F_match_rowprev=1;
    F_match_colprev=1;
end
if (level > size(gpBprime,2) && F_match_row > 3 && F_match_row<=size(gpAprime{level},2)-2) && (F_match_col > 3 && F_match_row<=size(gpAprime{level},2)-2)
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
    end
 end
end
end
%}


% old
%{
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
%}