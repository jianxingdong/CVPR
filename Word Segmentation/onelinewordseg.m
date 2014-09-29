clc;
clear all;
close all;
% Program for testing RGB2BW image conversion

previous = 0;
startline = [];
endline = [];

img = imread('C:\Users\Spider\Desktop\MATLAB\PatternRecognization\Test_Images\testfile.tif'); %read the image in a variable
original = img;
sizeHW = size(img);  %get the size matrix of the image
sizeH = sizeHW(1);  % get Height - from the sizeHW
sizeW = sizeHW(2);  % get Width - from the sizeHW

img = im2bw(img, 0.60);
img = ~(img);
img = bwareaopen(img, 10);

%imshow(img)

for colindex = 2:sizeH
    if ((sum(img(colindex,:)')== 0) && (previous == 1)) % blank line
        previous = 0;
        endline = [endline colindex];
        original(colindex,:) = zeros(1,sizeW);
    elseif (sum(img(colindex,:)') ~= 0) && (previous == 0) %got some letters
        previous = 1;
        startline = [startline colindex-1];
        original(colindex-1,:) = zeros(1,sizeW);
    end
end

imshow(img)
startline
endline
inlsum = 0;
inlncol = [];

for col = 1:sizeW
    for inln = (startline(1))+(1:endline(1)-1)
        inlsum = inlsum + img(inln,col);
    end
    inlncol = [inlncol inlsum];
    inlsum = 0;
end

inlncol