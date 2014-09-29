function varargout = WordSegmentGUI(varargin)
% WORDSEGMENTGUI MATLAB code for WordSegmentGUI.fig
%      WORDSEGMENTGUI, by itself, creates a new WORDSEGMENTGUI or raises the existing
%      singleton*.
%
%      H = WORDSEGMENTGUI returns the handle to a new WORDSEGMENTGUI or the handle to
%      the existing singleton*.
%
%      WORDSEGMENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORDSEGMENTGUI.M with the given input arguments.
%
%      WORDSEGMENTGUI('Property','Value',...) creates a new WORDSEGMENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WordSegmentGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WordSegmentGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WordSegmentGUI

% Last Modified by GUIDE v2.5 17-Sep-2014 21:13:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WordSegmentGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @WordSegmentGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before WordSegmentGUI is made visible.
function WordSegmentGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WordSegmentGUI (see VARARGIN)

% Choose default command line output for WordSegmentGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WordSegmentGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WordSegmentGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
axes(handles.picarea);

previous = 0;
startline = [];
endline = [];

img = imread(get(handles.imgpath,'String'));
imshow(img);
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

tlinenum = size(startline);
inlinesum = 0;
prevmark = 0;
gapping = 0;
threshold = 7;
linethreshold = 5;

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
file = fopen(get(handles.filepath,'String'),'w');

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
        % INPUT SHOULD BE TAKEN FROM HERE
        fprintf(file,'Line: %i, Word:%i - Language:%s\n',lineiter,rowiter,lang);
        % store info in file / file handling handling
    end
end



function imgpath_Callback(hObject, eventdata, handles)
% hObject    handle to imgpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imgpath as text
%        str2double(get(hObject,'String')) returns contents of imgpath as a double


% --- Executes during object creation, after setting all properties.
function imgpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filepath_Callback(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath as text
%        str2double(get(hObject,'String')) returns contents of filepath as a double


% --- Executes during object creation, after setting all properties.
function filepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function language_Callback(hObject, eventdata, handles)
% hObject    handle to language (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of language as text
%        str2double(get(hObject,'String')) returns contents of language as a double


% --- Executes during object creation, after setting all properties.
function language_CreateFcn(hObject, eventdata, handles)
% hObject    handle to language (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
