% this script will read foot points and plot poles using the
% ground truth calibration

close all;
clear;
clc;

load('qt_pts_all.mat');
h_pts = double(h_pts);
f_pts = double(f_pts);

% options.image_pref         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.image_pref         = '/home/gfuhr/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.d_mask            = 4;
options.file_ext          = 'jpg';
options.ith_frame         = 180;

% get the ground truth calibration
calib_filename = 'gt/pets_view_001.xml';
[K, Rt] = parse_xml_calibration_file(calib_filename);
P = K*Rt;
H = [P(:, 1:2) P(:, 4)];

im_frame = get_frame(options, options.ith_frame);
imshow(im_frame); hold on;

for i = 1:size(f_pts, 2)
    im_f_point = [f_pts(:, i); 1.0];    
    
    w_f_point = ics2wcs_H(im_f_point, H);
    
    % defines the head point at 2 meters high
    w_h_point = [w_f_point(1); w_f_point(2); 2000.0; 1.0];
    im_h_point = wcs2ics(w_h_point, P);
    
    % I am going to plot the the truth one and the computed one
    plot([im_f_point(1), im_h_point(1)], [im_f_point(2), im_h_point(2)], '-b', 'LineWidth', 2.0);
    plot([im_f_point(1), h_pts(1, i)], [im_f_point(2), h_pts(2, i)], '-r', 'LineWidth', 2.0);
end
