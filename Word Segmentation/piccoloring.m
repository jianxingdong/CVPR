clc;clear all;close all;
% to test the coloring of image

img = imread('C:\Users\Spider\Desktop\MATLAB\PatternRecognization\Test_Images\2.tif');
sizeHW = size(img);

coling = zeros(sizeHW(1),sizeHW(2),3);

rgbImage = cat(3, img, img, img);

rgbImage(:,:,2) = rgbImage(:,:,2) + 50;
imshow(rgbImage)