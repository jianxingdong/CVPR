clc;
clear all;
close all;
% draw line on image

image = imread('testfile.tif');
sizeHW = size(image);
sizeW = sizeHW(2);

srow = 25;

image(srow,:) = zeros(1,sizeW);

% for i = 1:sizeW
%     image(srow,i) = 0;
% end

imshow(image)