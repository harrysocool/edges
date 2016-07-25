function boxes = edge_detector_demo(image_filepath)
    addpath('private');
    addpath('models');
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
    im = imread(image_filepath);
    bbs=edgeBoxes(im,model,opts);
    boxes = double(bbs(:, 1:4));
    