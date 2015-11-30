% SCRIPT
clc; close all; clear;
format long;
dataset = 'choi';

addpath(genpath('./3rdparty/'));

%% dataset and background segmentation options
% the range between begin_frame and end_frame are set so that the vertical 
% poles, that are extracted from people, are obtained in this range
if strcmp(dataset, 'pets')
%     options.image_pref         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
    options.image_pref        = '~/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
%     options.tracker_results   = 'in/breitenstein_pets_results.txt';
    
    options.d_mask            = 4;
    options.file_ext          = 'jpg';
    
%     options.init_bg_training  = 110;
    options.bg_model_filename = 'in/bg_model_vibe_pets_110_180.mat';
    options.begin_frame       = 2;
    options.step_frame        = 1;
    options.end_frame         = 555;
elseif strcmp(dataset, 'towncentre')
    options.image_pref        = '~/phd/datasets/towncentre/frame';
    options.d_mask            = 5;
    options.file_ext          = 'png';  

    options.bg_model_filename = './in/bg_model_vibe_towncentre_1_250.mat';
    options.background_file   = './in/tc_backgrounds_1_1000.mat';
    options.begin_frame       = 1;
    options.end_frame         = 1000;
    options.step_frame        = 5;
elseif strcmp(dataset, 'tud_stadtmitte')
    options.image_pref        = '~/phd/datasets/tud_stadtmitte/DaMultiview-seq';
    options.d_mask            = 4;
    options.file_ext          = 'png';  

    options.bg_model_filename = './in/bg_model_vibe_tud_stadtmitte_7022_1_7200.mat';
%     options.init_bg_training  = 7022;
    %options.background_file   = './in/tc_backgrounds_1_1000.mat';
    options.begin_frame       = 7022;
    options.end_frame         = 7200;
    options.step_frame        = 1;
elseif strcmp(dataset, 'epfl_campus')
    options.image_pref        = '~/phd/datasets/epfl_campus/seq04_c1/frame_';
    options.d_mask            = 4;
    options.file_ext          = 'png';  

    options.bg_model_filename = './in/bg_model_vibe_epfl_campus_1_1_300.mat';
    %options.init_bg_training  = 1;
    %options.background_file   = './in/tc_backgrounds_1_1000.mat';
    options.begin_frame       = 150;
    options.end_frame         = 1999;
    options.step_frame        = 1;
elseif strcmp(dataset, 'choi')
    options.image_pref        = '/Users/gfuhr/phd/datasets/choi_dataset/images_sampled/';
    options.d_mask            = 4;
    options.file_ext          = 'jpg';  
    
    options.bg_model_filename = './in/bg_model_choi_1_1_420_random.mat';

    % options.init_bg_training  = 1;
    options.begin_frame       = 1;
    options.end_frame         = 420;
    options.step_frame        = 1;
end

%% self-calibration parameters 
options.min_qt = Inf;%0.11;

options.detection_threshold = 20;

options.show_frames = true;
options.save_frames = true;
options.out_path    = '~/phd/out_calibration/choi/';

if options.save_frames
    mkdir(options.out_path);
end

%% run
P = calibration_walking_human(options);

figure;
% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.
H = [P(:, 1:2) P(:, 4)];

tracking_area = [0, 20000; 0, 20000];
im_frame = get_frame(options, options.begin_frame);
imshow(im_frame); hold on;

plot_grid(tracking_area, H, 500);
plot_axis(2000.0, H, P);
