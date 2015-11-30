clear;
clc;
close all;

% format long;
dataset = 'pets';

if strcmp(dataset, 'pets')
    options.image_pref        = '~/study/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
    options.d_mask            = 4;
    options.file_ext          = 'jpg';
    options.begin_frame       = 1;
%     load('in/poles_1_180_all.mat');
    load('in/lv_pets_poles.mat');
elseif strcmp(dataset, 'towncentre')
    options.image_pref        = '~/phd/datasets/towncentre/frame';
    options.d_mask            = 5;
    options.file_ext          = 'png';  
elseif strcmp(dataset, 'tud_stadtmitte')
    options.image_pref        = '~/phd/datasets/tud_stadtmitte/DaMultiview-seq';
    options.d_mask            = 4;
    options.file_ext          = 'png';  
    options.begin_frame       = 7200;
    load('in/tud_stadtmitte_poles_all_all.mat');
elseif strcmp(dataset, 'epfl_campus')
    options.image_pref        = '~/phd/datasets/epfl_campus/seq04_c1/frame_';
    options.d_mask            = 4;
    options.file_ext          = 'png'; 
    options.begin_frame       = 1;
    load('in/epfl_campus_poles_all_all.mat');
elseif strcmp(dataset, 'choi')
    options.image_pref        = '/Users/gfuhr/phd/datasets/choi_dataset/images_sampled/';
    options.d_mask            = 4;
    options.file_ext          = 'jpg'; 
    options.begin_frame       = 1;
    load('in/choi_poles_1_420_all.mat');
end


options.ransac_inliner  = 75;
options.ransac_trials   = 100;

im_frame = get_frame(options, options.begin_frame);
im_size  = size(im_frame);

% show the poles in the image
imshow(im_frame); hold on;
for i = 1:size(h_pts,2) 
    plot([h_pts(1,i), f_pts(1,i)], [h_pts(2,i), f_pts(2,i)], 'r');
end

h_pts = double(h_pts);
f_pts = double(f_pts);

figure; imshow(im_frame); hold on;
for i = 1:length(h_pts)
    plot([h_pts(1,i) f_pts(1,i)], [h_pts(2,i) f_pts(2,i)], '-b');
end
fprintf('Before: %d poles\n', length(h_pts));

%% sample the poles to obtain a more uniform distribution
[h_pts, f_pts] = sample_poles(h_pts, f_pts, 10, 2000);
figure; imshow(im_frame); hold on;
for i = 1:length(h_pts)
    plot([h_pts(1,i) f_pts(1,i)], [h_pts(2,i) f_pts(2,i)], '-r');
end
fprintf('After: %d poles\n', length(h_pts));


figure;
imshow(im_frame); hold on;

fprintf('Extracting vertical vanishing point and horizon line...'); tic;
%% now compute the vertical vanishing point and the horizon line
vy = extract_vanishing_point(h_pts, f_pts);

plot(vy(1), vy(2), 'xr', 'MarkerSize', 10);

h_line = horizon_line(h_pts, f_pts, [], options);
toc;

axis auto;

fprintf('Self-calibrating...'); tic;
P = calibrate_cvpr2002(vy, h_line, im_size, h_pts, f_pts);
toc;


% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.

% PETS groundtruth
% gt_P = 1.0e+07 * ... 
%       [0.000092758253702  -0.000079086639724  -0.000015319476449 1.248195750930406; ...
%       -0.000009234442978   0.000001295124261  -0.000122402299869 0.622898830135874; ...
%        0.000000077919286   0.000000055889203  -0.000000028372202 0.003546929854700];


% TownCentre groundtruth
% gt_P = [1.0e+04 * ...
%    0.204353158306599  -0.196496184722238  -0.039223357897077   1.172781417821273; ...
%   -0.039946471188736  -0.013648757406928  -0.271719757444714   1.702096372175217; ...
%    0.000082892109512   0.000044215337252  -0.000034262255214   0.001239112186432];


H = [P(:, 1:2) P(:, 4)];

figure;
im_origin_point = [420; 315; 1];
ts = ics2wcs_H(im_origin_point, H);

tracking_area = [-10000, 2000; -10000, 2000];
imshow(im_frame); hold on;

plot_grid(tracking_area, H, 500, ts);
plot_poles_grid(tracking_area, P, 2500, 2000.0, ts);
plot_axis(2000.0, H, P, ts);

if exist('gt_P')
    figure; imshow(im_frame); hold on;
    error = analyse_P(gt_P, P, true);
    disp(error);
end