function boxes = edge_detector_demo(args)
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
    model=load('models/forest/modelBsds'); model=model.model;
    model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

    %% set up opts for edgeBoxes (see edgeBoxes.m)
    opts = edgeBoxes;
    opts.alpha = .35;     % step size of sliding window search
    opts.beta  = .75;     % nms threshold for object proposals
    opts.minScore = .01;  % min score of boxes to detect
    opts.maxBoxes = 1e4;  % max number of boxes to detect

    %% detect Edge Box bounding box proposals (see edgeBoxes.m)
    
    image_index = args.image_index;
    demo_index = args.demo_index;
    % demo_index == 0, for iamge demo
    if demo_index == 0
        path = '/harrysocool/Github/fast-rcnn/ear_recognition/data_file/image_index_list.csv';
        if ismac
            image_filenames = csvread('/Users' + path, image_index,0);
        elseif isunix
            image_filenames = csvread('/home' + path, image_index,0);
        end
        im = imread(image_filenames);
        bbs=edgeBoxes(im,model,opts);
        boxes = double(bbs(:, 1:4));
    % demo_index == 1, for vedio demo
    elseif demo_index == 1
                path = '/harrysocool/Github/fast-rcnn/ear_recognition/data_file/video_frame.jpg';
        if ismac
            image_filenames = '/Users' + path;
        elseif isunix
            image_filenames = '/home' + path;
        end
        im = imread(image_filenames);
        bbs=edgeBoxes(im,model,opts);
        boxes = double(bbs(:, 1:4));
    end
    