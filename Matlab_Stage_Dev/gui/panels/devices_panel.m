function obj = devices_panel(obj)

set(obj.gui.nextButton, 'Enable', 'on'); % Temporary

thisPanel = panel_index('devices');

%% activeDeviceList
% create a local variable to keep track of which devices are active
deviceList = fieldnames(obj.devices);
% activeDeviceList needs to be stored in a either a graphics handle (like
% user, gui, or appData) or as a property in the testbench class since
% callbacks can't return values
obj.AppSettings.Device.ActiveDeviceList = deviceList; %initial values

stringBoxSize = [0.08, 0.03];
editBoxSize = [0.066, 0.035];
pushButtonSie = [0.068, 0.04];
%% SELECT DEVICES
obj.gui.panel(thisPanel).selectDeviceStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.08, 0.85, 0.25, 0.03],...
    'String', 'Select Devices:', ....
    'FontSize', 11, ...
    'FontWeight', 'bold');

%Mode string
obj.gui.panel(thisPanel).modeStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.1, 0.805, stringBoxSize],...
    'String', 'Mode:', ....
    'FontSize', 10);

%Device ID string
obj.gui.panel(thisPanel).deviceNameStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.18, 0.805, stringBoxSize],...
    'String', 'Name:', ....
    'FontSize', 10);

% Comment string
obj.gui.panel(thisPanel).commentStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.26, .805, stringBoxSize],...
    'String', 'Comment:', ....
    'FontSize', 10);

% Type string
obj.gui.panel(thisPanel).typeStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.37, 0.805, stringBoxSize],...
    'String', 'Type:', ....
    'FontSize', 10);

% rating string
obj.gui.panel(thisPanel).ratingStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized',...
    'Position', [0.45, 0.805, stringBoxSize],...
    'String', 'Rating:', ....
    'FontSize', 10);

%% text edit boxes
%Mode edit box
obj.gui.panel(thisPanel).modeEdit = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','edit',...
    'Units', 'normalized',...
    'Position', [0.1, 0.77, editBoxSize]);

%Device ID edit box
obj.gui.panel(thisPanel).deviceNameStr = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','edit',...
    'Units', 'normalized',...
    'Position', [0.18, 0.77, editBoxSize]);

%Comment edit box
obj.gui.panel(thisPanel).commentEdit = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','edit',...
    'Units', 'normalized',...
    'Position', [0.26, 0.77, 0.093, 0.035]);

% Type edit box
obj.gui.panel(thisPanel).typeEdit = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','edit',...
    'Units', 'normalized',...
    'Position', [0.37, 0.77, editBoxSize]);

% Rating edit box
obj.gui.panel(thisPanel).rating_edit = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','edit',...
    'Units', 'normalized',...
    'Position', [0.45, 0.77, editBoxSize]);


%% Buttons
% Filter list button
obj.gui.panel(thisPanel).filterButton = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','pushbutton',...
    'Units', 'normalized',...
    'Position', [0.54, 0.77, pushButtonSie],...
    'String','Filter',...
    'Callback',{@filter_devices_cb, obj, thisPanel});

% Clear filter button
obj.gui.panel(thisPanel).filter_clr_button = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','pushbutton',...
    'Units', 'normalized',...
    'Position', [0.615, 0.77, pushButtonSie],...
    'String','Clear Filter',...
    'Callback',{@clear_filters_cb, obj, thisPanel});

% Select all button
obj.gui.panel(thisPanel).sel_all_button = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','pushbutton',...
    'Units', 'normalized',...
    'Position', [0.69, 0.77, pushButtonSie],...
    'String','Select all',...
    'Callback',{@select_all_devices_cb, obj, thisPanel});

% Clear all button
obj.gui.panel(thisPanel).clr_all_button = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel),...
    'Style','pushbutton',...
    'Units', 'normalized',...
    'Position', [0.765, 0.77, pushButtonSie],...
    'String','Clear all',...
    'Callback',{@clear_all_cb, obj, thisPanel});

%% DEVICE TABLE

% disable table (esp 'move to' and 'select for test' checkbox) if the user
% has not specified a current location (device)
if strcmp(obj.chip.CurrentLocation,'')
    enableTable = 'off';
    msg = 'No current location specified. Table disabled.';
    obj.msg(msg);
else
    enableTable = 'on';
end

% create table columns
% column number    1       2        3          4          5          6       7          8       9         10
columnNames =    {'Name', 'Peaks', 'Test',    'X',       'Y',       'Mode', 'Wvl',     'Type', 'Comment', 'Rating'};
columnFormat =   {'char', 'char',  'logical', 'numeric', 'numeric', 'char', 'numeric', 'char', 'char',    'char'};
columnEditable = [false   false    true       false      false      false   false      false   false      false];
columnWidth =    {150     52       40         50         50         40      40         40      150        75};

% initialize table
% rows = length(obj.AppSettings.Device.ActiveDeviceList);
% cols = length(columnNames);
table = updateTable(obj);

