% obj is the main testbench object
% --- build up a test control ui in the assigned panel (or popup)
% parentName is a string describing of the parent panel (or popup)
% --- 1. For popup: should be like 'manual', 'selectPeaks' ...
% --- 2. For panel: should be the same as in panel_index function
% parentObj is the parent object for the ui (type: double)
% Pavel Kulik 2013;
% Modified by Vince Wu - Nov 2013

function obj = test_control_ui(obj, parentName, parentObj, position)

parentStruct = getParentStruct(parentName);
if (~isempty(strfind(parentStruct, 'panel')))
    panelIndex = str2double(parentStruct(end - 1));
    parentStruct = parentStruct(1:end - 3);
else
    panelIndex = 1;
end

%% Test Status and Control Panel
% panel element size variables
stringBoxSize = [0.35, 0.1];
pushButtonSize = [0.25, 0.18];
editBoxSize = [0.15, 0.1];
spc = 0.55;
x_start = 0.05;
y_start = 0.76;

% parent panel
obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel = uipanel(...
    'Parent', parentObj, ...
    'Unit', 'Pixels', ...
    'Units', 'normalized', ...
    'Visible', 'on', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Title', 'Test Status & Control', ...
    'FontSize', 9, ...
    'FontWeight', 'Bold', ...
    'Position', position);

x_align = x_start;
y_align = y_start;

% start button
obj.gui.(parentStruct)(panelIndex).testControlUI.startButton = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'String', 'Start', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, pushButtonSize], ...
    'Callback', {@start_button_cb, obj, parentStruct, panelIndex});

x_align = x_start + 0.32;

% pause button
obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'Enable', 'off', ...
    'Units', 'normalized', ...
    'String', 'Pause', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, pushButtonSize], ...
    'Callback', {@pause_button_cb, obj, parentStruct, panelIndex});

x_align = x_align + 0.32;

% stop button
obj.gui.(parentStruct)(panelIndex).testControlUI.stopButton = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'Enable', 'off', ...
    'Units', 'normalized', ...
    'String', 'Stop', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, pushButtonSize], ...
    'Callback', {@stop_button_cb, obj, parentStruct, panelIndex});

x_align = x_start;
y_align = y_align - 1.2*pushButtonSize(2);

% progress string
obj.gui.(parentStruct)(panelIndex).testControlUI.progressString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Progress:', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, stringBoxSize]);


% progress display
obj.gui.(parentStruct)(panelIndex).testControlUI.progressDisplay = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'String', 'n/a', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'FontSize', 9, ...
    'Position', [x_align + 0.2, y_align, stringBoxSize]);

% Scan Number string
obj.gui.(parentStruct)(panelIndex).testControlUI.scanNumberString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Scan #:', ...
    'FontSize', 9, ...
    'Position', [x_align + 0.60, y_align, editBoxSize]);

% Scan Number display
obj.gui.(parentStruct)(panelIndex).testControlUI.scanNumberDisplay = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'String', 'n/a', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'FontSize', 9, ...
    'Position', [x_align + 0.75, y_align, editBoxSize]);

x_align = x_start;
y_align = y_align - 1.2*pushButtonSize(2);

% current device string
obj.gui.(parentStruct)(panelIndex).testControlUI.currentDeviceString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Current Device:', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, stringBoxSize]);

x_align = x_align + spc;

% current device display
obj.gui.(parentStruct)(panelIndex).testControlUI.currentDeviceDisplay = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'String', 'n/a', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'FontSize', 9, ...
    'Position', [x_align - 0.1, y_align, stringBoxSize]);

x_align = x_start;
y_align = y_align - 1.2*pushButtonSize(2);

% total elapsed time string
obj.gui.(parentStruct)(panelIndex).testControlUI.elapsedTimeString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Elapsed Time (min):', ...
    'FontSize', 9, ...
    'Position', [x_align, y_align, stringBoxSize]);

x_align = x_align + spc;

% total time display
obj.gui.(parentStruct)(panelIndex).testControlUI.elapsedTimeDisplay = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).testControlUI.mainPanel, ...
    'Style', 'text', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'String', '0.0', ...
    'FontSize', 9, ...
    'Position', [x_align - 0.1, y_align, stringBoxSize]);

end
%% Callbacks
function start_button_cb(~, ~, obj, parentStruct, panelIndex)
if get(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'UserData')
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'UserData', 0); % reset pause flag
    pause off;
else
    pause on;
    % Enable pause button and Stop Button
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'Enable', 'On');
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'UserData', 0);
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.stopButton, 'Enable', 'On');
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.stopButton, 'UserData', 0);
    % Disable Start Button
    set(obj.gui.(parentStruct)(panelIndex).testControlUI.startButton, 'Enable', 'Off');
    
    % execute test
    test_type = lower(obj.AppSettings.infoParams.Task);
    if strcmpi(test_type, 'WetTest') || strcmpi(test_type, 'DryTest')
        dry_test(obj);
    elseif strcmpi(test_type, 'SaltSteps')
        assay(obj);
    else
        msg = strcat('No test script exists for ',test_type,' yet. Bug Shon to get it done.');
        error(msg);
    end
end
end

function pause_button_cb(~, ~, obj, parentStruct, panelIndex)
set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'UserData', 1);
% disable button once set
set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'Enable', 'off');
set(obj.gui.(parentStruct)(panelIndex).testControlUI.startButton, 'Enable', 'on');
end

function stop_button_cb(hObject, ~, obj, parentStruct, panelIndex)
set(hObject, 'UserData', 1);
% disable button once set
set(obj.gui.(parentStruct)(panelIndex).testControlUI.stopButton, 'Enable', 'off');
set(obj.gui.(parentStruct)(panelIndex).testControlUI.pauseButton, 'Enable', 'off');
set(obj.gui.(parentStruct)(panelIndex).testControlUI.startButton, 'Enable', 'on');
% shons note-need to write this script
%        test_finish(obj); % script to finish assay and transfer data
end