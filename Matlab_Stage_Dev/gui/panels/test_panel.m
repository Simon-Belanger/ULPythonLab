function obj = test_panel(obj)

set(obj.gui.nextButton, 'Enable', 'on'); % Temporary

% panel that will combine wet and dry test panel and will display elements
% based on which type of assay was selected
% Victor Bass 2013

%% SET CONSTANT PARAMETERS
thisPanel = panel_index('test');

%% DETERMINE IF WET OR DRY TEST
% get the type of test (wet or dry) from the user settings
%test_type = lower(obj.AppSettings.infoParams.Task);
test_type = obj.AppSettings.infoParams.Task;

%% DETECTOR PLOTS (WITH TABLES FOR WET TEST)
plotPanel_w = 0.7;
plotPanel_h = 0.93;

% Plotting panel for sweep scan data and/or peak tracking plot
obj.gui.panel(thisPanel).plotPanel = uipanel(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Title', 'Sweep Scan Data', ...
    'FontSize', 9, ...
    'FontWeight', 'bold', ...
    'Unit', 'normalized', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Visible', 'on', ...
    'Position', [0.01, 0.01, plotPanel_w, plotPanel_h]);

% for loop to draw axes and table for each detector
numDetectors = obj.instr.detector.getProp('NumOfDetectors');
selectedDetectors = obj.instr.detector.getProp('SelectedDetectors');
numOfSelected = sum(selectedDetectors);
if strcmpi(test_type, 'SaltSteps') || strcmpi(test_type, 'TemperatureTest')|| strcmpi(test_type, 'BioAssay')
    % for loop to draw wvl Vs. pwr plots for each detector
    plotIndex = 0;
    for i = 1:numDetectors
        if (selectedDetectors(i))
            plotIndex = plotIndex + 1;
            % draw wvl Vs. pwr plots for this scanline
            if numOfSelected == 1
                obj.gui.panel(thisPanel).sweepScanPlots(plotIndex) = ...
                    subplot(2, numOfSelected, plotIndex*2-1, 'Parent', obj.gui.panel(thisPanel).plotPanel);
            else
                obj.gui.panel(thisPanel).sweepScanPlots(plotIndex) = ...
                    subplot(numOfSelected, 2, plotIndex*2-1, 'Parent', obj.gui.panel(thisPanel).plotPanel);
            end
            title(strcat(['Detector ',num2str(i),' real-time scan']));
            xlabel('Wavelength (nm)');
            ylabel('Power (dBW)');
            
            % draw peak tracking plots for all scanlines
            if numOfSelected == 1
                obj.gui.panel(thisPanel).peakTrackPlots(plotIndex) = ...
                    subplot(2, numOfSelected, plotIndex*2, 'Parent', obj.gui.panel(thisPanel).plotPanel);
            else
                obj.gui.panel(thisPanel).peakTrackPlots(plotIndex) = ...
                    subplot(numOfSelected, 2, plotIndex*2, 'Parent', obj.gui.panel(thisPanel).plotPanel);
            end
            title(strcat(['Detector ',num2str(i),' peak tracking']));
            xlabel('Scan number');
            ylabel('Wavelength shift (pm)');
        end
    end
elseif strcmpi(test_type, 'DryTest') || strcmpi(test_type, 'WetTest')
    % Draw only wvl Vs. pwr plots
    plotIndex = 0;
    for i = 1:numDetectors
        if (selectedDetectors(i))
            plotIndex = plotIndex + 1;
            % draw wvl Vs. pwr plots
            obj.gui.panel(thisPanel).sweepScanPlots(plotIndex) = ...
                subplot(numOfSelected, 1, plotIndex);
            set(obj.gui.panel(thisPanel).sweepScanPlots(plotIndex), 'Parent', obj.gui.panel(thisPanel).plotPanel);
            title(strcat(['Detector ',num2str(i),' real-time scan']));
            xlabel('Wavelength (nm)');
            ylabel('Power (dB)');
        end
    end
else
    error('Cannot create plot windows. Unsure of test type.');
end
%% Test UI Panels
ui_x = plotPanel_w + 0.015;
ui_y = 0.01;
ui_width = 0.99 - ui_x;
ui_height = 0;
ui_position = [ui_x, ui_y, ui_width, ui_height];

% Wet or Dry test ui
% use if/else to tell which panel to draw
ui_position(4) = 0.75;
if strcmpi(test_type, 'SaltSteps') || strcmpi(test_type, 'TemperatureTest') || strcmpi(test_type, 'BioAssay')
    obj = assay_ui(...
        obj, ...
        'test', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
elseif strcmpi(test_type,'DryTest') || strcmp(test_type,'WetTest')
    obj = dry_test_ui(...
        obj, ...
        'test', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
else
    error('Selected test type not currently supported');
end

% Status and control panel
ui_position(2) = ui_position(2) + ui_position(4);
ui_position(4) = 0.94 - ui_position(2);
obj = test_control_ui(...
    obj, ...
    'test', ...
    obj.gui.panelFrame(thisPanel), ...
    ui_position);

% Laser ui
% if (obj.instr.laser.Connected)
%     ui_position(2) = ui_position(2) + ui_position(4);
%     ui_position(4) = 0.94 - ui_position(2);
%     obj = laser_ui(...
%         obj, ...
%         'test', ...
%         obj.gui.panelFrame(thisPanel), ...
%         ui_position, ...
%         obj.gui.panel(thisPanel).sweepScanPlots);
% end
end