obj.gui.panel(thisPanel).hAutoDeviceTable = uitable(...,
    'parent', obj.gui.panelFrame(thisPanel),...
    'ColumnName', columnNames,...
    'ColumnFormat',columnFormat,...
    'ColumnEditable', columnEditable,...
    'Units','normalized',...
    'Position', [0.08, 0.05, 0.87, 0.7],...
    'Data', table,...
    'Enable', enableTable, ...
    'FontSize', 9,...
    'ColumnWidth',columnWidth,...
    'CellEditCallback',{@cell_edit_cb},...
    'CellSelectionCallback', {@cell_select_cb, obj, thisPanel});
end

%% CALLBACKS
function table = updateTable(obj)

activeDeviceList = obj.AppSettings.Device.ActiveDeviceList;

% read through all the device objects to get their properties and
% selection state and create the table to display
rows = length(activeDeviceList);
cols = 10;
table = cell(rows,cols);

for ii = 1:length(activeDeviceList)
    
    if obj.devices.(activeDeviceList{ii,1}).getProp('Selected')
        %         disp(activeDeviceList{ii,1});
        %         disp('true')
        selectedValue = true;
    else
        %         disp('false')
        selectedValue = false;
    end
    
    table{ii,1} = strtrim(obj.devices.(activeDeviceList{ii,1}).Name);
    table{ii,2} = 'SELECT';
    table{ii,3} = selectedValue;
    table{ii,4} = num2str(obj.devices.(activeDeviceList{ii,1}).X);
    table{ii,5} = num2str(obj.devices.(activeDeviceList{ii,1}).Y);
    table{ii,6} = strtrim(obj.devices.(activeDeviceList{ii,1}).Mode);
    table{ii,7} = num2str(obj.devices.(activeDeviceList{ii,1}).Wvl);
    table{ii,8} = strtrim(obj.devices.(activeDeviceList{ii,1}).Type);
    table{ii,9} = strtrim(obj.devices.(activeDeviceList{ii,1}).Comment);
    table{ii,10} = strtrim(obj.devices.(activeDeviceList{ii,1}).Rating);
end
end


%%
function filterTable(obj, thisPanel)

%     % Load file based on selected chip architecture
%     fn = strcat(obj.user.appSettings.infoParams.ChipArchitecture,'.txt');
%     chip_data = load_devices(obj, fn);

modeFilter = strtrim(get(obj.gui.panel(thisPanel).modeEdit,'String'));
devIDFilter = strtrim(get(obj.gui.panel(thisPanel).deviceNameStr,'String'));
commentFilter = strtrim(get(obj.gui.panel(thisPanel).commentEdit,'String'));
typeFilter = strtrim(get(obj.gui.panel(thisPanel).typeEdit,'String'));
ratingFilter = strtrim(get(obj.gui.panel(thisPanel).rating_edit,'String'));

% get array with value for each device for filtering devices to show in
% table on devices panel

deviceList = fieldnames(obj.devices);

% strtrim() removes leading and trailing whitespace
% regexp(str, ',', 'split') splits the str into substrings at ','
% lets the user enter multiple filters separated by commas in GUI and
% breaks them up into elements of all_Filters arrays

% clear and initialize
numberOfDevices = length(deviceList);
selectedDeviceList = zeros(numberOfDevices);

if (~isempty(modeFilter))
    if (strcmp(modeFilter(end), '*'))
        modeFilter = modeFilter(1:end-1);
    end
    if (strcmp(modeFilter(1), '*'))
        modeFilter = modeFilter(2:end);
    end
    all_modeFilters = strtrim(regexp(modeFilter, ',', 'split'));
    for k = 1:length(all_modeFilters)
        for kk = 1:length(deviceList)
            if strfind(lower(obj.devices.(deviceList{kk}).Mode), lower(all_modeFilters{k}))
                selectedDeviceList(kk) = selectedDeviceList(kk) + 1;
            end
        end
    end
else
    selectedDeviceList = selectedDeviceList + 1;
end

if (~isempty(devIDFilter))
    if (strcmp(devIDFilter(end), '*'))
        devIDFilter = devIDFilter(1:end-1);
    end
    if (strcmp(devIDFilter(1), '*'))
        devIDFilter = devIDFilter(2:end);
    end
    all_devIDFilters = strtrim(regexp(devIDFilter, ',', 'split'));
    for k = 1:length(all_devIDFilters)
        for kk = 1:length(deviceList)
            if strfind(lower(obj.devices.(deviceList{kk}).Name), lower(all_devIDFilters{k}))
                selectedDeviceList(kk) = selectedDeviceList(kk) + 1;
            end
        end
    end
else
    selectedDeviceList = selectedDeviceList + 1;
end

if (~isempty(commentFilter))
    if (strcmp(commentFilter(end), '*'))
        commentFilter = commentFilter(1:end-1);
    end
    if (strcmp(commentFilter(1), '*'))
        commentFilter = commentFilter(2:end);
    end
    all_commentFilters = strtrim(regexp(commentFilter, ',', 'split'));
    for k = 1:length(all_commentFilters)
        for kk = 1:length(deviceList)
            if strfind(lower(obj.devices.(deviceList{kk}).Comment), lower(all_commentFilters{k}))
                selectedDeviceList(kk) = selectedDeviceList(kk) + 1;
            end
        end
    end
