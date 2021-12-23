%% Mini Project 2: Scale-space blob detection
%% Up Sampling
%%
clear all; clc; close all;


%% import image 
%% 

% read the image

%img = imread('butterfly.jpg'); 
%img = imread('einstein.jpg'); 
%img = imread('fishes.jpg'); 
%img = imread('sunflowers.jpg');

%img = imread('Afsha-2020.jpg');
%img = imread('good will hunting.jpg');
%img = imread('Emad-Meteb-2014.jpg');
img = imread('ramos_2014.jpg');
figure(1)
imshow(img)


% convert it to gray
img = rgb2gray(img);

% convert it to double
img = im2double(img);  %This means that we have not lost precision


%% Build the laplacian of Gaussian filter scale space.
%%

% starting with some initial scale and going for n iterations
% 1. Filter image with scale-normalized Laplacian at current scale.
% 2. Save square of Laplacian response for current level of scale space.
% 3. Increase scale by a factor k

% initialization
[h, w] = size(img);                % Image size
k = 1.4;                          % Increasing factor of k
levels = 8;                       % Define number of iterations
sigma = 2;
scale_space = zeros(h, w, levels); % empty 3D matrix


% Perform LoG filter to image for several levels
tic
for i = 1:levels
    % Generate a Laplacian of Gaussian filter 
    % we use odd filter to make the filter mask have a centre
    LoG = fspecial('log', 2 * ceil(3 * sigma) + 1, sigma);
    % Filter the img with LoG
    scale_space(:,:,i) = (imfilter(img, LoG, 'replicate', 'same').*(sigma^2)).^2;
    % Increase scale by a factor k
    sigma = sigma * k;
    
end
toc

%% Perform nonmaximum suppression in scale space.
%%
suppressed_space = zeros(h,w,levels);
for i = 1:levels
    % replaces each element by the orderth element in the sorted set of 
    % neighbors specified by the nonzero elements in ones(3).
    suppressed_space(:,:,i) = ordfilt2(scale_space(:,:,i),9,ones(3)); 
end

maxima_space = max(suppressed_space, [], 3);
survive_space = zeros(h,w,levels);
for i = 1:levels
    survive_space(:,:,i) = (maxima_space == scale_space(:,:,i)).* img;

end


% Find all the coordinates and corresponding sigma
threshold = 0.3;       
initial_sigma = 2;   

for num = 1:levels
    % Find index and corresponding radius
    [c,r] = find(survive_space(:,:,num) >= threshold);
    rad = sqrt(2) * initial_sigma * k^num;
    if num == 1
        cx = c;
        cy = r;
        radius = rad .* ones(size(r,1), 1);
    else
        cx = [cx; c];
        cy = [cy; r];
        radius = [radius; rad .* ones(size(r,1), 1)];
    end
end
show_all_circles(img, cy, cx, radius, threshold, initial_sigma, k);
