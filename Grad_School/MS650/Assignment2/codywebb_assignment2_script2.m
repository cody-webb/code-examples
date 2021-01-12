%%

clear; close all; clc

%% Reading Data and creating the appropriate matrices

% Attempts at finding other ways of improving the prediction and the code
% used are at the bottom of the script. 

data = readtable('dataset3.csv');

% The reason that Creatinine is the only factor used for clustering is that
% its clusters were the closest to the actual egfr clusters. More
% information is in the notes section down at the bottom of this script. 

X = table2array(data(:, 11));

egfr = table2array(data(:, 12));

%% Creating a binary vector for egfr.

% The ith value of egfr_bin will be 1 if the ith person in the egfr table 
% has kidney failure and 0 if they do not. 

egfr_bin = zeros(length(egfr), 1);

for i=1:length(egfr) 
    if egfr(i) <= 15
        egfr_bin(i) = 1;
    end
end

%% k-means Section

k = 2;

[idx, C] = kmeans (X, k, 'Distance', 'sqeuclidean');

%% Comparing idx to eGFR data

correct = 0;
total = length(idx);

for i=1:length(idx)
    % Testing to see if the clusters correspond to the clusters that exist
    % for the eGFR data. 
    if idx(i) == egfr_bin(i) + 1
        correct = correct + 1;
    end
end

% If this percentage is either close to 1 (meaning that the clusters are
% matched to the correct group) or close to 0 (meaning clusters are matched
% to opposite group, then we know the model is good.
perc = correct / total;

% Looks better this way and don't have to worry about whether matching or
% not. 
if perc < 0.5
    perc = 1 - perc;
end

% Based on manual comparison, I can see that the group with the higher
% Creatinine values is more likely to have an egfr < 15 than those with
% lower values. If a patient has a Creatinine value that is larger than the 
% largest centroid, then the group that that patient belongs to is
% determined to be the group with kidney failure. That is what the code
% below determines. 

group_1_kidney_failure = 0; 
group_1 = X(idx == 1);

for i=1:length(group_1)
    if group_1(i) > max(C(1), C(2))
        group_1_kidney_failure = 1;
    end 
end

if group_1_kidney_failure
    disp("Group 1 is the clustered group with kidney failure")
else
    disp("Group 2 is the clustered group with kidney failure")
end
%% Data visualization

bar(X(idx==2), 'r')
hold on;
bar(X(idx==1), 'b')
ylabel("Creatine")


%% Hierarchical clustering Section

Y = pdist(X);

Z = linkage(Y);

dendrogram(Z, 50);

coph = cophenet(Z, Y);

% No heat map is needed in this analysis since I'm only using one column.
% 
%cg = clustergram(X, 'standardize', 'Column');

% The dendrogram and heat map when all variables were used showed that 
% Creatinine and BUN were highly related to each other, as well as WBC.
% However, as you can see in the notes section, when those were combined,
% they did not improve the results of just Creatinine on its own. 

%% Notes

% Percent in the correct cluster with:
%
% All variables: 60%. All variables (normalized): 78%
% Just column 5: 64%. Column 6: 64%. Column 7: 50%. Column 8: 74%
% Column 9: 52%. Column 10: 80%. Column 11: 92%
% Columns 10 and 11 (normalized): 86%
% Columns 8, 10, and 11 (normalized): 74%
% Columns 8, 10, and 11 (normalized) (Without patient 6): 85.71%

% This is why I just picked solely colemn 11 (creatinine) as my indicator
% for low egfr. 

%% Creating the X-matrices for various combinations of variables:

% Using all of the variables via k-means:

% X1 = normalize(table2array(data(:,5)));
% X2 = normalize(table2array(data(:,6)));
% X3 = normalize(table2array(data(:,7)));
% X4 = normalize(table2array(data(:,8)));
% X5 = normalize(table2array(data(:,9)));
% X6 = normalize(table2array(data(:,10)));
% X7 = normalize(table2array(data(:,11)));
% 
% X = [X1 X2 X3 X4 X5 X6 X7];

%_____________________________

%Using just Creatinine and BUN:
% (since they were the two best individual indicators)

% X1 = normalize(table2array(data(:,10)));
% X2 = normalize(table2array(data(:,11)));
% 
% X = [X1 X2];

% ________________
% Using Creatinine, BUN, and WBC, excluding Patient 6:
% (Patient 6 was excluded since their WBC was throwing off the data)

% X1 = normalize(table2array(data(:,8)));
% X2 = normalize(table2array(data(:,10)));
% X3 = normalize(table2array(data(:,11)));

% X1 = table2array(data(:,8));
% X2 = table2array(data(:,10));
% X3 = table2array(data(:,11));
% 
% X1(6,:) = [];
% X2(6,:) = [];
% X3(6,:) = [];

% egfr(6,:) = [];
% 
% X1 = normalize(X1);
% X2 = normalize(X2);
% X3 = normalize(X3);
% 
% X = [X1 X2 X3];