%
% This function tries to sample the poles to create a more uniform distribution (in the image)
% of them. The small_radius parameter is used to remove any duplicates that were detected, and
% the sample step is used to create virtual squares in which the density will be tested.
% If the density is above the average, the square will be randomlly sampled
%
function [new_head_points, new_feet_points] = sample_poles(head_points, feet_points, small_radius, sample_step)

n_pts = length(head_points);
% first remove duplicates and poles to close to each other
nh_pts = head_points;
nf_pts = feet_points;

n_new_points = n_pts;
i = 1;
while i < n_new_points
    i_points_inside = [];
    for j = 1:n_new_points
        % the distance is compute in pixels
        d = norm(nf_pts(:,i) - nf_pts(:,j));
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


new_head_points = nh_pts;
new_feet_points = nf_pts;
