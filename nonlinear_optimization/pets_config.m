function [options] = pets_config()    

options.P_gt = 1.0e+07 * ... 
       [0.000092758253702  -0.000079086639724  -0.000015319476449 1.248195750930406; ...
       -0.000009234442978   0.000001295124261  -0.000122402299869 0.622898830135874; ...
        0.000000077919286   0.000000055889203  -0.000000028372202 0.003546929854700];


options.image_pref        = '~/study/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.d_mask            = 4;
options.file_ext          = 'jpg';

options.begin_frame       = 1;
options.end_frame         = 1000;
options.step_frame        = 5;

options.ransac_inliner  = 750;
options.ransac_trials   = 100;

options.poles_file = '../calibration_walking_human/in/poles_1_230_min_qt_011.mat';

options.ground_plane_region = [-5000 5000; -5000 5000];
options.im_frame = '~/study/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_0001.jpg' ;
 
options.im_origin_point = [768/2.0; 576/2.0; 1];
options.ground_plane_std = 3000;

options.scale_gt_metric = 1;


options.poles_region = [-8.170959707951280e+03 1.601492924495151e+04; ...
                        -1.343098824216179e+04 1.391577659905446e+04];

options.square_size = 200;