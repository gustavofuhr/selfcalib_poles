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
options.plot_poles      = true;
options.out_path        = 'out/poles_1_230_min_qt_009/';
options.ransac_inliner  = 75;
options.ransac_trials   = 100;
options.min_distance    = 30;


if options.plot_poles, mkdir(options.out_path); end;

% load('in/new_new_poles.mat')
load('in/poles_1_230_min_qt_009.mat')
% load('./poles.mat')



h_pts = double(h_pts);
f_pts = double(f_pts);

fprintf('Extracting vertical vanishing point and horizon line...'); tic;
%% now compute the vertical vanishing point and the horizon line
vy = extract_vanishing_point(h_pts, f_pts);

tracker_res = read_tracker_results(options.tracker_results);
poles_ass = associate_poles_w_tracker(tracker_res, h_pts, f_pts, frs);


n_colors = 20; 
colors = distinguishable_colors(n_colors);
% show the last n frames poles with respective colors
figure;
last_n_frames = 10;
for i = options.begin_frame:options.end_frame
    im_frame = get_frame(options, i);
    imshow(im_frame); hold on;
    
    i_min = max(i-last_n_frames, 1);
    
    % idx contains the indices of the h_pts and p_pts of the last n frames
    idx = find([frs >= i_min] & [frs <= i]);
    for j = idx
        if poles_ass(j) ~= -1
            c = colors(mod(poles_ass(j), n_colors)+1, :);
            plot([f_pts(1,j), h_pts(1,j)], [f_pts(2,j), h_pts(2,j)], '-', 'Color', c, 'LineWidth', 1.5);
        else
            plot([f_pts(1,j), h_pts(1,j)], [f_pts(2,j), h_pts(2,j)], '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5);
        end
    end
    hold off;
    
    if options.plot_poles 
        export_fig([options.out_path, 'frame_', format_int(3,i), '.png'], '-a2');
    else
        pause(0.1);
    end
end


h_line = horizon_line(h_pts, f_pts, poles_ass, options);
toc;

fprintf('Self-calibrating...'); tic;
P = calibrate_cvpr2002(vy, h_line, im_size, h_pts, f_pts);
toc;

% now, tries to show the ground plane and axis of the calibration to
% somehow attest how good is it.
im_frame = get_frame(options, options.begin_frame);
H = [P(:, 1:2) P(:, 4)];
ts = [-20000; -20000];
figure;
tracking_area = [0, 20000; 0, 20000];
imshow(im_frame); hold on;

plot_grid(tracking_area, H, 500, ts);
plot_poles_grid(tracking_area, P, 2500, 2000.0, ts);
plot_axis(2000.0, H, P, ts);

figure; imshow(im_frame); hold on;
error = analyse_P(P, true);
disp(error);


