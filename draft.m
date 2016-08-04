% Demo for Edge Boxes (please see readme.txt first).

%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load('models/forest/modelEAR0.4_2.mat'); 
model=model.model;
model.opts.multiscale=1; 
model.opts.sharpen=2; 
model.opts.nThreads=4;
model.opts.nms=0;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .55;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
im_path= 'DatabaseEars/';
gt_path= 'boundaries.csv';
im_path_list = dir(im_path);
gt_list = csvread(gt_path, 1, 0);
for index = 3:length(im_path_list)
    I = imread([im_path im_path_list(index).name]);
    tic, bbs=edgeBoxes(I,model,opts); toc
    gt = gt_list(index-2, :);
    % gt format of the southampton database is [Y1 Y2 X1 X2] start from 1
    X1 = gt(3);
    X2 = gt(4);
    Y1 = gt(1);
    Y2 = gt(2);
    W = X2-X1;
    H = Y2-Y1;
    if (X2+5>=600 || Y2+5>=800)
        X2 = 595;
        Y2 = 795;
        disp('error')
    end
    [gtRes,dtRes]=bbGt('evalRes',[X1, Y1, W, H, 0],double(bbs),.8);
    figure(1); 
    bbGt('showRes',I,gtRes,dtRes(dtRes(:,5)>0.09,:));
    title('green=matched gt  red=missed gt  dashed-green=matched detect');
    pause
    close
end