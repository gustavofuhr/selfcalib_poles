%
% This function tries to sample the poles to create a more uniform distribution (in the world)
% of them. The small_radius parameter is used to remove any duplicates that were detected, and
% the sample step is used to create virtual squares in which the density will be tested.
% If the density is above the average, the square will be randomlly sampled
%
function [new_head_points, new_feet_points] = sample_poles(head_points, feet_points, P, small_radius, sample_step)

H = [P(:, 1:2) P(:, 4)];

n_pts = length(head_points);
% first remove duplicates and poles to close to each other
nh_pts = head_points;
nf_pts = feet_points;

n_new_points = n_pts;
i = 1;
while i < n_new_points
    i_points_inside = [];
    for j = 1:n_new_points
        % the distances are computed in world coordinates
        wfeet_pt1 = ics2wcs_H([nf_pts(:,i); 1], H);
        wfeet_pt2 = ics2wcs_H([nf_pts(:,j); 1], H);
        
        d = norm(wfeet_pt1 - wfeet_pt2);
        if d < small_radius
            i_points_inside = [i_points_inside j];
        end
    end
    
    if length(i_points_inside) > 1
        % now, randomlly sample one of the points that are inside
        i_elected = i_points_inside(round(rand(1)*(length(i_points_inside)-1))+1);
        
        % remove from the list all other points
        i_other = setdiff(i_points_inside, i_elected);
        nh_pts(:, i_other) = [];
        nf_pts(:, i_other) = [];
        
        n_new_points = length(nh_pts);
        
        if i_elected == i
            i = i+1;
        end
    else
        i = i + 1;
    end
end

% first of all, I reconstruct all the remaining poles in the world
w_feet_points = ics2wcs_H([nf_pts; ones(1, size(nf_pts, 2))], H);
min_x = min(w_feet_points(1,:)); max_x = max(w_feet_points(1,:));
min_y = min(w_feet_points(2,:)); max_y = max(w_feet_points(2,:));

debug = false;
if debug
    figure; hold all;
    plot(w_feet_points(1,:), w_feet_points(2,:), 'x');
    axis equal;
end

n_pts_square = [];
n_squares = length(min_y:sample_step:max_y)*length(min_x:sample_step:max_x);
for i = 1:n_squares
    pts_square(i).pts = [];
end
i_square = 1;
% coloca os indices de cada ponto do square na lista, depois eu faco
% o sampling deles e boto no novo h_pts e f_pts
for y = min_y:sample_step:max_y
    for x = min_x:sample_step:max_x
        % count how many feet points are in the range
        n_inside = 0;
        for i = 1:size(w_feet_points, 2)
            if w_feet_points(1,i) < x+sample_step && w_feet_points(1,i) >= x && ...
                    w_feet_points(2,i) < y+sample_step && w_feet_points(2,i) >= y
                n_inside = n_inside + 1;
                pts_square(i_square).pts = [pts_square(i_square).pts i];
            end
        end
        n_pts_square = [n_pts_square n_inside];
        
        if debug
            % show the square
            plot([x x x+sample_step x+sample_step x], [y y+sample_step y+sample_step y  y], '-k');
            fprintf('%d points inside the square\n', n_inside);
        end
        
        i_square = i_square + 1;
    end
end

% fprintf('Mean %f\n', mean_number_poles);
nn_pts_square = n_pts_square(n_pts_square > 0);
% see which squares are outliers in the number of points and sample them
% remove outliers from the errors
med_pts = median(nn_pts_square);
third_quartile = median(nn_pts_square(nn_pts_square > med_pts));
third_quartile = mean(nn_pts_square);


new_head_points = [];
new_feet_points = [];
for i = 1:length(n_pts_square)
    pts_sq = pts_square(i).pts;
    if n_pts_square(i) > third_quartile
        j_elected = pts_sq(round(rand(1, round(third_quartile))*(length(pts_sq)-1))+1);
    else
        j_elected = pts_sq;
    end
    
    for j = j_elected
        new_head_points = [new_head_points nh_pts(:, j)];
        new_feet_points = [new_feet_points nf_pts(:, j)];
    end
end


if debug
    fprintf('\n\n');
    figure; hold all;
    w_feet_points = ics2wcs_H([new_feet_points; ones(1, size(new_feet_points, 2))], H);
    plot(w_feet_points(1,:), w_feet_points(2,:), 'x');
    axis equal;
    for y = min_y:sample_step:max_y
        for x = min_x:sample_step:max_x
            % count how many feet points are in the range
            n_inside = 0;
            for i = 1:size(w_feet_points, 2)
                if w_feet_points(1,i) < x+sample_step && w_feet_points(1,i) >= x && ...
                        w_feet_points(2,i) < y+sample_step && w_feet_points(2,i) >= y
                    n_inside = n_inside + 1;
                end
            end
            % show the square
            plot([x x x+sample_step x+sample_step x], [y y+sample_step y+sample_step y  y], '-k');
            fprintf('%d points inside the square\n', n_inside);
        end
    end
    keyboard;
end

