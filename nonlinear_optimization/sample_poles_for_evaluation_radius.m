function [h_pts_samp, f_pts_samp] = sample_poles_for_evaluation_radius(h_pts, f_pts, w_feet_point, radius, n_points)

% first select the poles inside the radius
mean_point = mean(w_feet_point, 2);
d_error = arrayfun(@(idx) norm(mean_point - w_feet_point(:,idx)), 1:size(w_feet_point,2));

in_points = find(d_error <= radius);

r = randperm(length(in_points), n_points);
r_idx = in_points(r);

h_pts_samp = h_pts(:, r_idx);
f_pts_samp = f_pts(:, r_idx);