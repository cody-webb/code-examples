%%

clear; close all; clc; 
  %%
fprintf("Loading data...\n");

% Loads the data from the two .mat files. 
data_mtx = load("data_mtx.mat");
data_mtx = data_mtx.data_mtx;
surv_cell_sort = load("surv_cell_sort.mat");
surv_cell_sort = surv_cell_sort.surv_cell_sort;
surv_cell_sort = surv_cell_sort(:, 1);

%% 
fprintf("Slight modification to edge images...\n");

data_mtx2 = zeros(750000, length(surv_cell_sort)); % The colored images
data_mtx3 = zeros(250000, length(surv_cell_sort)); % The edge images. 

% for ii = 1:length(surv_cell_sort)
%     img1 = imresize(data_mtx(:,:,ii, 1), [500 500]);
%     img2 = imresize(data_mtx(:,:,ii, 2), [500 500]);
%     img3 = imresize(data_mtx(:,:,ii, 3), [500 500]);
%     
%     data_mtx2(1:250000, ii, 1) = reshape(img1, [250000 1]);
%     data_mtx2(250001:500000, ii, 2) = reshape(img2, [250000 1]);
%     data_mtx2(500001:750000, ii, 3) = reshape(img3, [250000 1]);
% end

% Fills the holes in the edge images and then puts them into data_mtx3. 
SE = strel('square', 3);
for ii = 1:length(surv_cell_sort)
    x = data_mtx(:,:,ii, 4);
    x = uint8(x);
    x = imresize(x, [500 500]);
    x = imclose(x,SE);
    x = imfill(x,4);
    x = double(x);
    data_mtx3(:,ii) = reshape(x, [250000 1]);
end

fail = 0;

fprintf("Taking samples of images...\n");
% Takes a random 100x100 sample from an image, and if it has less than 30%
% black space, puts it into data_mtx2 in the appropriate spot. Repeats the
% process until 25 random 100x100 slices have been found. 
for ii = 1:length(surv_cell_sort)
    i1 = data_mtx(:,:,ii, 1);
    i2 = data_mtx(:,:,ii, 2);
    i3 = data_mtx(:,:,ii, 3);
    %i4 = data_mtx(:,:,ii, 4);
    
    N = 0;
    
    while N < 25
        c1 = randi([1 950], 1, 1);
        c2 = randi([1 950], 1, 1);
        
        img = i1(c1:c1+99, c2:c2+99);
      
        black = 0;
        for row = 1:100
            for col = 1:100
                if img(row, col) == 0
                    black = black + 1;
                end
            end
        end
        
        if black > 2500
            fail = fail + 1;
        else
            im1 = i1(c1:c1+99, c2:c2+99);
            im2 = i2(c1:c1+99, c2:c2+99);
            im3 = i3(c1:c1+99, c2:c2+99);
            
            data_mtx2(N*10000+1: N*10000+ 10000, ii, 1) = reshape(im1, [10000, 1]);
            data_mtx2(250000+ N*10000+1: 250000+ N*10000+ 10000, ii, 1) = reshape(im2, [10000, 1]);
            data_mtx2(500000+N*10000+1: 500000+ N*10000+ 10000, ii, 1) = reshape(im3, [10000, 1]);
            
            N = N + 1;
        end  
    end
end

%% Get rid of all datapoints that have NaN. 

fprintf("Getting rid of datapoints with no data...\n");

num_ims = length(surv_cell_sort);
wrong = 0;

for ii = 1:num_ims
    % If the value is not 0 or 1, then it has to be NaN. 
    t1 = surv_cell_sort(ii, 1) == 0;
    t2 = surv_cell_sort(ii, 1) == 1;
    if ~(t1 | t2)
        wrong = wrong + 1;
        gone(wrong, 1) = ii;
    end
end
% Makes it so I don't have to worry about affecting the order of things. 
gone = sort(gone, 'descend'); 

% Deletes the appropriate columns. 
for ii = 1:length(gone)
    data_mtx2(:, gone(ii), :) = [];
    data_mtx3(:, gone(ii)) = [];
    surv_cell_sort(gone(ii)) = [];
end
%% Split training and testing

fprintf("Creating testing and training sets...\n");

num_ims = length(surv_cell_sort);
rand_vec = randperm(num_ims);
M = round(0.8 * num_ims);

% Training data that is from the colored images. 
x_train1 = data_mtx2(:, rand_vec(1:M));
x_test1 = data_mtx2(:, rand_vec(M+1:end));

% Training data that is from the edge images. 
x_train2 = data_mtx3(:, rand_vec(1:M));
x_test2 = data_mtx3(:, rand_vec(M+1:end));

y_train = surv_cell_sort(rand_vec(1:M));
y_test = surv_cell_sort(rand_vec(M+1:end));

% Since mnr needs 1-2 rather than 0-1, created own category. 
y_train_mnr = y_train + ones(length(y_train), 1);
y_test_mnr = y_test + ones(length(y_test), 1);

%% PCA
fprintf("PCA-ing the data...\n");

