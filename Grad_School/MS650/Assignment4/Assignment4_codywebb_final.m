%% 
clear; clc; close all;

%% Reading data

% The width/height of the final images. Doing it at 300x300 doesn't
% negatively impact the resulting model by very much and allows for the
% code to execute in less than 5 minutes. 
our_dims = 300;

% Gaussian filter that will be used later. 
filter1 = [-1 -1 -1 -1 -1; -1 2 2 2 -1 ; -1 2 8 2 -1 ; -1 2 2 2 -1; ...
    -1 -1 -1 -1 -1];

fprintf('Reading data for training...\n');
cd('/Users/codywebb/Documents/MATLAB/ChinaSet_AllFiles/CXR_png/');
%cd('/Users/vkola/Google Drive (vkola@bu.edu)/BU/MS650/Datasets/ChinaSet_AllFiles/CXR_png/');

pngFiles1 = dir('*.png');

labels_train = zeros(size(pngFiles1,1),1);

total_pixels = our_dims * our_dims;

% Total_pixels * 2 since I'm going to be adding the Gaussian filter results
% to each column later. 
images_train = zeros(total_pixels * 2, size(pngFiles1,1));

%Training data set
for ii=1:size(pngFiles1,1)
    im1 = imread(pngFiles1(ii).name);
    % For whatever reason, reversing the image on the training hat
    % significantly improves the results. 
    im1 = imcomplement(im1);
    im2 = im2double(im1(:,:,1));
    % I resize for cropping to make things go slightly faster. 
    im2 = imresize(im2, [1000 1000]);
    
    dims = size(im2);
    crop_spot = dims(1,1);
    
    % This section crops out the bottom black bars that occasionally show
    % up. 
    for rows = 1:dims(1,1)
        if sum(im2(rows, :)) < .1
            if crop_spot > rows
                crop_spot = rows;
                break;
            end
        end
    end
    
    % Does the cropping and then resizes the image to 500x500 (purely for
    % processing reasons. 
    im2 = im2(1:crop_spot, :);
    im2 = imresize(im2, [our_dims our_dims]);
    % im2_copy = im2;
    
    % End cropping 
    
    %Thresholding happens here. It should reduce some of the noise in the
    %black regions. It used to be two sided, but creating only a lower
    %threshold improved the results. 
    for r = 1:our_dims
        for c = 1:our_dims
            if im2(r, c) < 0.2 % || im2(r,c) > 0.6
                    im2(r,c) = 0;
            end
        end
    end
    
    % End thresholding
 
    images_train(1:total_pixels, ii) = im2(:);
    
    % Gaussian filter should be applied here. Does a Gaussian filter on the
    % image, but then adds those results to the end of the column vector
    % related to our specific image. 
    im3 = conv2(im2, filter1, 'same');
    size_im3 = size(im3);
    the_end = our_dims + (size_im3(1,1) * size_im3(1,2));
    
    images_train(our_dims+1:the_end, ii) = im3(:);
    % End Gaussian filter 
    
    % Creates the labels. 
    if(isempty(strfind(pngFiles1(ii).name,'_0.')))
        labels_train(ii,1) = labels_train(ii,1) + 1;
    end
end

cd('/Users/codywebb/Documents/MATLAB');
%cd('/Users/vkola/Google Drive (vkola@bu.edu)/BU/MS650/Matlab');

fprintf('Reading data for testing...\n');
%cd('/Users/vkola/Google Drive (vkola@bu.edu)/BU/MS650/Datasets/MontgomerySet/CXR_png/');
cd('/Users/codywebb/Documents/MATLAB/MontgomerySet/CXR_png/');

pngFiles2 = dir('*.png');
 
labels_test = zeros(size(pngFiles2,1),1);

images_test = zeros(total_pixels * 2, size(pngFiles2, 1));

% Testing Data Set. The things here are essentially the same as above. 
for ii=1:size(pngFiles2,1)
    im1 = imread(pngFiles2(ii).name);
    im2 = im2double(im1(:,:,1)); % Converts the image to grayscale. 
    im2 = imresize(im2, [1000 1000]);
    
    %Cropping
    dims = size(im2);
    crop_spot = dims(1,1);

    for rows = 1:dims(1,1)
        if sum(im2(rows, :)) < .1
            if crop_spot > rows
                crop_spot = rows;
                break;
            end
        end
    end
    
    im2 = im2(1:crop_spot, :);
    im2 = imresize(im2, [our_dims our_dims]);
    %im2_copy = im2;
    
    %End cropping
    
    % Thresholding 
    for r = 1:our_dims
        for c = 1:our_dims
            if im2(r, c) < 0.2 % || im2(r,c) > 0.6
                    im2(r,c) = 0;
            end
        end
    end
    % End Thresholding
    
    images_test(1:total_pixels, ii) = im2(:);
    
    % Gaussian filter 
    im3 = conv2(im2, filter1, 'same');
    size_im3 = size(im3);
    the_end = our_dims + (size_im3(1,1) * size_im3(1,2));
    
    images_test(our_dims+1:the_end, ii) = im3(:);
    % End Gaussian filter
    
    % Label vector creation 
    if(isempty(strfind(pngFiles2(ii).name,'_0.')))
        labels_test(ii,1) = labels_test(ii,1) + 1;
    end
end

cd('/Users/codywebb/Documents/MATLAB');
%cd('/Users/vkola/Google Drive (vkola@bu.edu)/BU/MS650/Matlab');

%% Modeling

fprintf("Creating model...\n")

% Creates the model
beta = fitcsvm(images_train', labels_train);
[svm_pred, svm_prob] = predict(beta, images_test');


% Evaluates the model performance. 
fprintf('Evaluating model performance...\n');
cp = classperf(labels_test);
cp = classperf(cp, svm_pred);

[X, Y, ~, AUC] = perfcurve(labels_test, svm_pred, 1);

modelAccuracy = cp.CorrectRate; % Model accuracy 
fprintf('Model accuracy = %0.3f\n\n', modelAccuracy); 
modelSensitivity = cp.Sensitivity; % Model sensitivity 
fprintf('Model sensitivity = %0.3f\n', modelSensitivity);
modelSpecificity = cp.Specificity; % Model specificity 
fprintf('Model specificity = %0.3f\n', modelSpecificity);
fprintf('Model AUC = %0.3f\n', AUC); % model AUC
% Plotting the ROC curve 
% figure; plot(X, Y,'b-','LineWidth',2); 
% title('ROC curve for logistic regression','FontSize',14,'FontWeight','bold');
% xlabel('False positive rate','FontSize',14,'FontWeight','bold'); 
% ylabel('True positive rate','FontSize',14,'FontWeight','bold'); 
% set(gca,'FontWeight','bold','FontSize',14,'LineWidth',2);
