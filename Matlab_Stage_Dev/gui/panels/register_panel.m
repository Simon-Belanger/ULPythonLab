function obj = register_panel(obj)

set(obj.gui.nextButton, 'Enable', 'on'); % Temporary
thisPanel = panel_index('register');

cam_width = 0.61;
cam_height = 0.91;
% Microscope Camera ui Panel
obj = camera_ui(...
    obj, ...
    'register', ...
    obj.gui.panelFrame(thisPanel), ...
    [.01, .02, cam_width, cam_height]);

%% AUTO COORDINATE SYSTEM
autoCoordPosition = ...
    [cam_width + 0.015, cam_height - 0.15, 0.975 - cam_width, 0.17];
obj.gui.panel(thisPanel).autoCoordPanel = uipanel(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Unit', 'normalized', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Title', 'Auto Coordinate System', ...
    'FontSize', 9, ...
    'FontWeight', 'Bold', ...
    'Position', autoCoordPosition);

buttonPosition = [0.07, 0.66, 0.25, 0.25];
% Automatic Start
obj.gui.panel(thisPanel).autoCoordSys.auto_start= uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','pushbutton', ...
    'Enable','off', ...
    'Units', 'normalized', ...
    'String','Start', ...
    'Position', buttonPosition, ...
    'Callback', @auto_start_cb);

%Automatic Stop
buttonPosition(1) = buttonPosition(1) + 0.3;
obj.gui.panel(thisPanel).autoCoordSys.auto_stop = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','pushbutton', ...
    'Enable','off', ...
    'BackGroundColor', [1,0,0], ...
    'Units', 'normalized', ...
    'Position', buttonPosition, ...
    'String','Stop', ...
    'Callback', @auto_stop_cb);

%Automatic Settings
buttonPosition(1) = buttonPosition(1) + 0.3;
obj.gui.panel(thisPanel).autoCoordSys.auto_settings = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','pushbutton', ...
    'Enable','on', ...
    'Units', 'normalized', ...
    'Position', buttonPosition, ...
    'String', 'Settings', ...
    'Callback', @auto_settings_cb);

% Progress String
obj.gui.panel(thisPanel).autoCoordSys.progressString = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'Position', [.1, .41, .21, .16], ...
    'String', 'Progress: ', ....
    'FontSize', 9);

% Progress Bar
obj.gui.panel(thisPanel).autoCoordSys.auto_progress_bar = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','text', ...
    'HorizontalAlignment','center', ...
    'BackGroundColor', [1,0,0], ...
    'Units', 'normalized', ...
    'Position', [.36, .38, .41, .19], ...
    'String', '0% Completed', ...
    'FontSize', 9, ...
    'Callback', @auto_prgrss_bar_cb);

%Error String
obj.gui.panel(thisPanel).autoCoordSys.error_string = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style','text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'Position', [0.16, .13, .16, .16], ...
    'String', 'Error: ', ....
    'FontSize', 9);


%Error Box
obj.gui.panel(thisPanel).autoCoordSys.errorDisp = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).autoCoordPanel, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [.36, .11, .41, .19], ...
    'FontSize', 8, ...
    'Visible', 'on', ...
    'String', 'N/A', ...
    'Callback', @error_disp_cb);

%% Heat Map Panel
heatMapPosition = ...
    [autoCoordPosition(1), autoCoordPosition(2) - 0.61, ...
    autoCoordPosition(3), 0.61];
% Heat Map Panel
obj.gui.panel(thisPanel).heatMapPanel = uipanel(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Unit', 'normalized', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Title', 'Heat Map', ...
    'FontSize', 9, ...
    'FontWeight', 'Bold', ...
    'Position', heatMapPosition);

% Heat Map axe
obj.gui.panel(thisPanel).heatMapDsip = axes(...
    'Parent', obj.gui.panel(thisPanel).heatMapPanel, ...
    'Units', 'normalized', ...
    'Position', [.1, .06, .84, .9], ...
    'Color', [.85 .85 .85], ...
    'NextPlot', 'add', ...
    'box', 'on');

%% Manual Coordinates System
manualCoordPosition = ...
    [heatMapPosition(1), 0.02, ...
    heatMapPosition(3), heatMapPosition(2) - 0.02];

obj.gui.panel(thisPanel).manualCoordPanel = uipanel(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Unit', 'normalized', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Title', 'Manual Coordinate Control', ...
    'FontSize', 9, ...
    'FontWeight', 'Bold', ...
    'Position', manualCoordPosition);

if (~isempty(obj.instr.laser) && ~isempty(obj.instr.opticalStage))
    man_enable = 'on';
else
    man_enable = 'off';
end

obj.gui.panel(thisPanel).manualCoordStart = uicontrol(...
    'Parent', obj.gui.panel(thisPanel).manualCoordPanel, ...
    'Style','pushbutton', ...
    'Enable', man_enable, ...
    'Units', 'normalized', ...
    'Position', [.33, .2, .3, .6], ...
    'String','START', ...
    'FontSize', 11, ...
    'Callback', {@man_crd_start_cb, obj});

end

%% CALLBACKS
% AUTO COORDINATE CALLBACKS
function auto_start_cb(hObject, eventdata) 
end
function auto_stop_cb(hObject, eventdata) 
end
function auto_settings_cb(hObject, eventdata) 
end
function auto_prgrss_bar_cb(hObject, eventdata) 
end
function error_disp_cb(hObject, eventdata) 
end
% MANUAL COORDINATE CALLBACKS
function  man_crd_start_cb(~, ~, obj)
man_coord_start(obj);
end