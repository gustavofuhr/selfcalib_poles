function P = calibration_walking_human(options)

%% extract poles
fprintf('\nDetecting poles...\n');

% init background segmentation
addpath('./3rdparty/vibe');

if isfield(options, 'bg_model_filename')
    load(options.bg_model_filename);
else
    tic; fprintf('Building background model...');
    bg_model = bgs_model(options.init_bg_training, options.begin_frame, options, 1);
    toc;
    disp('Its your chance to save the background model for next time (variable name = bg_model)...');
    keyboard;
end

% load pre-computed backgrounds
if isfield(options, 'background_file')
    tic;
    fprintf('Loading pre-computed backgrounds...'); 
    load(options.background_file);
    toc;
else
    all_bgs = {};
end

% init detection
addpath('./3rdparty/piotr_toolbox');
load('./3rdparty/piotr_toolbox/detector/models/AcfInriaDetector.mat');
% detector.opts.cascThr   = -0.3;
detector.opts.im_resize = 1.0;
detector_model  = detector;

h_pts = [];
f_pts = [];
frs = [];
qts = [];
im_size = [];


for i = options.begin_frame:options.step_frame:options.end_frame    
    fprintf('Frame %d of %d...\n', i, options.end_frame);
    im_frame = get_frame(options, i);
    if i == options.begin_frame
        im_size = size(im_frame);
    end
    
    
    %% detect persons in the image
    options.detection_options.imgNm = im_frame;
    fprintf('Detecting pedestrians...'); tic;
    
    im_original_frame = im_frame;
    if isfield(detector_model.opts, 'im_resize') && detector_model.opts.im_resize ~= 1
        im_frame = imresize(im_frame, detector_model.opts.im_resize);
    end

    bboxes = acfDetect(im_frame, detector_model);
    bboxes = bboxes(bboxes(:,5) > options.detection_threshold, 1:4);

    if isfield(detector_model.opts, 'im_resize') && detector_model.opts.im_resize ~= 1
        bboxes = bboxes./detector_model.opts.im_resize;
    end
    toc;
    
    % Here I could expand these boxes to fit better the bgs
    bboxes = bboxes(:, 1:4);
    % we need to convert these bboxes from (x y w h) to (x1 y1 x2 y2)
    bboxes(:,3) = bboxes(:,1)+bboxes(:,3);
    bboxes(:,4) = bboxes(:,2)+bboxes(:,4);
    
    %% segment the frame using ViBE
    if isfield(options, 'background_file')
        bgs = all_bgs{i};
    else
        fprintf('Segmenting frame...'); tic;
        bgs = bgs_frame(bg_model, i, options);
        toc;
        all_bgs{i} = bgs;
    end
  
    if options.show_frames
        alpha = 0.50;
        mix = double(repmat(bgs*255, [1 1, 3])).*alpha + double(im_original_frame).*(1 - alpha);
        imshow(uint8(mix)); hold on;
        plot_bboxes(bboxes, [0.7 0.7 0.7]);
    end
    
    fprintf('Computing principal direction...'); tic;
    %% see the direction of each detected person using PCA
    for j = 1:size(bboxes, 1)
        % extract the relevant background segmnetation part.
        bb = uint16(bboxes(j, :));
        bb = trunc_roi(bb, im_size(1), im_size(2));
        
        bgs_ped = bgs(bb(2):bb(4), bb(1):bb(3));
        
        % at least a big part of the detection must be foreground
        min_perc_foreground = 0.2;
        n_bbox = double((bb(4)-bb(2))*(bb(3)-bb(1)));
        n_foreground = sum(sum(bgs_ped));
        if n_foreground > 0 && double((n_foreground/n_bbox)) > min_perc_foreground
            
            [foot_pt, head_pt, qt] = pedestrian_orientation_PCA(bgs_ped);            
            if sum(head_pt == [0;0]) == 0 && sum(foot_pt == [0;0]) == 0
                head_pt = head_pt + bb(1:2)';
                foot_pt = foot_pt + bb(1:2)';                
                
                if length(qts) >= j
                    qts(j).v = [qts(j).v qt];
                else
                    qts(j).v = [qt];
                end
                
                % only includes if we have a good idea that the legs were
                % not split apart in the frame
                if qt < options.min_qt
                    frs = [frs i];
                    h_pts = [h_pts double(head_pt)];
                    f_pts = [f_pts double(foot_pt)];                    
                    
                    if options.show_frames
                        plot([head_pt(1) foot_pt(1)], [head_pt(2) foot_pt(2)], '-r', 'LineWidth', 2.0);
                    end
                end
                
            end
        end
    end   
    toc;
    
    if options.show_frames
        if options.save_frames
            export_fig([options.out_path, '/frame_', format_int(4, i), '.png'], '-a1');
        end
        pause(0.1); hold off;
    end
end

fprintf('Save stuff (consider qts) :\n');
keyboard;


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
            plot([f_pts(1,i), h_pts(1,i)], [f_pts(2,i), h_pts(2,i)], '-b', 'LineWidth', 1.5);
        end
    end
    
    export_fig(['out/frame_', format_int(3,i), '.png'], '-a2');    
end





% imshow(im_frame); hold on;
% for i = 1:size(h_pts, 2)
%     if poles_ass ~= -1
%         c = colors(mod(poles_ass(i), n_colors)+1, :);
%         plot([f_pts(1,i), h_pts(1,i)], [f_pts(2,i), h_pts(2,i)], '-', 'Color', c, 'LineWidth', 1.5);
%     else
%         plot([f_pts(1,i), h_pts(1,i)], [f_pts(2,i), h_pts(2,i)], '-b', 'LineWidth', 1.5);
%     end
%         
% end
h_line = horizon_line(h_pts, f_pts, poles_ass);
toc;

fprintf('Self-calibrating...'); tic;
P = calibrate_cvpr2002(vy, h_line, im_size, h_pts, f_pts);
toc;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

