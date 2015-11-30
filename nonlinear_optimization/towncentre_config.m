function [options] = towncentre_config()    

options.P_gt = 1.0e+04 * ...
    [0.204353158306599  -0.196496184722238  -0.039223357897077   1.172781417821273; ...
    -0.039946471188736  -0.013648757406928  -0.271719757444714   1.702096372175217; ...
     0.000082892109512   0.000044215337252  -0.000034262255214   0.001239112186432];


options.image_pref        = '~/study/datasets/towncentre/frame';
options.d_mask            = 5;
options.file_ext          = 'png';

options.bg_model_filename = './bg_models/bg_model_vibe_towncentre_1_250.mat';
options.background_file   = './bg_models/tc_backgrounds_1_1000.mat';
options.begin_frame       = 1;
options.end_frame         = 1000;
options.step_frame        = 5;

options.ground_truth_file = './gt/towncentre/gt_roi_subject_16.mat';

options.ransac_inliner  = 750;
options.ransac_trials   = 100;

options.poles_file = '../calibration_walking_human/in/tc_poles_1_5_1000_min_qt_011.mat';

options.ground_plane_region = [-5000 5000; -5000 5000];
options.im_frame = '~/study/datasets/towncentre/frame00001.png';
 
options.im_origin_point = [1920/2.0; 1080/2.0; 1];
options.ground_plane_std = 3000;

options.scale_gt_metric = 1./1000;