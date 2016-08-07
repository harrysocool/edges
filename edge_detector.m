function all_boxes = edge_detector(image_filenames, output_filename)
    addpath('private');
    addpath('models')
    addpath('toolbox');

    if(~exist('edgesDetectMex'))
        mex private/edgesDetectMex.cpp -outdir private
    end

    if(~exist('edgesNmsMex'))
        mex private/edgesNmsMex.cpp    -outdir private
    end

    if(~exist('spDetectMex'))
        mex private/spDetectMex.cpp    -outdir private
    end  
    
    if(~exist('edgeBoxesMex'))
        mex private/edgeBoxesMex.cpp   -outdir private
    end

    %% load pre-trained edge detection model and set opts (see edgesDemo.m)
    model=load('models/forest/modelEAR0.4_2.mat'); model=model.model;
    model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

    %% set up opts for edgeBoxes (see edgeBoxes.m)
    opts = edgeBoxes;
    opts.alpha = .60;     % step size of sliding window search
    opts.beta  = .75;     % nms threshold for object proposals
    opts.minScore = .01;  % min score of boxes to detect
    opts.maxBoxes = 1e4;  % max number of boxes to detect

    %% detect Edge Box bounding box proposals (see edgeBoxes.m)
    % Process all images.
    all_boxes = {};
    count = 0;
    for i=1:length(image_filenames)
        im = imread(image_filenames{i});
        bbs=edgeBoxes(im,model,opts);
        % change it to the right format of the bbs
        bbs = double(bbs);
        bbs(:, 3:4) = bbs(:, 1:2) + bbs(:, 3:4);
        correct_bbs = bbs(:, 1:4) - 1;
        all_boxes{i} = correct_bbs;
        count = count + 1;
        display(['No.',int2str(count),' pictures processed, ', int2str(size(correct_bbs,1)), ' boxes']);
    end

    if nargin > 1
        save(output_filename, 'all_boxes', '-v7');
    end