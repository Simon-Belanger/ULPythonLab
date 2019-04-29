function varargout = LumeneraGUI(varargin)
% LumeneraGUI M-file for LumeneraGUI.fig
%      LumeneraGUI, by itself, creates a new LumeneraGUI or raises the existing
%      singleton*.
%
%      H = LumeneraGUI returns the handle to a new LumeneraGUI or the
%      handle to
%      the existing singleton*.
%
%      LumeneraGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LumeneraGUI.M with the given input arguments.
%
%      LumeneraGUI('Property','Value',...) creates a new LumeneraGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LumeneraGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LumeneraGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LumeneraGUI

% Last Modified by GUIDE v2.5 18-Dec-2006 11:55:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LumeneraGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LumeneraGUI_OutputFcn, ...
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

% --- Executes just before LumeneraGUI is made visible.
function LumeneraGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LumeneraGUI (see VARARGIN)

% Choose default command line output for LumeneraGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if (LuDispatcher(6,1))
    connected(handles);
    set(handles.camera_number, 'Enable', 'Off');
end

% UIWAIT makes LumeneraGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LumeneraGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in preview_on.
function preview_on_Callback(hObject, eventdata, handles)
% hObject    handle to preview_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(0, camNum);
catch
    errordlg(lasterr, 'Preview Error', 'modal');
end
preview_started(handles);


% --- Executes on button press in preview_off.
function preview_off_Callback(hObject, eventdata, handles)
% hObject    handle to preview_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(1, camNum);
catch
    errordlg(lasterr, 'Preview Error', 'modal');
end
preview_stopped(handles);

