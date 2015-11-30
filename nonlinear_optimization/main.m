% SCRIPT
clc; close all; clear;
format long;
dataset = 'pets';

%% dataset and background segmentation options
% the range between begin_frame and end_frame are set so that the vertical 
% poles, that are extracted from people, are obtained in this range
if strcmp(dataset, 'pets')
    %     options.image_suf         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
%     options.image_suf         = '/home/gfuhr/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
    options.image_pref        = '/Users/gfuhr/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
    options.tracker_results   = 'in/breitenstein_pets_results.txt';
    
    options.d_mask            = 4;
    options.file_ext          = 'jpg';
    
%     options.init_bg_training  = 110;
    options.bg_model_filename = 'bg_model_vibe_pets_110_180.mat';
    options.begin_frame       = 180;
    options.step_frame        = 1;
    options.end_frame         = 556;
elseif strcmp(dataset, 'towncentre')
    options.image_suf      = '/home/gfuhr/phd/datasets/oxford/TownCentre_frames/';
    options.d_mask            = 5;
    options.file_ext          = 'png';  

    options.bg_model_filename = 'bg_model_vibe_towncentre_1_250.mat';
    options.begin_frame       = 250;
    options.end_frame         = 1000;
end

options.min_qt = 0.09;

%% extract poles
fprintf('\nDetecting poles...\n'); tic;
[head_points, feet_points] = extract_poles(options);
toc;

%% minimization
fprintf('Computing the calibration through nonlinear optimization...'); tic;
P = nonlinear_selfcalibration(head_points, feet_points, options);
toc;

%% show results
figure;
% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.
H = [P(:, 1:2) P(:, 4)];

tracking_area = [0, 20000; 0, 20000];
im_frame = get_frame(options, options.begin_frame);
imshow(im_frame); hold on;

plot_grid(tracking_area, H, 500);
plot_axis(2000.0, H, P);
