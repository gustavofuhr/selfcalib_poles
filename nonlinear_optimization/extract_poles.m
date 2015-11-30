function [h_pts, f_pts] = extract_poles(options)

% init background segmentation
addpath('./3rdparty/vibe');

if isfield(options, 'bg_model_filename')
    load(options.bg_model_filename);
else
    tic; fprintf('Building background model...');
    bg_model = bgs_model(options.init_bg_training, options.begin_frame, options, 4);
    toc;
    disp('Its your chance to save the background model for next time (variable name = bg_model)...');
    keyboard;
end

% init detection
addpath('./3rdparty/piotr_toolbox');
load('./3rdparty/piotr_toolbox/detector/models/AcfInriaDetector.mat');
detector.opts.cascThr   = -0.3;
detector.opts.im_resize = 2;
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
    
    if isfield(detector_model.opts, 'im_resize') && detector_model.opts.im_resize ~= 1
        im_frame = imresize(im_frame, detector_model.opts.im_resize);
    end

    bboxes = acfDetect(im_frame, detector_model);
    bboxes = bboxes(:, 1:4);

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
    fprintf('Segmenting frame...'); tic;
    bgs = bgs_frame(bg_model, i, options);
    toc;    
  
    fprintf('Computing principal direction...'); tic;
    %% see the direction of each detected person using PCA
    for j = 1:size(bboxes, 1)
        % extract the relevant background segmnetation part.
        bb = uint16(bboxes(j, :));
        bb = trunc_roi(bb, im_size(1), im_size(2));
        
        bgs_ped = bgs(bb(2):bb(4), bb(1):bb(3));
        
        % at least a big part of the detection must be foreground
        min_perc_foreground = 0.2;
        n_bbox = (bb(4)-bb(2))*(bb(3)-bb(1));
        n_foreground = sum(sum(bgs_ped));
        if n_foreground > 0 && (n_foreground/n_bbox) > min_perc_foreground
            
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
                end
                
            end
        end
    end   
    toc;
end




    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