% this function is used to fill the fps listbox
function setfpslist(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    handles.fpsnamelist = LuDispatcher(4, camNum);
catch
    errordlg(lasterr, 'FPS Error', 'modal');
end
set(handles.fpslist, 'String', handles.fpsnamelist, 'Value', 1);

% clears out the fps listbox
function unsetfpslist(handles)
set(handles.fpslist, 'String', '', 'Value', 1);

% this function is used to set the offsets
function setoffsets(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    offsets = LuDispatcher(8, camNum);
catch
    errordlg(lasterr, 'Offset Error', 'modal');
end
set(handles.xOffset_Box, 'String', offsets(1));
set(handles.yOffset_Box, 'String', offsets(2));
set(handles.offset_button, 'Enable', 'on');
set(handles.xOffset_Box, 'Enable', 'on');
set(handles.yOffset_Box, 'Enable', 'on');

% this function is used to unset the offsets
function unsetoffsets(handles)
set(handles.xOffset_Box, 'String', '');
set(handles.yOffset_Box, 'String', '');
set(handles.offset_button, 'Enable', 'off');
set(handles.xOffset_Box, 'Enable', 'off');
set(handles.yOffset_Box, 'Enable', 'off');

% this function is used to set the 16-bit checkbox
function set16bit(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    toggleVal = LuDispatcher(11, camNum);
catch
    errordlg(lasterr, '16-Bit Error', 'modal');
end
set(handles.check_16bit, 'Value', toggleVal);
set(handles.check_16bit, 'Enable', 'on');

% this function is used to unset the 16-bit checkbox
function unset16bit(handles)
set(handles.check_16bit, 'Enable', 'off');
set(handles.check_16bit, 'Value', false);

% this function is used to set the resolution
function setresolution(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    resolution = LuDispatcher(12, camNum);
catch
    errordlg(lasterr, 'Resolution Error', 'modal');
end
set(handles.width_box, 'String', resolution(1));
set(handles.height_box, 'String', resolution(2));
set(handles.change_res_button, 'Enable', 'on');
set(handles.width_box, 'Enable', 'on');
set(handles.height_box, 'Enable', 'on');

% this function is used to unset the resolution
function unsetresolution(handles)
set(handles.width_box, 'String', '');
set(handles.height_box, 'String', '');
set(handles.change_res_button, 'Enable', 'off');
set(handles.width_box, 'Enable', 'off');
set(handles.height_box, 'Enable', 'off');

% this function is used to set the labels
function setlabels(handles)
set(handles.width_label, 'Enable', 'on');
set(handles.height_label, 'Enable', 'on');
set(handles.horizontal_label, 'Enable', 'on');
set(handles.vertical_label, 'Enable', 'on');

% this function is used to unset the labels
function unsetlabels(handles)
set(handles.width_label, 'Enable', 'off');
set(handles.height_label, 'Enable', 'off');
set(handles.horizontal_label, 'Enable', 'off');
set(handles.vertical_label, 'Enable', 'off');

% sets the properties for when we connect
function connected(handles)
set(handles.connect_button, 'Enable', 'off');
set(handles.disconnect_button, 'Enable', 'on');
set(handles.setfps, 'Enable', 'on');
set(handles.properties_page, 'Enable', 'on');
set(handles.status_bar, 'String', 'Connected');
set(handles.capture_button, 'Enable', 'on');
setfpslist(handles);
setresolution(handles);
setoffsets(handles);
set16bit(handles);
set(handles.snapshot_mode_checkbox, 'Enable', 'on');
setlabels(handles);

% sets the properties for when we disconnect
function disconnected(handles)
set(handles.connect_button, 'Enable', 'on');
set(handles.disconnect_button, 'Enable', 'off');
set(handles.setfps, 'Enable', 'off');
set(handles.properties_page, 'Enable', 'off');
set(handles.status_bar, 'String', 'Not Connected');
set(handles.capture_button, 'Enable', 'off');
unsetfpslist(handles);
unsetoffsets(handles);
unset16bit(handles);
unsetresolution(handles);
preview_stopped(handles);
set(handles.snapshot_mode_checkbox, 'Enable', 'off');
set(handles.snapshot_mode_checkbox, 'Value', 0);
unsetsnapshot(handles);
unsetlabels(handles);

% sets the properties for when we start a preview
function preview_started(handles)
set(handles.preview_off, 'Enable', 'on');
set(handles.preview_on, 'Enable', 'off');
connected(handles);

% sets the properties for when we stop the preview
function preview_stopped(handles)
set(handles.preview_off, 'Enable', 'off');
set(handles.preview_on, 'Enable', 'on');

% --- Executes during object creation, after setting all properties.
function fpslist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fpslist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject, 'String', '', 'Value', 1);




% --- Executes on selection change in fpslist.
function fpslist_Callback(hObject, eventdata, handles)
% hObject    handle to fpslist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fpslist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fpslist


% --- Executes on button press in setfps.
function setfps_Callback(hObject, eventdata, handles)
% hObject    handle to setfps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(handles.fpslist,'Value');
try
    camNum = str2num(get(handles.camera_number, 'String'));
    fpslist = LuDispatcher(4, camNum);
    LuDispatcher(3, camNum, fpslist(value));
catch
    errordlg(lasterr, 'FPS Error', 'modal');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
camNum = str2num(get(handles.camera_number, 'String'));
delete(hObject);
% Don't disconnect the camera.
%try
%    if LuDispatcher(6, camNum)
%        LuDispatcher(-2, camNum);
%    end
%catch
%    errordlg(lasterr, 'Connection Error', 'modal');
%end


% --- Executes on button press in properties_page.
function properties_page_Callback(hObject, eventdata, handles)
% hObject    handle to properties_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(5, camNum);
catch
    errordlg(lasterr, 'Properties Error', 'modal');
end


% --- Executes during object creation, after setting all properties.
function width_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function width_box_Callback(hObject, eventdata, handles)
% hObject    handle to width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_box as text
%        str2double(get(hObject,'String')) returns contents of width_box as a double


% --- Executes during object creation, after setting all properties.
function height_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function height_box_Callback(hObject, eventdata, handles)
% hObject    handle to height_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height_box as text
%        str2double(get(hObject,'String')) returns contents of height_box as a double


% --- Executes on button press in change_res_button.
function change_res_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_res_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
width = str2num(get(handles.width_box, 'String'));
height = str2num(get(handles.height_box, 'String'));
if (width == 0) || (height == 0)
    errordlg('Resolution may not have a dimension set to 0.', 'Input Error', 'modal');
elseif (mod(width, 8) ~= 0) || (mod(height, 8) ~= 0)
    errordlg('Resolution must be a multiple of 8.', 'Input Error', 'modal');
    setresolution(handles);
else
    try
        camNum = str2num(get(handles.camera_number, 'String'));
        LuDispatcher(2, camNum, width, height);
    catch
        errordlg(lasterr, 'Resolution Error', 'modal');
    end
end
setfpslist(handles);
setoffsets(handles);



% --- Executes on button press in capture_button.
function capture_button_Callback(hObject, eventdata, handles)
% hObject    handle to capture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'off');
try
    camNum = str2num(get(handles.camera_number, 'String'));
    thePicture = LuDispatcher(7, camNum);
    %imshow requires image processing toolbox be installed.
    %figure, imshow(thePicture, 'InitialMagnification', 'fit');
    figure, image(thePicture);
    pictureName = inputdlg({'Name of Image Matrix:'}, 'Image Name', 1, {'theImage'});
    if(length(pictureName) ~= 0)
        assignin('base', pictureName{1}, thePicture);
    end
catch
    errordlg(lasterr, 'Capture Error', 'modal');
end
set(hObject, 'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function xOffset_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xOffset_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function xOffset_Box_Callback(hObject, eventdata, handles)
% hObject    handle to xOffset_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xOffset_Box as text
%        str2double(get(hObject,'String')) returns contents of xOffset_Box as a double


% --- Executes during object creation, after setting all properties.
function yOffset_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yOffset_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function yOffset_Box_Callback(hObject, eventdata, handles)
% hObject    handle to xOffset_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xOffset_Box as text
%        str2double(get(hObject,'String')) returns contents of xOffset_Box as a double


% --- Executes on button press in offset_button.
function offset_button_Callback(hObject, eventdata, handles)
% hObject    handle to offset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xoff = str2num(get(handles.xOffset_Box, 'String'));
yoff = str2num(get(handles.yOffset_Box, 'String'));
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(9, camNum, xoff, yoff);
catch
    errordlg(lasterr, 'Offset Error', 'modal');
end
setoffsets(handles);


% --- Executes on button press in check_16bit.
function check_16bit_Callback(hObject, eventdata, handles)
% hObject    handle to check_16bit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1
    toggleVal = true;
else
    toggleVal = false;
end
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(10, camNum, toggleVal);
catch
    errordlg(lasterr, 'Bit Depth Error', 'modal');
end


% --- Executes on button press in connect_button.
function connect_button_Callback(hObject, eventdata, handles)
% hObject    handle to connect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    if (~LuDispatcher(6, camNum))
        LuDispatcher(-1, camNum);
    end
    set(handles.camera_number, 'Enable', 'Off');
catch
    errordlg(lasterr, 'Connection Error', 'modal');
end
connected(handles);


% --- Executes on button press in disconnect_button.
function disconnect_button_Callback(hObject, eventdata, handles)
% hObject    handle to disconnect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    if (LuDispatcher(6,camNum))
        LuDispatcher(-2, camNum);
    end
catch
    errordlg(lasterr, 'Disconnection Error', 'modal');
end
set(handles.camera_number, 'Enable', 'On');
disconnected(handles);

% this function handles setting up the exposure
function setexposure(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    range = LuDispatcher(14, camNum);
catch
    errordlg(lasterr, 'Exposure Error', 'modal');
end
set(handles.snapshot_exposure_slider, 'Min', range(1));
set(handles.snapshot_exposure_slider, 'Max', range(2));
set(handles.snapshot_exposure, 'Enable', 'on');
set(handles.snapshot_exposure_slider, 'Enable', 'on');
exposureval = get(handles.snapshot_exposure_slider, 'Value');
if(exposureval < range(1))
    exposureval = range(1);
elseif(exposureval > range(2))
    exposureval = range(2);
end
set(handles.snapshot_exposure_slider, 'Value', exposureval);
set(handles.snapshot_exposure, 'String', exposureval);

% this function handles unsetting the exposure
function unsetexposure(handles)
set(handles.snapshot_exposure, 'Enable', 'off');
set(handles.snapshot_exposure_slider, 'Enable', 'off');
set(handles.snapshot_exposure, 'String', '');

% this function handles setting up the gain
function setgain(handles)
try
    camNum = str2num(get(handles.camera_number, 'String'));
    range = LuDispatcher(16, camNum);
catch
    errordlg(lasterr, 'Gain Error', 'modal');
end
set(handles.snapshot_gain_slider, 'Min', range(1));
set(handles.snapshot_gain_slider, 'Max', range(2));
set(handles.snapshot_gain, 'Enable', 'on');
set(handles.snapshot_gain_slider, 'Enable', 'on');
gainval = get(handles.snapshot_gain_slider, 'Value');
if(gainval < range(1))
    gainval = range(1);
elseif(gainval > range(2))
    gainval = range(2);
end
set(handles.snapshot_gain_slider, 'Value', gainval);
set(handles.snapshot_gain, 'String', gainval);

% this function handles unsetting the gain
function unsetgain(handles)
set(handles.snapshot_gain, 'Enable', 'off');
set(handles.snapshot_gain_slider, 'Enable', 'off');
set(handles.snapshot_gain, 'String', '');

% this function handles setting the strobe
function setstrobe(handles)
set(handles.strobe_checkbox, 'Enable', 'on');

% this function handles unsetting the strobe
function unsetstrobe(handles)
set(handles.strobe_checkbox, 'Enable', 'off');
set(handles.strobe_checkbox, 'Value', 0);
set(handles.trigger_delay, 'String', '');
set(handles.trigger_delay, 'Enable', 'off');

% this function handles setting the hw trigger
function sethwtrigger(handles)
set(handles.hwtrigger_checkbox, 'Enable', 'on');

% this function handles unsetting hwtrigger
function unsethwtrigger(handles)
set(handles.hwtrigger_checkbox, 'Enable', 'off');
set(handles.hwtrigger_checkbox, 'Value', 0);

% this function handles setting the 16-bit snapshot mode
function set16bitsnapshot(handles)
set(handles.snapshot_16bit, 'Enable', 'on');

% this function handles unsetting the 16-bit snapshot mode
function unset16bitsnapshot(handles)
set(handles.snapshot_16bit, 'Enable', 'off');
set(handles.snapshot_16bit, 'Value', 0);

% this function handles setting the color gains
function setcolorgains(handles)
set(handles.red_gain, 'Enable', 'on');
set(handles.green_gain, 'Enable', 'on');
set(handles.blue_gain, 'Enable', 'on');
try
    camNum = str2num(get(handles.camera_number, 'String'));
    colorgains = LuDispatcher(21, camNum);
catch
    errordlg(lasterr, 'Color Gain Error', 'modal');
end
set(handles.red_gain, 'String', colorgains(1));
greengain = (colorgains(2) + colorgains(3)) / 2;
set(handles.green_gain, 'String', greengain);
set(handles.blue_gain, 'String', colorgains(4));

% this function handles unsetting the color gains
function unsetcolorgains(handles)
set(handles.red_gain, 'Enable', 'off');
set(handles.green_gain, 'Enable', 'off');
set(handles.blue_gain, 'Enable', 'off');
set(handles.red_gain, 'String', '');
set(handles.green_gain, 'String', '');
set(handles.blue_gain, 'String', '');

% this function handles setting the snapshot labels
function setsnapshotlabels(handles)
set(handles.exposure_label, 'Enable', 'on');
set(handles.delay_label, 'Enable', 'on');

%this function handles unsetting the snapshot labels
function unsetsnapshotlabels(handles)
set(handles.exposure_label, 'Enable', 'off');
set(handles.delay_label, 'Enable', 'off');

% this function handles what happens when snapshot mode is enables
function setsnapshot(handles)
setexposure(handles);
setgain(handles);
setstrobe(handles);
sethwtrigger(handles);
set16bitsnapshot(handles);
setcolorgains(handles);
set(handles.snapshot_button, 'Enable', 'on');
setsnapshotlabels(handles);

% this function handles what happens when snapshot mode is disabled
function unsetsnapshot(handles)
unsetexposure(handles);
unsetgain(handles);
unsetstrobe(handles);
unsethwtrigger(handles);
unset16bitsnapshot(handles);
unsetcolorgains(handles);
set(handles.snapshot_button, 'Enable', 'off');
unsetsnapshotlabels(handles);


% --- Executes on button press in snapshot_mode_checkbox.
function snapshot_mode_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_mode_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of snapshot_mode_checkbox
if(get(hObject, 'Value') == 1)
    setsnapshot(handles)
else
    unsetsnapshot(handles)
end

% --- Executes during object creation, after setting all properties.
function snapshot_exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snapshot_exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function snapshot_exposure_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of snapshot_exposure as text
%        str2double(get(hObject,'String')) returns contents of snapshot_exposure as a double
min = get(handles.snapshot_exposure_slider, 'Min');
max = get(handles.snapshot_exposure_slider, 'Max');
val = str2num(get(hObject, 'String'));
if(val < min)
    val = min;
elseif(val > max)
    val = max;
end
set(hObject, 'String', val);
set(handles.snapshot_exposure_slider, 'Value', val);




% --- Executes during object creation, after setting all properties.
function snapshot_exposure_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snapshot_exposure_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function snapshot_exposure_slider_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_exposure_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
exposure_value = get(hObject, 'Value');
set(handles.snapshot_exposure, 'String', exposure_value);


% --- Executes during object creation, after setting all properties.
function snapshot_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snapshot_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function snapshot_gain_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of snapshot_gain as text
%        str2double(get(hObject,'String')) returns contents of snapshot_gain as a double
min = get(handles.snapshot_gain_slider, 'Min');
max = get(handles.snapshot_gain_slider, 'Max');
val = str2num(get(hObject, 'String'));
if(val < min)
    val = min;
elseif(val > max)
    val = max;
end
set(hObject, 'String', val);
set(handles.snapshot_gain_slider, 'Value', val);


% --- Executes during object creation, after setting all properties.
function snapshot_gain_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snapshot_gain_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function snapshot_gain_slider_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_gain_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
gain_value = get(hObject, 'Value');
set(handles.snapshot_gain, 'String', gain_value);


% --- Executes on button press in strobe_checkbox.
function strobe_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to strobe_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of strobe_checkbox
if(get(hObject, 'Value'))
    set(handles.trigger_delay, 'String', 0.3);
    set(handles.trigger_delay, 'Enable', 'on');
else
    set(handles.trigger_delay, 'String', '');
    set(handles.trigger_delay, 'Enable', 'off');
end

% --- Executes during object creation, after setting all properties.
function trigger_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trigger_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function trigger_delay_Callback(hObject, eventdata, handles)
% hObject    handle to trigger_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trigger_delay as text
%        str2double(get(hObject,'String')) returns contents of trigger_delay as a double

if(str2num(get(hObject, 'String')) < 0)
    set(hObject, 'String', 0);
end


% --- Executes on button press in hwtrigger_checkbox.
function hwtrigger_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to hwtrigger_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hwtrigger_checkbox


% --- Executes on button press in snapshot_16bit.
function snapshot_16bit_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_16bit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of snapshot_16bit


% --- Executes during object creation, after setting all properties.
function red_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to red_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function red_gain_Callback(hObject, eventdata, handles)
% hObject    handle to red_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of red_gain as text
%        str2double(get(hObject,'String')) returns contents of red_gain as a double


% --- Executes during object creation, after setting all properties.
function green_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to green_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function green_gain_Callback(hObject, eventdata, handles)
% hObject    handle to green_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of green_gain as text
%        str2double(get(hObject,'String')) returns contents of green_gain as a double


% --- Executes during object creation, after setting all properties.
function blue_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blue_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function blue_gain_Callback(hObject, eventdata, handles)
% hObject    handle to blue_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blue_gain as text
%        str2double(get(hObject,'String')) returns contents of blue_gain as a double


% --- Executes on button press in snapshot_button.
function snapshot_button_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable the snapshot button
set(hObject, 'Enable', 'off');

% gather all the data
exposure_val = str2num(get(handles.snapshot_exposure, 'String'));
gain_val = str2num(get(handles.snapshot_gain, 'String'));
red_gain_val = str2num(get(handles.red_gain, 'String'));
green_gain_val = str2num(get(handles.green_gain, 'String'));
blue_gain_val = str2num(get(handles.blue_gain, 'String'));
strobe_delay_val = str2num(get(handles.trigger_delay, 'String'));
if(get(handles.snapshot_16bit, 'Value') == 1)
    snapshot16bit_val = true;
else
    snapshot16bit_val = false;
end
if(get(handles.strobe_checkbox, 'Value') == 1)
    strobe_val = true;
else
    strobe_val = false;
end
if(get(handles.hwtrigger_checkbox, 'Value') == 1)
    hwtrigger_val = true;
else
    hwtrigger_val = false;
end

% send the data to matlab
try
    camNum = str2num(get(handles.camera_number, 'String'));
    LuDispatcher(15, camNum, exposure_val); % exposure
    LuDispatcher(17, camNum, gain_val); % gain
    LuDispatcher(20, camNum, red_gain_val, green_gain_val, green_gain_val, blue_gain_val); % color gain
    LuDispatcher(18, camNum, snapshot16bit_val); % 16bit mode
    LuDispatcher(22, camNum, strobe_val); % strobe use
    if(strobe_val == true)
        LuDispatcher(24, camNum, strobe_delay_val); % strobe delay
    end
    LuDispatcher(26, camNum, hwtrigger_val);
catch
    errordlg(lasterr, 'Property Error', 'modal');
end

%take the snapshot
try
    thePicture = LuDispatcher(13, camNum);
    %imshow requires image processing toolbox be installed.
    %figure, imshow(thePicture, 'InitialMagnification', 'fit');
    figure, image(thePicture);
    pictureName = inputdlg({'Name of Image VMatrix:'}, 'Image Name', 1, {'theImage'});
    if(length(pictureName) ~= 0) % check for cancel button
        assignin('base', pictureName{1}, thePicture);
    end
catch
    errordlg(lasterr, 'Snapshot Error', 'modal');
end

%renable the snapshot button
set(hObject, 'Enable', 'on');





function Camera_number_Callback(hObject, eventdata, handles)
% hObject    handle to Camera_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Camera_number as text
%        str2double(get(hObject,'String')) returns contents of
%        Camera_number as a double


% --- Executes during object creation, after setting all properties.
function Camera_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Camera_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function camera_number_Callback(hObject, eventdata, handles)
% hObject    handle to camera_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of camera_number as text
%        str2double(get(hObject,'String')) returns contents of
%        camera_number as a double

% --- Executes during object creation, after setting all properties.
function camera_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


