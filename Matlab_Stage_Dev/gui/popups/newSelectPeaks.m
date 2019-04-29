function newSelectPeaks(obj, targetDevice)
% new select peaks popup that will graph the wavelength Vs. power output of
% each detector unit on a separate axes and allow the user to pick peaks on
% each graph to track by saving them to the device object specified
% Victor Bass 2013


% Reset device scan datas
obj.devices.(targetDevice).setProp('ScanNumber', 0);
obj.devices.(targetDevice).PeakLocations = {};
obj.devices.(targetDevice).PeakLocationsN = {};
obj.devices.(targetDevice).PeakTrackWindow = {};

%targetDevice is the name of the device 

numDetectors = obj.instr.detector.getProp('NumOfDetectors');

instructions{1} = 'Press the Start button to begin peak tracking';
instructions{2} = 'Left click near a peak to select for tracking.';
instructions{3} = 'Right click when finished';
instructions{4} = 'Click ''Done'' to save peaks';

obj.gui.popup_peaks.mainWindow = figure(...
    'Unit', 'normalized', ...
    'Position', [0, 0, 0.68, 0.72],...
    'Menu', 'None',...
    'Name', 'PEAK TRACKER',...
    'WindowStyle', 'normal',...  % normal , modal, docked.
    'Visible', 'off',...
    'NumberTitle', 'off',...
    'CloseRequestFcn', {@closeWindow});

% main panel
obj.gui.popup_peaks.peakPanel = uipanel(...
    'parent', obj.gui.popup_peaks.mainWindow,...
    'Title','',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Visible','on',...
    'Units', 'normalized', ...
    'Position', [.005, .005, .990, .990]);

% title string
obj.gui.popup_peaks.stringTitle = uicontrol(...
    'Parent', obj.gui.popup_peaks.peakPanel,...
    'Style', 'text',...
    'HorizontalAlignment','center',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'FontWeight','bold',...
    'Units', 'normalized',...
    'String','Select Peaks BETA VERSION',...
    'Position', [0.3, 0.95, 0.4, 0.025]);

% instructions string
obj.gui.popup_peaks.instr_title = uicontrol(...
    'parent', obj.gui.popup_peaks.peakPanel,...
    'Style', 'text',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'FontWeight','bold',...
    'Units', 'normalized', ...
    'Position', [.26, .9, .4, .025],...
    'String', 'INSTRUCTIONS');

% dynamic instructions box
obj.gui.popup_peaks.instructions = uicontrol(...
    'parent', obj.gui.popup_peaks.peakPanel,...
    'Style', 'text',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'FontWeight','bold',...
    'Units', 'normalized',...
    'Position', [.27, .85, .4, .025],...
    'String', instructions{1});

% save and close button
obj.gui.popup_peaks.save_and_close_button = uicontrol(...
    'parent', obj.gui.popup_peaks.peakPanel,...
    'Style', 'pushbutton',...
    'units', 'normalized',...
    'String', 'Save and Close',...
    'Enable', 'on',...
    'Position', [0.75, 0.8, 0.07, 0.03],...
    'Callback', {@save_and_close_cb, obj, targetDevice, numDetectors});

% initiate axes for plot
% obj.gui.popup_peaks.sweep_axes = axes('Parent', obj.gui.popup_peaks.peakPanel,...
%     'Units', 'normalized', ...
%     'Position', [.3, .2, .45, .60], ...
%     'Color', [.85 .85 .85], ...
%     'NextPlot', 'add', ...
%     'box', 'on');
% set(obj.gui.popup_peaks.sweep_axes, 'Color', [1,1,1]);
% xlabel(obj.gui.popup_peaks.sweep_axes,'Wavelength [nm]');
% ylabel(obj.gui.popup_peaks.sweep_axes,'Power [dBm]');

%% PLOTTING

% Get wvl and pwr ranges from a laser sweep
% Perform a Sweep
[wvlVals, pwrVals] = sweep(obj);
for kk = 1: numDetectors
    ThisSweep(kk).pwr = pwrVals(:, kk);
    ThisSweep(kk).wvl = wvlVals(:, kk);
end
obj.devices.(obj.chip.CurrentLocation).setProp('ThisSweep', ThisSweep);

