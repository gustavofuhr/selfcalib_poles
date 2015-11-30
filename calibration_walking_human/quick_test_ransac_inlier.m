clear;
clc;
close all;

% options.image_pref         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.image_pref      = '~/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.d_mask          = 4;
options.file_ext        = 'jpg';
options.begin_frame     = 1;
options.end_frame       = 230;
options.tracker_results = 'in/breitenstein_pets_results.txt';
options.plot_poles      = false;
options.min_distance    = 30;

options.ransac_trials   = 100;

if options.plot_poles, mkdir(options.out_path); end;

load('in/poles_1_230_min_qt_009.mat')

h_pts = double(h_pts);
f_pts = double(f_pts);

%% now compute the vertical vanishing point and the horizon line
vy = extract_vanishing_point(h_pts, f_pts);

tracker_res = read_tracker_results(options.tracker_results);
poles_ass = associate_poles_w_tracker(tracker_res, h_pts, f_pts, frs);


r_inliers = [5	10	30	40	50	75	100	120 150 170 200 230 250 270 300];

for ri = r_inliers
    options.ransac_inliner  = ri;
    h_line = horizon_line(h_pts, f_pts, poles_ass, options);

    
    P = calibrate_cvpr2002(vy, h_line, im_size, h_pts, f_pts);
    error = analyse_P(P, false);
    fprintf('Ransac inlier: %f errors: angles: %f dist: %f\n', ri, error.angle, error.dist);
    
end


