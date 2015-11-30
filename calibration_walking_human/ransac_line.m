function [best_line] = ransac_line(pts, inline_threshold, n_trials)

if nargin == 1
    inline_threshold = 50;
	n_trials = 100;
elseif nargin == 2
    n_trials = 100;
end

n_points = size(pts, 2);

max_inliers = 0;
best_line = [];
best_line_inliers = [];

for i = 1:n_trials
    % take two points randomically.
    
    i1 = randi(n_points);
    i2 = i1;
    while (i1 == i2)
        i2 = randi(n_points);
    end
    
    r_line = cross([pts(:,i1); 1.0], [pts(:,i2); 1.0]);
    
    % count the inliers
    n_inliers = 0;
    i_inliers = [];
    for j = 1:n_points
        d = dist_point_line(r_line, pts(:,j));
        if d < inline_threshold
            n_inliers = n_inliers + 1;
            i_inliers = [i_inliers j];
        end
    end
    
    % update if is best
    if n_inliers > max_inliers
        max_inliers = n_inliers;
        best_line = r_line;
        best_line_inliers = i_inliers;
    end    
end

% now we perform the LSE minimization using only the inliers
best_line = LSE_line(pts(:, best_line_inliers));

% plot(pts(1, best_line_inliers), pts(2, best_line_inliers), '+g');
    
    
    
    
function d = dist_point_line(line, pt)

x = pt(1);
y = pt(2);

d = abs((line(1)*x + line(2)*y + line(3))/sqrt(line(1)^2 + line(2)^2));