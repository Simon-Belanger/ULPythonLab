% obj is the main testbench object
% --- build up a coordinates control ui in the assigned panel (or popup)
% parentName is a string describing of the parent panel (or popup)
% --- 1. For popup: should be like 'manual', 'selectPeaks' ...
% --- 2. For panel: should be the same as in panel_index function
% parentObj is the parent object for the ui (type: double)
% Victor Bass 2013;
% Modified by Vince Wu - Nov 2013
% Modified by Pavel Kulik - Nov 2013

function obj = coordinates_ui(obj, parentName, parentObj, position)

parentStruct = getParentStruct(parentName);
if (~isempty(strfind(parentStruct, 'panel')))
    panelIndex = str2double(parentStruct(end - 1));
    parentStruct = parentStruct(1:end - 3);
else
    panelIndex = 1;
end

% ui element size variables
editBoxSize = [0.25, 0.075];
pushButtonSize = [0.25, 0.075];
stringBoxSize = [0.25, 0.075];

% Coordinates main Panel
obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel = uipanel(...
    'Parent', parentObj, ...
    'Unit', 'Pixels', ...
    'BackgroundColor', [0.9, 0.9 0.9], ...
    'Visible', 'on', ...
    'Units', 'normalized', ...
    'Title', 'Coordinates', ...
    'FontSize', 9, ...
    'FontWeight', 'bold', ...
    'Position', position);

% error string
obj.gui.(parentStruct)(panelIndex).coordUI.errorString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Norm of Residuals:', ...
    'Position', [0.05, 0.9, stringBoxSize]);

% error display box
obj.gui.(parentStruct)(panelIndex).coordUI.errorDisplay = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'edit', ...
    'Enable', 'off', ...
    'HorizontalAlignment','left', ...
    'Units', 'normalized', ...
    'String', 'l33l', ...
    'Position', [0.3, 0.9, editBoxSize], ...
    'Callback', {@error_display_cb, obj});

% clear all button
obj.gui.(parentStruct)(panelIndex).coordUI.clearAllButton = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'Units', 'normalized', ...
    'String', 'Clear All', ...
    'Position', [0.7, 0.9, pushButtonSize], ...
    'Callback', {@clear_all_cb, obj, parentStruct, panelIndex});

% GDS device header
obj.gui.(parentStruct)(panelIndex).coordUI.deviceHeader = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'GDS device', ...
    'Position', [0.05, 0.8, stringBoxSize]);

% GDS coord. header
obj.gui.(parentStruct)(panelIndex).coordUI.coordHeader = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'GDS coord', ...
    'Position', [0.31, 0.8, stringBoxSize]);

% stage coord header
obj.gui.(parentStruct)(panelIndex).coordUI.stageHeader = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Stage coord', ...
    'Position', [0.575, 0.8, stringBoxSize]);

% set header
obj.gui.(parentStruct)(panelIndex).coordUI.setHeader = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Set', ...
    'Position', [0.825, 0.8, .1, 0.075]);

% clear header
obj.gui.(parentStruct)(panelIndex).coordUI.clearHeader = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Clear', ...
    'Position', [0.9, 0.8, .09, 0.075]);

table_element_y = 0.1;

deviceName = fieldnames(obj.devices);
devicePD = cell(length(deviceName)+1, 1);
devicePD{1} = '<Device>';
for i = 1:length(deviceName)
    devicePD{i+1} = obj.devices.(deviceName{i}).Name;
end