% Create file path to store data
dt = datestr(now,'yyyy.mm.dd@HH.MM'); % time stamp
% create directory path to save data = <dataDir>/<chip>/<die>/<task>/<date>/
filePath = strcat(...
    obj.AppSettings.path.tempData,...
    obj.chip.Name,'\',...
    obj.AppSettings.infoParams.DieNumber,'\',...
    obj.AppSettings.infoParams.Task,'\',...
    dt,'\');
if (exist(filePath, 'dir') ~= 7) % If the directory exist, it would return 7
    mkdir(filePath);
end

params = scanParams(obj);
obj.devices.(obj.chip.CurrentLocation).checkDirectory(filePath);
obj.devices.(obj.chip.CurrentLocation).saveData(wvlVals, pwrVals, params);

% Check if data is the correct size
if length(wvlVals) ~= length(pwrVals)
    err = MException('SelectPeak:DataFormat','xdata and ydata are not the same length');
    throw(err);
end

% axes panel
obj.gui.popup_peaks.axesPanel = uipanel(...
    'parent', obj.gui.popup_peaks.peakPanel,...
    'Title', '',...
    'Unit', 'Pixels',...
    'BackgroundColor', [0.9, 0.9, 0.9],...
    'Visible', 'on',...
    'Units', 'normalized',...
    'Position', [0.01, 0.01, 0.6, 0.8]);

% Make sure each plot has a different color
colors = {'r', 'g', 'b', 'c', 'm'};
% for loop to draw axes, table, and buttons for each detector
for i = 1:numDetectors
    % draw axes
    obj.gui.popup_peaks.axesSubplot(i)= subplot(numDetectors,1,i);
    set(obj.gui.popup_peaks.axesSubplot(i), 'Parent', obj.gui.popup_peaks.axesPanel);
    xlabel('Wavelength [nm]');
    ylabel('Power [dBm]');
    plot(wvlVals(:,i), pwrVals(:,i), colors{i});
    title(strcat(['Detector ', num2str(i)]));
    
    % table to show selected wvls
    PeakLocations = {};
    
    obj.gui.popup_peaks.peaks_table(i) = uitable(...
        'Parent', obj.gui.popup_peaks.peakPanel,...
        'ColumnName', {'Wvl'},...
        'ColumnFormat',{'char'},...
        'ColumnEditable', false,...
        'Units','normalized',...
        'Position', [0.65, 0.6 - ((i-1)*0.7/numDetectors), 0.075, (0.3/numDetectors)],...
        'Data', PeakLocations,...
        'FontSize', 9,...
        'ColumnWidth', {50},...
        'CellEditCallback',{@cell_edit_cb, i},...
        'CellSelectionCallback', {@cell_sel_cb, i},...
        'Enable', 'on');
    
    % start button for peak selection
    obj.gui.popup_peaks.start_button(i) = uicontrol(...
        'Parent', obj.gui.popup_peaks.peakPanel,...
        'Style', 'pushbutton',...
        'units', 'normalized',...
        'position', [.65, 0.73 - ((i-1)*0.7/numDetectors), .075, .03],...
        'string', 'Start',...
        'Enable', 'on',...
        'callback', {@start_button_cb, obj,instructions, i});
    
    % done button for peak selection
    obj.gui.popup_peaks.done_button(i) = uicontrol(...
        'Parent', obj.gui.popup_peaks.peakPanel,...
        'Style', 'pushbutton',...
        'units', 'normalized',...
        'position', [.65, 0.7 - ((i-1)*0.7/numDetectors), .075, .03],...
        'string', 'Done',...
        'userData', false, ...
        'Enable', 'off', ...
        'callback', {@done_button_cb, obj,instructions, targetDevice, i});
end % ends for loop

%% INSTR UI PANELS

% panel position variables
panel_x_coord = 0.75;
panel_y_coord = 0.25;

small_ui_x = 0.25;
small_ui_y = 0.135;

medium_ui_x = 0.25;
medium_ui_y = 0.185;

% Optical Stage UI
if (obj.instr.opticalStage.Connected)
y_offset = optical_stage_ui(obj, obj.gui.popup_peaks.peakPanel, panel_x_coord,...
    panel_y_coord, medium_ui_x, medium_ui_y);
panel_y_coord = panel_y_coord + y_offset;
end

% Laser UI
if (obj.instr.laser.Connected)
y_offset = laser_ui(obj, obj.gui.popup_peaks.peakPanel, panel_x_coord,...
    panel_y_coord, medium_ui_x, medium_ui_y, obj.gui.popup_peaks.axesPanel);
panel_y_coord = panel_y_coord + y_offset;
end

% Detector UI
if (obj.instr.detector.Connected)
y_offset = detector_ui(obj, obj.gui.popup_peaks.peakPanel, panel_x_coord,...
    panel_y_coord, small_ui_x, small_ui_y);
panel_y_coord = panel_y_coord + y_offset;
end

set(obj.gui.popup_peaks.mainWindow, 'Visible', 'on');
movegui(obj.gui.popup_peaks.mainWindow, 'center');

end % ends newSelectPeaks

%% SELECT PEAKS FROM PLOT
function peak_selection(obj, instructions, index) % --- Vince 2013
PeakLocations = {};

% Delete the previous (if any) peak selection
delete(findobj(obj.gui.popup_peaks.axesSubplot(index), 'Marker', '+'));
set(obj.gui.popup_peaks.peaks_table(index), 'Data', {});

%this is not good: can't reset peak locations. 
dataObj = get(obj.gui.popup_peaks.axesSubplot(index),'Children');
wvlVals = get(dataObj,'XData');
pwrVals = get(dataObj,'YData');
% WinPoints = 5/(wvlVals(2)-wvlVals(1)); % window/step = num of elements: for a 2nm window;
xrange = max(wvlVals) - min(wvlVals);
tol = xrange/50;
n = 0;
hold(obj.gui.popup_peaks.axesSubplot(index), 'on');
finish = false;
while (~finish)
        [xsel, ysel, button] = ginput(1); 
        % get x,y coord of mouse cursor
        % button is an integer indicating which mouse buttons you pressed 
        % (1 for left, 2 for middle, 3 for right)        
        if (button == 1) %user - left-click
            boundary = ...
                xsel <= max(wvlVals) && xsel >= min(wvlVals) && ...
                ysel <= max(pwrVals) && ysel >= min(pwrVals);
            if (boundary) % Process data only when user click with in the proper axes
                % Limit the range of wavelength selection
                wvlVals_filter = wvlVals(abs(wvlVals - xsel) <= tol);
                pwrVals_filter = pwrVals(abs(wvlVals - xsel) <= tol);

                % Find the peak power value within the limited range above
                [y_peak, ind] = min(pwrVals_filter); % look for index of min y in range
                x_peak = wvlVals_filter(ind);

                % update plot /w X on selected point
                plot(obj.gui.popup_peaks.axesSubplot(index), x_peak, y_peak, 'r+'); % make a red-x at point
                n = n + 1;
                PeakLocations{n,1} = x_peak;
                set(obj.gui.popup_peaks.peaks_table(index), 'Data', PeakLocations);
                set(obj.gui.popup_peaks.instructions, 'String', instructions{3});
            end
        elseif (button == 2 || button == 3)  %user right or middle mouse click
           finish = true; 
        end
end
hold(obj.gui.popup_peaks.axesSubplot(index), 'off');
end

%% CALLBACK FUNCTIONS

function closeWindow(hObject,eventdata)
delete(hObject);
end

function start_button_cb(hObject, eventdata, obj, instructions, index)
set(hObject, 'Enable', 'off'); % disable the start button that was pressed
% set(obj.gui.popup_peaks.done_button(index), 'Enable', 'on');
set(obj.gui.popup_peaks.instructions, 'String', instructions{2});
set(obj.gui.popup_peaks.done_button(index), 'Enable', 'on');
peak_selection(obj,instructions, index);
end

function done_button_cb(hObject, eventdata, obj, instructions, targetDevice, index)
% save wvls (meters) of selected peaks to device object
% also find the min/max of selected peaks from all detectors and save in
% device object as start and stop wvls
obj.devices.(targetDevice).PeakLocations{index} = {};
obj.devices.(targetDevice).PeakLocationsN{index} = {};

set(obj.gui.popup_peaks.instructions, 'String', instructions{1}); % update displayed instructions
set(obj.gui.popup_peaks.start_button(index), 'Enable', 'on'); % enable start button again
wvl_data = cell2mat(get(obj.gui.popup_peaks.peaks_table(index), 'data')); % get wvl data from table
wvl_data = wvl_data; % convert nm to meters before saving
% find min and max of data
data_min = min(wvl_data);
data_max = max(wvl_data);
% save data to the device object
%device.PeakLocations.(strcat('Detector',num2str(index))) = wvl_data;
for ii = 1:length(wvl_data)
    obj.devices.(targetDevice).PeakLocations{index}{ii} = wvl_data(ii);
    obj.devices.(targetDevice).PeakLocationsN{index}{ii} = 0;
end
% determine if overall min/max is within data and set if so
% min (start wvl)
if isempty(obj.devices.(targetDevice).getProp('StartWvl')) % device property not set yet
    obj.devices.(targetDevice).setProp('StartWvl', data_min);
elseif data_min < obj.devices.(targetDevice).getProp('StartWvl') % current start higher than lowest selected peak
    obj.devices.(targetDevice).setProp('StartWvl', data_min);
end
% max (stop wvl)
if isempty(obj.devices.(targetDevice).getProp('StopWvl'))
    obj.devices.(targetDevice).setProp('StopWvl', data_max);
elseif data_max > obj.devices.(targetDevice).getProp('StopWvl')
    obj.devices.(targetDevice).setProp('StopWvl', data_max);
end

set(hObject, 'Enable', 'off'); % disable done button that was pushed
end

function save_and_close_cb(~, ~, obj, targetDevice, numDetectors)
if numDetectors > length(obj.devices.(targetDevice).PeakLocations)
   for index = length(obj.devices.(targetDevice).PeakLocations):numDetectors
       obj.devices.(targetDevice).PeakLocations{index} = {};
       obj.devices.(targetDevice).PeakLocationsN{index} = {};
   end
end
obj.devices.(targetDevice).trackPeaks();
close(obj.gui.popup_peaks.mainWindow);
obj.gui.popup_peaks = [];
end

function cell_edit_cb(hObject, eventdata, index)
end

function cell_sel_cb(hObject, eventdata, index)
end