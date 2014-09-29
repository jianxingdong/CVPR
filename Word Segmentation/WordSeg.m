clc;
clear all;
close all;
% Program for testing RGB2BW image conversion

previous = 0;
startline = [];
endline = [];

img = imread('C:\Users\Spider\Desktop\MATLAB\PatternRecognization\Test_Images\6.tif');
original = img;
sizeHW = size(img);  %get the size matrix of the image
sizeH = sizeHW(1);  % get Height - from the sizeHW
sizeW = sizeHW(2);  % get Width - from the sizeHW

img = im2bw(img, 0.60);
img = ~(img);
img = bwareaopen(img, 10);

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

%imshow(original)
tlinenum = size(startline);
inlinesum = 0;
prevmark = 0;
gapping = 0;
threshold = 7;
linethreshold = 5;

% wordstart = [];
% wordend = [];
wordpos = [];
wordnumperline = 0;
wordnumperlinearray = [];

for totalline = 1:tlinenum(2)
    for rowwise = 1:sizeW
        for inline = startline(totalline)+1:endline(totalline)-1
            inlinesum = inlinesum + img(inline,rowwise);
        end
        % word seg marking should be done here
        if inlinesum~=0 && prevmark==0
            for inline = startline(totalline)+1:endline(totalline)-1
                original(inline,rowwise-1) = 0 ;
            end
            %mark the start of a word
            wordpos = [wordpos rowwise];
            prevmark = 1;
        elseif inlinesum==0 && prevmark==1 && gapping<threshold            
            % mark the end of word
            if rowwise < (sizeW-linethreshold)
                gapping = gapping + 1;
                prevmark = 1;
            else
                for inline = startline(totalline)+1:endline(totalline)-1
                    original(inline,rowwise) = 0 ;
                end
                wordpos = [wordpos rowwise];
                wordnumperline = wordnumperline + 1;
                gapping = 0;
                prevmark = 0;
                %almost END OF LINE
            end
        elseif inlinesum==0 && prevmark==1 && gapping==threshold
            for inline = startline(totalline)+1:endline(totalline)-1
                original(inline,rowwise-threshold) = 0 ;
            end 
            wordpos = [wordpos rowwise];
            wordnumperline = wordnumperline + 1;
            gapping = 0;
            prevmark = 0;
        elseif inlinesum~=0 && prevmark==1
            gapping = 0;
            prevmark = 1;
        end
        % marking done goto next 'rowwise'
        inlinesum = 0;
    end
    wordnumperlinearray = [wordnumperlinearray wordnumperline];
    wordnumperline = 0;
    %wordpos
    gapping = 0;
    prevmark = 0;
end
%wordpos  got all the word starting and ending position consuqutively 
%in the array called 'wordpos'

rgboriginal = cat(3, original, original, original);

worditer = 1;
file = fopen('C:\Users\Spider\Desktop\MATLAB\PatternRecognization\Data.txt','w');
lang = '';

for lineiter = 1:tlinenum(2)
    for rowiter = 1:wordnumperlinearray(lineiter)
        for hlrow = wordpos(worditer):wordpos(worditer+1)
            for hlcol = startline(lineiter):endline(lineiter)
                rgboriginal(hlcol,hlrow,2) = rgboriginal(hlcol,hlrow,2) + 50;
            end
        end
        worditer = worditer + 2;
        imshow(rgboriginal)
        lang = input('Enter language : ','s');
        fprintf(file,'Line: %i, Word:%i - Language:%s\n',lineiter,rowiter,lang);
        % store info in file / file handling handling
    end
end

fclose(file);

% imshow(rgboriginal)