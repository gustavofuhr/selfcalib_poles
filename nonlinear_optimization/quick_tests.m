clear;
clc;
close all;

dataset = 'towncentre';
if strcmp(dataset, 'pets')
    options.image_pref        = '~/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
    options.d_mask            = 4;
    options.file_ext          = 'jpg';
        
    % 1_230_min_qt_011			
    init_P = 1.0e+06 * ...
		   [0.000698829948912  -0.000171861199733   0.000227719316790  -1.088344460347762; ...
		   -0.000021854602901   0.000025681614729   0.000636647168520  -3.042743271939621; ...
		    0.000000698790626   0.000000586432837   0.000000409619566  -0.001957704738525];
        
    options.out_path    = '~/phd/out_nonlinear/eccv_poles';
    
    load('../calibration_walking_human/in/poles_1_230_min_qt_009.mat');

elseif strcmp(dataset, 'towncentre')
    options.image_pref        = '~/study/datasets/towncentre/frame';
    options.d_mask            = 5;
    options.file_ext          = 'png';  
    
    init_P = 1.0e+06 * ...
	  [0.000893417788533  -0.001399811641123   0.000528806021286  -2.602953713463614;...
	  -0.000262303213788   0.000124402725143   0.001535568520222  -7.558563293714591;...
	   0.000000893331602   0.000000097379451   0.000000438720745  -0.002159524939477];
   
     options.out_path    = '~/study/out_nonlinear/tc_poles_1_5_1000_min_qt_011';
     load('../calibration_walking_human/in/tc_poles_1_5_1000_min_qt_011.mat');
elseif strcmp(dataset, 'choi')
    options.image_pref        = '/Users/gfuhr/phd/datasets/choi_dataset/images_sampled/';
    options.d_mask            = 4;
    options.file_ext          = 'jpg'; 
    
    init_P = 1.0e+05 * ...
        [0.005058902235541   0.001120927000892 0.001299155952323  -2.398226563849682; ...
         0.000579416192044   0.000860338247730 0.004268740744908  -7.880045063349185; ...
         0.000005058937703   0.000007926853527 0.000003401785190  -0.006279655335037];
     
    options.out_path = '~/phd/out_nonlinear/choi/';

    options.begin_frame       = 1;
    load('../calibration_walking_human sampling/in/choi_poles_1_420_all.mat');
end


options.im_frame = get_frame(options, 1); % for debug
% options.im_frame = imread('pets_background.png'); % for debug

mkdir(options.out_path);

h_pts = double(h_pts);
f_pts = double(f_pts);

% figure; imshow(im_frame); hold on;
% for i = 1:length(h_pts)
%     plot([h_pts(1,i) f_pts(1,i)], [h_pts(2,i) f_pts(2,i)], '-b');
% end
% fprintf('Before: %d poles\n', length(h_pts));

%% sample the poles to obtain a more uniform distribution
[h_pts, f_pts] = sample_poles(h_pts, f_pts, init_P, 50, 2000);
% figure; imshow(im_frame); hold on;
% for i = 1:length(h_pts)
%     plot([h_pts(1,i) f_pts(1,i)], [h_pts(2,i) f_pts(2,i)], '-r');
% end
% fprintf('After: %d poles\n', length(h_pts));

%% minimization
fprintf('Computing the calibration through nonlinear optimization...'); tic;
P = nonlinear_selfcalibration(init_P, h_pts, f_pts, options, []);
toc;

%% show results
% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.
H = [P(:, 1:2) P(:, 4)];

figure;
tracking_area = [-10000, 2000; -10000, 2000];
imshow(options.im_frame); hold on;

im_origin_point = [420; 315; 1];
ts = ics2wcs_H(im_origin_point, H);

plot_grid(tracking_area, H, 500, ts);
plot_axis(2000.0, H, P, ts);
