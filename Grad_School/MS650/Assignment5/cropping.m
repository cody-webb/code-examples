clear all; close all; clc;

%% Get directory and files

path = '/Users/codywebb/Documents/MATLAB/Example_Images';      % set path

cd(path)                                                                    % change directory
d = dir('*png');                                                            % list all files with jpg extension in data structure

%% Read data

for ii = 1:length(d)                                                          % for each jpg image file in directory
    file_name = fullfile(path,d(ii).name);                                  % obtain file name and folders
    image = imread(file_name);                                             % read image into MATLAB
    % image = imread('kb1.png');

    %% Convert to LAB color space
    lab_img = rgb2lab(image);
    l_img = lab_img(:,:,1);                                                 % luminosity image
    a_img = lab_img(:,:,2);                                                 % red image
    b_img = lab_img(:,:,3);                                                 % blue image
    thresh = .5*mean(l_img,'all');                                          % set threshold as half mean luminosity
    %figure, imshow(uint8(lab_img(:,:,1))
    
    %% Crop images vertically
    
    dim1 = size(l_img,1); dim2 = size(l_img,2);                             % get dimensions of l_img
    win = 10;                                                               % window of how many pixels to look ahead when determining the border of the object
    
    vert = zeros(dim2,2);                                                   % allocate memory for a two column matrix of all rows that correspond to the top and bottom of the object
    for col = 1:dim2                                                        % for each column in l_image
        T = find(l_img(:,col)<thresh,1,'first');                            % let T be the first row for this column whose pixel has less than the mean luminosity
        
        if dim1-T>win                                                       % if T is greater than win distance from the bottom of the image
            w = win;                                                        % set w to win (look ahead win pixels)
        else
            w = dim1-T;                                                     % if not, set w to the remaining distance to the bottom of the image (look ahead till the end)
        end
            
        if ~isempty(T) && sum(l_img(T:T+w,col)<thresh)>.9*w                 % if T exists AND at least 90% of the next w pixels have less than the mean luminosity
            vert(col,1) = T;                                                % log this value of T in the 1st column of vert
        end    
        
        B = find(l_img(:,col)<thresh,1,'last');                             % let B be the last row for this column whose pixel has less than the mean luminosity 
        
        if B-1>win                                                          % if B is greater than win distance from the top of the image
            w = win;                                                        % set w to win (look behind win pixels)
        else
            w = B-1;                                                        % if not, set w to the remaining distance to the top of the image (look behind till the start)
        end
        
        if ~isempty(B) && sum(l_img(B:-1:B-w,col)<thresh)>.9*w              % if B exists AND at least 90% of the next w pixels have less than the mean luminosity
            vert(col,2) = B;                                                % log this value of B in the 2nd column of vert
        end
    end
    
    top = min(vert(vert(:,1)~=0&vert(:,1)~=1,1));                           % top edge cropping value equals the least non-zero row index stored in the 1st column vert
    bottom = max(vert(:,2));                                                % bottom edge cropping value equals the greatest row index stored in the 2nd column of vert
    
    
    % Crop images horizontally
    
    horz = zeros(dim1,2);                                                   % allocate memory for a two column matrix of all columns that correspond to the left and right borders of the object
    for row = 1:dim1                                                        % for each row in l_image
        L = find(l_img(row,:)<thresh,1,'first');                            % let L be the first column for this row whose pixel has less than the mean luminosity
        
        if dim2-L>win                                                       % if L is greater than win distance from the right edge of the image 
            w = win;                                                        % set w to win (look ahead win pixels)
        else
            w = dim2-L;                                                     % if not, set w to the remaining distance to the right edge of the image (look ahead till the end)
        end
        
        if ~isempty(L) && sum(l_img(row,L:L+w)<thresh)>.9*w                 % if L exists AND at least 90% of the next w pixels have less than the mean luminosity
            horz(row,1) = L;                                                % log this value of L in the 1st column of horz
        end
        
        R = find(l_img(row,:)<thresh,1,'last');                             % let R be the last column for this row whose pixel has less than the mean luminosity
        
        if R-1>win                                                          % if R is greater than win distance from the left of the image
            w = win;                                                        % set w to win (look behind win pixels)
        else
            w = R-1;                                                        % if not, set w to the remaining distance to the right edge of the image (look behind till the start)
        end
        
        if ~isempty(R) && sum(l_img(row,R:-1:R-w)<thresh)>.9*w              % if R exists AND at least 90% of the next w pixels have less than the mean luminosity
            horz(row,2) = R;                                                % log this value of R in the 2nd column of horz
        end
    end
    
    left = min(horz(horz(:,1)~=0,1));                                       % left edge cropping value equals the least non-zero column index stored in 1st column of horz
    right = max(horz(:,2));                                                 % right edge cropping value equals the greatest column index stored in 2nd column of horz
    
    figure, imshow(image)
    figure, imshow(image(top:bottom,left:right,:))
    
    
    %%
%     figure, imshow(image(:,:,1));
%     figure, imshow(image(:,:,2));
%     figure, imshow(image(:,:,3));
end
    