else
    selectedDeviceList = selectedDeviceList + 1;
end

if (~isempty(typeFilter))
    if (strcmp(typeFilter(end), '*'))
        typeFilter = typeFilter(1:end-1);
    end
    if (strcmp(typeFilter(1), '*'))
        typeFilter = typeFilter(2:end);
    end
    all_typeFilters = strtrim(regexp(typeFilter, ',', 'split'));
    for k = 1:length(all_typeFilters)
        for kk = 1:length(deviceList)
            if strfind(lower(obj.devices.(deviceList{kk}).Type), lower(all_typeFilters{k}))
                selectedDeviceList(kk) = selectedDeviceList(kk) + 1;
            end
        end
    end
else
    selectedDeviceList = selectedDeviceList + 1;
end

if (~isempty(ratingFilter))
    if (strcmp(ratingFilter(end), '*'))
        ratingFilter = ratingFilter(1:end-1);
    end
    if (strcmp(ratingFilter(1), '*'))
        ratingFilter = ratingFilter(2:end);
    end
    all_ratingFilters = strtrim(regexp(ratingFilter, ',', 'split'));
    for k = 1:length(all_ratingFilters)
        for kk = 1:length(deviceList)
            if strfind(lower(obj.devices.(deviceList{kk}).Rating), lower(all_ratingFilters{k}))
                selectedDeviceList(kk) = selectedDeviceList(kk) + 1;
            end
        end
    end
else
    selectedDeviceList = selectedDeviceList + 1;
end

numberOfDevices = length(find(selectedDeviceList >= 5));
% initialize obj.AppSettings.Device.ActiveDeviceList
obj.AppSettings.Device.ActiveDeviceList = cell(numberOfDevices, 1);

% Create updated deviceList for table
index = 1;
for kk = 1:length(deviceList)
    if selectedDeviceList(kk) >= 5
        %        obj.AppSettings.Device.ActiveDeviceList = cell(deviceList(kk));
        obj.AppSettings.Device.ActiveDeviceList(index) = deviceList(kk);
        index = index + 1;
    end
end
end


%% SELECT DEVICES CALLBACKS

function filter_devices_cb(hObject, eventdata, obj, thisPanel)
filterTable(obj, thisPanel); % generate active device list
table = updateTable(obj); % update device table accordingly
% update table
set(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data', table);
end

function clear_filters_cb(hObject, eventdata, obj, thisPanel)
% clear filter fields
set([obj.gui.panel(thisPanel).modeEdit,...
    obj.gui.panel(thisPanel).commentEdit,...
    obj.gui.panel(thisPanel).deviceNameStr,...
    obj.gui.panel(thisPanel).typeEdit,...
    obj.gui.panel(thisPanel).rating_edit], 'String', '');
% reset activeDeviceList
obj.AppSettings.Device.ActiveDeviceList = fieldnames(obj.devices);
table = updateTable(obj); % update device table accordingly
% update table
set(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data', table);
end

function select_all_devices_cb(hObject, eventdata, obj, thisPanel)
% loop through all active devices and set 'selected' property
for jj = 1:length(obj.AppSettings.Device.ActiveDeviceList)
    obj.devices.(obj.AppSettings.Device.ActiveDeviceList{jj}).setProp('Selected', 1); % select
end
% update table
table = updateTable(obj); % update device table accordingly
% update table
set(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data', table);
end

function clear_all_cb(hObject, eventdata, obj, thisPanel)
% loop through all active devices and set 'selected' property
for jj = 1:length(obj.AppSettings.Device.ActiveDeviceList)
    obj.devices.(obj.AppSettings.Device.ActiveDeviceList{jj}).setProp('Selected', 0); % de-select
end
% update table
table = updateTable(obj); % update device table accordingly
% update table
set(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data', table);
end

function cell_edit_cb(hObject, eventdata) end

function cell_select_cb(hObject, eventdata, obj, thisPanel)
thisPanel = panel_index('devices');
if numel(eventdata.Indices)~=0
    row = eventdata.Indices(1);
    column = eventdata.Indices(2);
    switch column
        case 2 % select peaks
            % check for current location
            if strcmp(obj.chip.CurrentLocation, '') % no location specified
                msg = 'No device location specified. Select one with the optical stage UI.';
                obj.msg(msg);
            else % move to new device
                currentDevice = obj.devices.(obj.chip.CurrentLocation);
                data = get(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data');
                targetDevice = obj.devices.(data{row,1}); %col 1 has name
                
                obj = moveToDevice(obj, currentDevice, targetDevice);
                fine_align(obj);
                % Select Peak Popup
                selectPeaks(obj, targetDevice.Name);
                
                targetDevice.setProp('Selected', 1);
                
                table = updateTable(obj);
                % update table
                set(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data', table);
            end
            
        case 3 % select for testing
            % Delay time for logic value to pass into data table
            pause(0.5)
            table = get(obj.gui.panel(thisPanel).hAutoDeviceTable, 'Data');
            selected = double(table{row, column});
            obj.devices.(obj.AppSettings.Device.ActiveDeviceList{row, 1}).setProp('Selected', selected);
    end
end
end