% GDS table loop
for i = 1:7
    % position coordinates
    x_table_coord = 0.05;
    y_table_coord = 0.7 - (0.11*(i-1));
    
    % popup menu
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,1} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','popupmenu', ...
        'HorizontalAlignment','left', ...
        'Units', 'normalized', ...
        'Position', [x_table_coord , y_table_coord, 0.2, table_element_y], ...
        'String', devicePD, ...
        'Callback', {@gds_selection_cb, obj, parentStruct, panelIndex, i});
    
    x_table_coord = x_table_coord + 0.26;
    
    % GDS x coord
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,2} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','edit', ...
        'Enable', 'off', ...
        'HorizontalAlignment','left', ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, 0.1, table_element_y], ...
        'String', '{x}');
    
    x_table_coord = x_table_coord + 0.1;
    
    % GDS y coord
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,3} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','edit', ...
        'Enable', 'off', ...
        'HorizontalAlignment','left', ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, 0.1, table_element_y], ...
        'String', '{y}');
    
    x_table_coord = x_table_coord + 0.17;
    
    % stage x coord
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,4} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','edit', ...
        'Enable', 'off', ...
        'HorizontalAlignment','left', ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, 0.1, table_element_y], ...
        'String', '{x}');
    
    x_table_coord = x_table_coord + 0.1;
    
    % stage y coord
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,5} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','edit', ...
        'Enable', 'off', ...
        'HorizontalAlignment','left', ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, 0.1, table_element_y], ...
        'String', '{y}');
    
    x_table_coord = x_table_coord + 0.15;
    
    % set radio button
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,6} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','radiobutton', ...
        'HorizontalAlignment','left', ...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, .05, table_element_y], ...
        'Callback', {@set_coord_cb, obj, parentStruct, panelIndex, i});
    
    x_table_coord = x_table_coord + 0.1;
    
    % clear radio button
    obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{i,7} = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).coordUI.mainPanel, ...
        'Style','radiobutton', ...
        'HorizontalAlignment','left', ...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized', ...
        'Position', [x_table_coord, y_table_coord, .05, table_element_y], ...
        'Callback', {@clr_coord_cb, obj, parentStruct, panelIndex, i});
end

end

%% Callbacks
function error_display_cb(hObject, eventdata, obj)

end

function clear_all_cb(~, ~, obj, parentStruct, panelIndex)
% clear both GDS and stage coords
for ii = 1:7
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,2}, 'String', ' ');
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,3}, 'String', ' ');
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,4}, 'String', ' ');
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,5}, 'String', ' ');
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,6}, 'Value', 0);
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{ii,7}, 'Value', 0);
end
try
    obj.instr.opticalStage.removeAllCoordPair;
catch ME
    rethrow(ME);
end
end

% table callbacks
function gds_selection_cb(~, ~, obj, parentStruct, panelIndex, index)
% load the gds coords for the selected device
selectedDeviceIndex = get(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 1}, 'Value');
deviceNames = get(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index,1}, 'String');
selectedDeviceName = deviceNames{selectedDeviceIndex};
if selectedDeviceIndex~=1  %the first element is not a device name but 'Device'
    dev_x = obj.devices.(selectedDeviceName).X;     % need the correct property names for coords
    dev_y = obj.devices.(selectedDeviceName).Y;
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 2}, 'String', num2str(dev_x));
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 3}, 'String', num2str(dev_y));
    %it doesn't save the coordiantes to the CoordSys class yet.
    %only set does.
end
end


function set_coord_cb(hObject, ~, obj, parentStruct, panelIndex, index)
% set the current stage coords as the gds coords
if get(hObject,'Value')
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index,7}, 'Value', 0);  %Clear radio button uncheck
    try
        [cur_x, cur_y, ~] = obj.instr.opticalStage.getPosition();
    catch ME
        %could try to fix it here or ask again
        rethrow(ME);
    end
    
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 4}, 'String', num2str(cur_x));
    set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 5}, 'String', num2str(cur_y));
    gds_x = str2double(get(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 2}, 'String'));
    gds_y = str2double(get(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 3}, 'String'));
    %update the coordsys class
    if ~isnan(gds_x) && ~isnan(gds_y) && isnumeric(gds_x) && isnumeric(gds_y)
        obj.instr.opticalStage.addCoordPair([gds_x, gds_y],[cur_x, cur_y], index);
    else
        obj.msg('coordinate pair is invalid');
        return;
    end
    %update error
    set(obj.gui.(parentStruct)(panelIndex).coordUI.errorDisplay, 'String', ...
        num2str(obj.instr.opticalStage.coordSysError));
else
    msg = 'coordinates_ui: Already set';
    obj.msg(msg);
end
end

function clr_coord_cb(~, ~, obj, parentStruct, panelIndex, index)
% clear the stage coords
set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 4}, 'String', ' ');
set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index, 5}, 'String', ' ');
%unset the radiobutton
set(obj.gui.(parentStruct)(panelIndex).coordUI.GDS_table{index,6}, 'Value', 0);
try
    obj.instr.opticalStage.removeCoordPair(index);
catch ME
    rethrow(ME);
end
%update error
set(obj.gui.(parentStruct)(panelIndex).coordUI.errorDisplay, 'String', ...
    num2str(obj.instr.opticalStage.coordSysError));
end