% PCA for the colored images
[evectors_train1, ~, ~] = pca(x_train1');
[evectors_test1, ~, ~] = pca(x_test1');

num_eigenvalues = 15; % Found through trial and error.
evectors_train1 = evectors_train1(:, 5:num_eigenvalues);
evectors_test1 = evectors_test1(:, 5:num_eigenvalues);

mean_train1 = mean(x_train1, 2);
shifted_images_train1 = x_train1 - repmat(mean_train1, 1, M);
mean_test1 = mean(x_test1, 2);
shifted_images_test1 = x_test1 - repmat(mean_test1, 1, num_ims - M);

features_train1 = evectors_train1' * shifted_images_train1;
features_test1 = evectors_test1' * shifted_images_test1;

% PCA for the structural images. 
[evectors_train2, ~, ~] = pca(x_train2');
[evectors_test2, ~, ~] = pca(x_test2');

num_eigenvalues = 15; % Found through trial and error. 
evectors_train2 = evectors_train2(:, 5:num_eigenvalues);
evectors_test2 = evectors_test2(:, 5:num_eigenvalues);

mean_train2 = mean(x_train2, 2);
shifted_images_train2 = x_train2 - repmat(mean_train2, 1, M);
mean_test2 = mean(x_test2, 2);
shifted_images_test2 = x_test2 - repmat(mean_test2, 1, num_ims - M);

features_train2 = evectors_train2' * shifted_images_train2;
features_test2 = evectors_test2' * shifted_images_test2;

%% Creating the model 

fprintf("Creating models...\n");
beta1 = fitcsvm(features_train1', y_train); % SVM colored images.
[x_pred1, x_prob1] = predict(beta1, features_test1');

% beta2 = fitcknn(features_train1', y_train, "NumNeighbors", 3); %knn colored images
% [x_pred2, x_prob2] = predict(beta2, features_test1');

% beta3 = fitcsvm(features_train2', y_train); % svm edge images
% [x_pred3, x_prob3] = predict(beta2, features_test2');

% beta4 = mnrfit(features_train2', y_train_mnr); %mnr edge images
% x_prob4 = mnrval(beta4, features_test2');
% [~, x_pred4] = max(x_prob4');
% x_pred4 = x_pred4 - ones(1, length(x_pred4));
% x_pred4 = x_pred4';

% beta5 = fitctree(features_train1', y_train); %decision tree colored images
% [~,x_prob5] = predict(beta5, features_test1');
% [~,x_pred5] = max(x_prob5');
% x_pred5 = x_pred5' - ones(length(x_pred5), 1);

beta6 = fitctree(features_train2', y_train); %Decision tree edge images. 
[~,x_prob6] = predict(beta6, features_test2');
[~,x_pred6] = max(x_prob6');
x_pred6 = x_pred6'- ones(length(x_pred6), 1);

svm_pred = zeros(size(y_test,1),1);

tie = 0;
for ii=1:size(y_test,1)
    
    total = x_pred1 + x_pred6; % This combination seemed to produce the best results. 
    
    if total == 2
        svm_pred(ii, 1) = 1;
    elseif total == 0
        svm_pred(ii, 1) = 0;
    else
        if max(x_prob1(ii,:)) > 2
            svm_pred(ii, 1) = x_pred1(ii, 1);
        elseif max(x_prob6(ii,:)) > 0.95
            svm_pred(ii, 1) = x_pred6(ii, 1);
        else
            svm_pred(ii, 1) = 0;
        end    
    end
    
%     total = 0.3* x_pred1(ii, 1) + 0.2* x_pred2(ii,1) + ... 
%         0.1 * x_pred4(ii, 1) + 0.4 * x_pred6(ii, 1);
%     
%     if total > 0.5
%         svm_pred(ii, 1) = 1;
%     elseif total <= 0.5
%         svm_pred(ii, 1) = 0;
%     else 
%         tie = tie + 1;
%         if abs(x_prob6(ii,1) - 0.5) > 0.4
%             svm_pred(ii, 1) = x_pred6(ii,1); 
%         elseif abs(x_prob1(ii, 1)) > 1.8
%             svm_pred(ii, 1) = x_pred1(ii, 1);
%         elseif abs(x_prob2(ii, 1) - 0.5) > 0.4
%             svm_pred(ii, 1) = x_pred2(ii,1);
%         elseif abs(x_prob4(ii, 1) - 0.5) > 0.4
%             svm_pred(ii, 1) = x_pred4(ii, 1);
%         else 
%             svm_pred(ii, 1) = 0;
%         end    
%     end
end

%% Evaluating model performance

%svm_pred = x_pred1;

% Evaluates the model performance. 
fprintf('Evaluating model performance...\n');
cp = classperf(y_test);
cp = classperf(cp, svm_pred);

[X, Y, ~, AUC] = perfcurve(y_test, svm_pred, 1);

fprintf('Model AUC = %0.3f\n', AUC); % model AUC
modelAccuracy = cp.CorrectRate; % Model accuracy 
fprintf('Model accuracy = %0.3f\n', modelAccuracy); 
modelSensitivity = cp.Sensitivity; % Model sensitivity 
fprintf('Model sensitivity = %0.3f\n', modelSensitivity);
modelSpecificity = cp.Specificity; % Model specificity 
fprintf('Model specificity = %0.3f\n', modelSpecificity);

% Plotting the ROC curve 
figure; plot(X, Y,'b-','LineWidth',2); 
title('ROC curve for logistic regression','FontSize',14,'FontWeight','bold');
xlabel('False positive rate','FontSize',14,'FontWeight','bold'); 
ylabel('True positive rate','FontSize',14,'FontWeight','bold'); 
set(gca,'FontWeight','bold','FontSize',14,'LineWidth',2);