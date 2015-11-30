function [P] = test_whole_calibration(h_pts, f_pts, options)

h_pts_original = h_pts;
f_pts_original = f_pts;

im_frame = get_frame(options, options.begin_frame);
im_size  = size(im_frame);

h_pts = double(h_pts);
f_pts = double(f_pts);
fprintf('Initial calibration...'); tic;
addpath('../calibration_walking_human/');

%% sample the poles to obtain a more uniform distribution
[h_pts, f_pts] = sample_poles_initial(h_pts, f_pts, 10, 2000);
% var = get_poles_variance(h_pts, options);
% figure; imshow(im_frame); hold on;
% for i = 1:length(h_pts)
%     plot([h_pts(1,i) f_pts(1,i)], [h_pts(2,i) f_pts(2,i)], '-r');
% end
% title('Poles used in the initial calibration');


%% now compute the vertical vanishing point and the horizon line
vy = extract_vanishing_point(h_pts, f_pts);
h_line = horizon_line(h_pts, f_pts, [], options);
init_P = calibrate_cvpr2002(vy, h_line, im_size, h_pts, f_pts);
toc;

% figure;
% H = [init_P(:, 1:2) init_P(:, 4)];
% im_origin_point = [im_size(2)/2.0; im_size(1)/2.0; 1];
% ts = ics2wcs_H(im_origin_point, H);
% 
% tracking_area = [-2000, 2000; -2000, 2000];
% im_frame = get_frame(options, options.begin_frame);
% imshow(im_frame); hold on;
% for i = 1:size(h_pts,2) 
%     plot([h_pts(1,i), f_pts(1,i)], [h_pts(2,i), f_pts(2,i)], 'r');
% end
% 
% plot_grid(tracking_area, H, 500, ts);
% plot_axis(2000.0, H, init_P, ts);
% title('Initial calibration');


all_P = {};
errors = [];
fprintf('Computing the calibration through nonlinear optimization...'); tic;
for i = 1:1
    h_pts_orig = double(h_pts_original);
    f_pts_orig = double(f_pts_original);

    [h_pts, f_pts] = sample_poles(h_pts_orig, f_pts_orig, init_P, 50, 2000);
    if isempty(f_pts)
        f_pts = f_pts_orig;
        h_pts = h_pts_orig;
    end
        
% 	var = get_poles_variance(h_pts, options);
    
    [P, ferror] = nonlinear_selfcalibration_optimized(init_P, h_pts, f_pts, options, []);
    all_P{i} = P;
    errors = [errors ferror];
end
[~, i_min] = min(errors);
P = all_P{i_min};
toc;

%% show results
% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.
% figure;
% H = [P(:, 1:2) P(:, 4)];
% im_origin_point = [im_size(2)/2.0; im_size(1)/2.0; 1];
% ts = ics2wcs_H(im_origin_point, H);
% 
% tracking_area = [-2000, 2000; -2000, 2000];
% im_frame = get_frame(options, options.begin_frame);
% imshow(im_frame); hold on;
% for i = 1:size(h_pts,2) 
%     plot([h_pts(1,i), f_pts(1,i)], [h_pts(2,i), f_pts(2,i)], 'r');
% end
% 
% plot_grid(tracking_area, H, 500, ts);
% plot_axis(2000.0, H, P, ts);
% title('Optimized calibration');



