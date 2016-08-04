clear
clc
im_path= 'DatabaseEars/';
gt_path= 'boundaries.csv';
im_path_list = dir(im_path);
gt_list = csvread(gt_path, 1, 0);
% %%
% 
% for index = 4:length(im_path_list)
%     I = imread([im_path im_path_list(index).name]);
%     gt = gt_list(index-3, :);
%     % gt format of the southampton database is [Y1 Y2 X1 X2] start from 1
%     X1 = gt(3)-5; 
%     X2 = gt(4)+5;
%     Y1 = gt(1)-5;
%     Y2 = gt(2)+5;
%     W = X2-X1;
%     H = Y2-Y1;
%     I1 = insertShape(I, 'Rectangle', [X1 Y1 W H], 'LineWidth', 1);
%     imshow(I1, 'border', 'tight' ); %//show your image
%     pause
% end
% 
% 
% %% otus segmentation
% 
% for index = 4:length(im_path_list)
%     I = imread([im_path im_path_list(index).name]);
%     I = rgb2gray(I);
%     background = imopen(I,strel('disk',50));
%     I2 = I - background;
%     I3 = imadjust(I2);
%     bw = imbinarize(I3);
%     bw = bwareaopen(bw, 50);
%     %
%     cc = bwconncomp(bw, 26);
%     labeled = labelmatrix(cc);
%     RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
%     imshow(RGB_label)
%     display(max(max(labeled)))
%     pause
% end
%% kmeans segmentation
scale_index = 0.4;
for index = 3:length(im_path_list)
    I = imread([im_path im_path_list(index).name]);
    % transform the rgb2lab color space
%     cform = makecform('srgb2lab');
%     lab_he = applycform(I,cform);
%     ab = double(lab_he(:,:,2:3));
    nrows = size(I,1);
    ncols = size(I,2);

    ab = reshape(double(I),nrows*ncols,3);

    pixel_labels1 = ones(nrows,ncols);
    nColors = 3;
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                          'Replicates',3);  
    pixel_labels2 = reshape(cluster_idx,nrows,ncols);
    
    gt = gt_list(index-2, :);
    % gt format of the southampton database is [Y1 Y2 X1 X2] start from 1
    X1 = gt(3); 
    X2 = gt(4);
    Y1 = gt(1);
    Y2 = gt(2);
    if (X2+5>=600 || Y2+5>=800)
        X2 = 595;
        Y2 = 795;
        disp('error')
    end
    pixel_labels(Y1:Y2,X1:X2) = 1+1;
    temp_gt = zeros(800,600);
    temp_gt(Y1-5:Y2+5,X1-5:X2+5) = 1;
    temp_gt = logical(temp_gt);
    
    [~, ext, ~] = fileparts(im_path_list(index).name);
%     display(ext);
    groundTruth = {};
    field1 = 'Segmentation';
    value1 = uint16(resizem(pixel_labels1, scale_index));
    value2 = uint16(resizem(pixel_labels2, scale_index));
    field2 = 'Boundaries';
    value = resizem(temp_gt, scale_index);
    
%     imagesc(value1)
%     figure(2)
%     imagesc(double(value1).*value2)

    gt_struct1 = struct(field1,value1,field2,value);
    groundTruth{1,1} = gt_struct1;
    gt_struct2 = struct(field1,value2,field2,value);
    groundTruth{1,2} = gt_struct2;
    
% %         demonstration for inspection
%     RGB_label = label2rgb(resizem(pixel_labels, 0.5), @spring, 'c', 'shuffle');
%     imshow(RGB_label)
%     pause
%     close
    
    save(['EAR/data/groundTruth/train/' ext '.mat'], 'groundTruth');
%     I2 = imresize(I, scale_index);
%     imwrite(I2, ['EAR/data/images/train/' ext '.jpg']);
    disp(index)
end

run edgesDemo.m
