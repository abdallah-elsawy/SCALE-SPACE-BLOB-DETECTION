%% Mini Project 2: Scale-space blob detection
%% Differences of Gaussian pyramid
%%
clear all; clc; close all;

%% import image 
%% 

% read the image

img = imread('butterfly.jpg'); 
%img = imread('einstein.jpg'); 
%img = imread('fishes.jpg'); 
%img = imread('sunflowers.jpg');
%img = imread('Afsha-2020.jpg');
%img = imread('good will hunting.jpg');
%img = imread('Emad-Meteb-2014.jpg');
%img = imread('ramos_2014.jpg');
figure(1)
imshow(img)

% convert it to gray
img = rgb2gray(img);

% convert it to double
img = im2double(img);  %This means that we have not lost precision

%%
% initialization
[h, w] = size(img);
threshold = 0.9;
k = sqrt(2);
levels = 8;
octave = 3;
initial_sigma = 2;
sigma = 2;


tic
% First octave, original image size
scale_space_temp = zeros(h, w ,levels);
img_octave_1 = img;
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = (imfilter(img_octave_1, filter, 'same', 'replicate')).^2;
    scale_space_temp(:,:,i) = filter_response;
    sigma = sigma * k;
end

scale_space_1 = zeros(h, w, levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_1(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end

sigma = initial_sigma * k^2;
% Second octave, original image size
img_octave_2 = imresize(img, 0.5);
scale_space_temp = zeros(size(img_octave_2, 1), size(img_octave_2, 2) ,levels);
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = (imfilter(img_octave_2, filter, 'same', 'replicate')).^2;
    scale_space_temp(:,:,i) = (sigma^2) * filter_response;
    sigma = sigma * k;
end

scale_space_2 = zeros(size(img_octave_2, 1), size(img_octave_2, 2) ,levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_2(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end



sigma = initial_sigma * k^4;
% Third octave, original image size
img_octave_3 = imresize(img_octave_2, 0.5);
scale_space_temp = zeros(size(img_octave_3, 1), size(img_octave_3, 2) ,levels);
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = (imfilter(img_octave_3, filter, 'same', 'replicate')).^2;
    scale_space_temp(:,:,i) = (sigma^2) * filter_response;
    sigma = sigma * k;
end

scale_space_3 = zeros(size(img_octave_3, 1), size(img_octave_3, 2) ,levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_3(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end
toc


% Scale_space resize to oringinal image
for i = 1:size(scale_space_2, 3)
    temp2 = imresize(scale_space_2(:,:,i), [size(scale_space_1,1),size(scale_space_1,2)]);
end

for i = 1:size(scale_space_3, 3)
    temp3 = imresize(scale_space_3(:,:,i), [size(scale_space_1,1),size(scale_space_1,2)]);
end


diffSpace = cat(3, scale_space_1, temp2, temp3);


for i = 1:size(diffSpace,3)
    ord = ordfilt2(diffSpace(:,:,i), 9, ones(3));
    diffSpace(:,:,i) = diffSpace(:,:,i) .* (ord == diffSpace(:,:,i));
    %Apply threshold in each 2D slice.
    temp = diffSpace(:,:,i);
    temp(temp < threshold) = 0;
    diffSpace(:,:,i) = temp;
end


% % Perform Nonmaxima Suppression in octaves
survival_space = imregionalmax(diffSpace,26);



cx = [];
cy = [];
rads = [];
for i = 1:size(survival_space,3)
    [c, r] = find(survival_space(:,:,i));
    
    if i >= 1 && i <= 3
        rad = sqrt(2)^(i-1) * initial_sigma  .* ones(size(r,1),1);
        cy = [cy;r];
        cx = [cx;c];
        rads = [rads;rad];
        
    elseif i > 3 && i <= 6
        rad = sqrt(2)^(i-4) * initial_sigma * sqrt(2)  .* ones(size(r,1),1);
        cy = [cy;r];
        cx = [cx;c];
        rads = [rads;rad];
    else
        rad = sqrt(2)^(i-7) * initial_sigma * 2  .* ones(size(r,1),1);
        cy = [cy;r];
        cx = [cx;c];
        rads = [rads;rad];
    end
end
show_all_circles(img, cy, cx, rads, threshold, initial_sigma, k);





