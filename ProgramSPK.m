function varargout = ProgramSPK(varargin) %GUI
% PROGRAMSPK MATLAB code for ProgramSPK.fig
%      PROGRAMSPK, by itself, creates a new PROGRAMSPK or raises the existing
%      singleton*.
%
%      H = PROGRAMSPK returns the handle to a new PROGRAMSPK or the handle to
%      the existing singleton*.
%
%      PROGRAMSPK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRAMSPK.M with the given input arguments.
%
%      PROGRAMSPK('Property','Value',...) creates a new PROGRAMSPK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProgramSPK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProgramSPK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProgramSPK

% Last Modified by GUIDE v2.5 20-Jan-2018 17:55:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProgramSPK_OpeningFcn, ...
                   'gui_OutputFcn',  @ProgramSPK_OutputFcn, ...
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


% --- Executes just before ProgramSPK is made visible.
function ProgramSPK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProgramSPK (see VARARGIN)

% Choose default command line output for ProgramSPK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0,'datacontainer',hObject);
movegui(hObject,'onscreen')% To display application onscreen
movegui(hObject,'center')  % To display application in the center of screen

clear
clc
% UIWAIT makes ProgramSPK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProgramSPK_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[nama_file,nama_path] = uigetfile({'*.*'},'Silahkan pilih Gambar','D:\Materi Kuliah\S2 - MMSI\Semester 1\Sistem Penunjang Keputusan\Kategori Data\Total Data');
if ~isequal(nama_file,0)
    img = imread(fullfile(nama_path,nama_file));
    axes(handles.axes1)
    imshow(img)
    handles.img = img;
    guidata(hObject,handles)
else
    return
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img = handles.img;
x = str2double(get(handles.edit3,'String'));
y = str2double(get(handles.edit4, 'String'));

%Preprocessing
rect = [x y 50 50];
img_crop = imcrop(img,rect); %cropping based on input coordinate
img_resize = imresize(img_crop,[50 50]);
img_final = medfilt2(img_resize);

axes(handles.axes2);
imshow(img_final);
handles.img_final = img_final;
guidata(hObject,handles)

imwrite (img_final,'contoh pre.png');

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

img_ex = handles.img_final;

%Gray Level Coocurence Matrix (GLCM) Texture Feature Extraction
jarak_test = 1; %distance beetwen pixel
GLCM_test = graycomatrix(img_ex,'Offset',[0 jarak_test; -jarak_test jarak_test; -jarak_test 0; -jarak_test -jarak_test]);
stats = graycoprops(GLCM_test,{'contrast','homogeneity','correlation','energy'});

contrast = stats.Contrast;
contrast0 = contrast(1);
contrast45 = contrast(2);
contrast90 = contrast(3);
contrast135 = contrast(4);

homogeneity = stats.Homogeneity;
homogeneity0 = homogeneity(1);
homogeneity45 = homogeneity(2);
homogeneity90 = homogeneity(3);
homogeneity135 = homogeneity(4);

correlation = stats.Correlation;
correlation0 = correlation(1);
correlation45 = correlation(2);
correlation90 = correlation(3);
correlation135 = correlation(4);

energy = stats.Energy;
energy0 = energy(1);
energy45 = energy(2);
energy90 = energy(3);
energy135 = energy(4);

testing_knn = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;...
    correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135]';

testing_ann = [contrast0;contrast45;contrast90;contrast135;homogeneity0;homogeneity45;homogeneity90;homogeneity135;...
    correlation0;correlation45;correlation90;correlation135;energy0;energy45;energy90;energy135];

load knn_train
load group_train
load jst

Predict = knnclassify(testing_knn,training,group_train, 5, 'euclidean','nearest') %KNN PREDICT

if Predict == 1
    kelas_knn = 'Benign'; %TARGET CLASS
elseif Predict == 2
    kelas_knn = 'Malignant';
elseif Predict == 3
    kelas_knn = 'Normal';  
end

set(handles.edit2,'String',kelas_knn);

output = sim(net,testing_ann)
keluaran = vec2ind(output) % ANN PREDICT

if keluaran == 1
    kelas_ann = 'Benign'; %TARGET CLASS
elseif keluaran == 2
    kelas_ann = 'Malignant';
elseif keluaran == 3
    kelas_ann = 'Normal';  
end

set(handles.edit1,'String',kelas_ann);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
