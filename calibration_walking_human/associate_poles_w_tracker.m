function ass = associate_poles_w_tracker(tracker_results, head_points, feet_points, frames)

n_poles = size(head_points, 2);

ass = zeros(1, n_poles); 
for i = 1:n_poles
    i_frame = frames(i);
    bbs = tracker_results(i_frame).bboxes;
    
    dists = zeros(1, size(bbs, 1));
    for ib = 1:size(bbs, 1)
        dists(ib) = distance_pole_to_tracker(head_points(:, i), feet_points(:, i), bbs(ib, :));
    end
    
    % take the one with the minimum distance
    threshold = 30;
    [min_dist, i_min] = min(dists);
    if length(i_min) == 1 && min_dist < threshold
        ass(i) = tracker_results(i_frame).ids(i_min);
    else
        ass(i) = -1;
    end
    
end


function dist = distance_pole_to_tracker(head_point, feet_point, bbox)

mid = (head_point + feet_point) / 2.0;

tracker_center_point = [(bbox(1) + bbox(3)) / 2.0; (bbox(2) + bbox(4)) / 2.0]; 

dist = norm(mid - tracker_center_point);