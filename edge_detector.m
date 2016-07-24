function all_boxes = edge_detector(image_filenames, output_filename)
    addpath('private');
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
    model=load('models/forest/modelBsds'); model=model.model;
    model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

    %% set up opts for edgeBoxes (see edgeBoxes.m)
    opts = edgeBoxes;
    opts.alpha = .35;     % step size of sliding window search
    opts.beta  = .75;     % nms threshold for object proposals
    opts.minScore = .01;  % min score of boxes to detect
    opts.maxBoxes = 1e4;  % max number of boxes to detect

    %% detect Edge Box bounding box proposals (see edgeBoxes.m)
    % Process all images.
    all_boxes = {};
    for i=1:length(image_filenames)
        im = imread(image_filenames{i});
        bbs=edgeBoxes(im,model,opts);
        all_boxes{i} = double(bbs(:, 1:4));
    end

    if nargin > 1
        save(output_filename, 'all_boxes', '-v7');
    end