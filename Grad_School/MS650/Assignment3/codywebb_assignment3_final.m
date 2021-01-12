clear; clc; close all;

%% 

features = readtable('features.csv');
output = readtable('output.csv');

x1 = features.GeneId;
x2 = features.H3K4me3;
x3 = features.H3K4me1;
x4 = features.H3K36me3;
x5 = features.H3K9me3;
x6 = features.H3K27me3;

y1 = output.Prediction;

data = zeros(length(y1), 6);

for ii = 1:length(y1)
    start = (ii - 1) * 100 + 1;
    data(ii, 1) = sum(x2(start:start+99));
    data(ii, 2) = sum(x3(start:start+99));
    data(ii, 3) = sum(x4(start:start+99));
    data(ii, 4) = sum(x5(start:start+99));
    data(ii, 5) = sum(x6(start:start+99));
    data(ii, 6) = y1(ii) + 1;
end

%%

randVec = randperm(length(y1));

M = 11000;

x_train = data(randVec(1:M), 1:5);
y_train = data(randVec(1:M), 6);
x_test = data(randVec(M+1:end), 1:5);
y_test = data(randVec(M+1:end), 6);

%% 

best_beta = zeros(6,1);
best_auc = 0;
best_y_logit_pred = zeros(1, length(y_test));

for n=1:5
    beta = mnrfit(x_train, y_train); 
    y_logit_prob = mnrval(beta, x_test);
    [~, y_logit_pred] = max(y_logit_prob');
    
    [X, Y, ~, AUC] = perfcurve(y_test, y_logit_prob(:,1), 1);
    if AUC > best_auc
        best_beta = beta;
        best_auc = AUC;
        best_y_logit_pred = y_logit_pred;
    end
    
end

cp = classperf(y_test);
cp = classperf(cp, y_logit_pred);
modelAccuracy = cp.CorrectRate; % Model accuracy 
fprintf('For the original data set, the accuracy, sensitivity, and specificity are: \n')
fprintf('Model accuracy = %0.3f\n', modelAccuracy); 
modelSensitivity = cp.Sensitivity; % Model sensitivity 
fprintf('Model sensitivity = %0.3f\n', modelSensitivity);
modelSpecificity = cp.Specificity; % Model specificity 
fprintf('Model specificity = %0.3f\n', modelSpecificity);
fprintf('Best AUC value =  %0.3f\n', best_auc);

tot_auc = 0;

for iteration = 1:25
    
    randVec1 = randperm(length(y1));

    M2 = 11000;

    x_test1 = data(randVec1(M2+1:end), 1:5);
    y_test1 = data(randVec1(M2+1:end), 6);
    
    y_logit_prob1 = mnrval(best_beta, x_test1);
    
    [X, Y, ~, AUC] = perfcurve(y_test1, y_logit_prob1(:,1), 1);
    
    tot_auc = tot_auc + AUC;
    
end

tot_auc = tot_auc / 25;

fprintf("\n\n\n");
fprintf("The average AUC of the best model is %0.3f\n", tot_auc);


   

% beta = mnrfit(x_train, y_train); 
% y_logit_prob = mnrval(beta, x_test);
% [~, y_logit_pred] = max(y_logit_prob');
