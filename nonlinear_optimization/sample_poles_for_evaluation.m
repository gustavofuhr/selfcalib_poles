function [h_pts, f_pts] = sample_poles_for_evaluation(h_pts, f_pts, percentual)

n_points = length(h_pts);
n_new_points = round(n_points*percentual);

r = randi(n_points, [n_new_points, 1]);

h_pts = h_pts(:, r);
f_pts = f_pts(:, r);