   
clear; close all; 

format long

vanishing_point = 1.0e+03 * [0.542335664335664; 2.081176470588235];
% vanishing_point = 1.0e+03 * [0.5399; 4.3142];

horizon_line = [-0.0544; -1.0000; -53.7773];
% horizon_line = [0.023476268506490; -1.000000000000000; 98.308204007085322];
horizon_line = [0.000077139572069  -0.011869436725978   1.000000000000000];

% options.image_pref         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.image_pref         = '~/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.d_mask            = 4;
options.file_ext          = 'jpg';
options.ith_frame         = 180;

im_frame = get_frame(options, options.ith_frame);

load('qt_pts_all.mat');
f_pts = double(f_pts);
h_pts = double(h_pts);

head_point = h_pts(:,1);
feet_point = f_pts(:,1);


figure('Color', 'w');
P = calibrate_cvpr2002(vanishing_point, horizon_line, size(im_frame), head_point, feet_point);
% imshow(im_frame); 
P

% H = [P(:, 1) P(:, 3:4)];
H = [P(:, 1:2) P(:, 4)];

tracking_area = [-500, 20000; ...
    -5000, 12000];
imshow(im_frame); hold on;
plot_grid(tracking_area, H);
plot_axis(3000.0, H, P);