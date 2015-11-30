clear; close all; clc;

options = towncentre_config();

load(options.poles_file);
addpath('../evaluate_results/');


n_radius = 50;
n_points = 15;
n_times = 50;

H = [options.P_gt(:, 1:2) options.P_gt(:, 4)];

feet_points = f_pts;
w_feet_point = ics2wcs_H([feet_points; ones(1, size(feet_points,2))], H);
mean_point = mean(w_feet_point, 2);
d_error = arrayfun(@(idx) norm(mean_point - w_feet_point(:,idx)), 1:size(w_feet_point,2));
max_radius = max(d_error);

init_radius = 3.2;
% init_radius = 1200;
radii = init_radius:(max_radius-init_radius)/n_radius:max_radius;

errors = zeros(length(radii), n_times);
for i = 1:length(radii)
    i
    r = radii(i);
    
    for t = 1:n_times
        [h_pts_samp, f_pts_samp] = sample_poles_for_evaluation_radius(h_pts, f_pts, w_feet_point, r, n_points);
        
        P = test_whole_calibration(h_pts_samp, f_pts_samp, options);
        options.P_estimate = P;
        error_P = evaluate_calibration(options.P_gt, options.P_estimate, options, true);
        
        errors(i,t) = error_P;
    end
    
    im_frame = get_frame(options, options.begin_frame);
    imshow(im_frame); hold on;
    for j = 1:size(h_pts_samp,2)
        plot([h_pts_samp(1,j), f_pts_samp(1,j)], [h_pts_samp(2,j), f_pts_samp(2,j)], 'r');
    end
    pause(0.1); hold off;
end


figure;
plot(radii, median(errors,2), '-r');
errorbar(radii, median(errors, 2), std(errors'), 'x', 'Color', [0.5, 0.5, 0.5]);

disp('Save the errors!');
