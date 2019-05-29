% obj is the main testbench object
% --- build up a Assay control ui in the assigned panel (or popup)
% parentName is a string describing of the parent panel (or popup)
% --- 1. For popup: should be like 'manual', 'selectPeaks' ...
% --- 2. For panel: should be the same as in panel_index function
% parentObj is the parent object for the ui (type: double)
% Victor Bass 2013;
% Modified by Vince Wu - Nov 2013

function obj = assay_ui(obj, parentName, parentObj, position)

parentStruct = getParentStruct(parentName);
if (~isempty(strfind(parentStruct, 'panel')))
    panelIndex = str2double(parentStruct(end - 1));
    parentStruct = parentStruct(1:end - 3);
else
    panelIndex = 1;
end

%% Assay Panel
% panel element size variables
stringBoxSize = [0.45, 0.03];
pushButtonSize = [0.20, 0.05];
editBoxSize = [0.25, 0.03];

%% parent panel
obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel = uipanel(...
    'Parent', parentObj, ...
    'Unit', 'Pixels', ...
    'Units', 'normalized', ...
    'Visible', 'on', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Title', 'Assay', ...
    'FontSize', 9, ...
    'FontWeight', 'Bold', ...
    'Position', position);

%% settings button
obj.gui.(parentStruct)(panelIndex).assayUI.settingsButton = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'String', 'Settings', ...
    'FontSize', 9, ...
    'Position', [0.766, 0.943, pushButtonSize], ...
    'Callback', {@settings_button_cb, obj});

% %% optimize sweep range string
% obj.gui.(parentStruct)(panelIndex).assayUI.optimizeString = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'text', ...
%     'HorizontalAlignment','left', ...
%     'BackgroundColor', [0.9, 0.9, 0.9], ...
%     'Units', 'normalized', ...
%     'String', 'Optimize Sweep Range:', ...
%     'FontSize', 9, ...
%     'Position', [0.01, 0.89, stringBoxSize]);
%
% % optimize checkbox
% obj.gui.(parentStruct)(panelIndex).assayUI.optimizeCheckbox = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'checkbox', ...
%     'BackgroundColor', [0.9, 0.9, 0.9], ...
%     'Enable', 'on', ...
%     'Units', 'normalized', ...
%     'Position', [0.425, 0.895, 0.1, 0.1], ...
%     'Callback', {@optimize_checkbox_cb, obj});


% %% Manually switch reagents string
% % determine if more than one device is being tested, if so, display option
% deviceName = fieldnames(obj.devices);
% devicesToTest = 0;
% for i = 1:length(deviceName)
%     if obj.devices.(deviceName{i}).getProp('Selected')
%         devicesToTest = devicesToTest + 1;
%     end
% end
%
% if devicesToTest > 1
%     obj.gui.(parentStruct)(panelIndex).assayUI.batchTestingString = uicontrol(...
%         'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%         'Style', 'text', ...
%         'HorizontalAlignment','left', ...
%         'BackgroundColor', [0.9, 0.9, 0.9], ...
%         'Units', 'normalized', ...
%         'String', 'Manually Switch Reagents:', ...
%         'Enable', 'on', ...
%         'FontSize', 9, ...
%         'Position', [0.01, 0.71, stringBoxSize]);
%
%     obj.gui.(parentStruct)(panelIndex).assayUI.batchTestingCheckbox = uicontrol(...
%         'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%         'Style', 'checkbox', ...
%         'BackgroundColor', [0.9, 0.9, 0.9], ...
%         'Enable', 'on', ...
%         'Units', 'normalized', ...
%         'Position', [0.425, 0.72, 0.1, 0.1], ...
%         'Callback', {@batch_testing_checkbox_cb, obj});
%
% end

%% recipe string
obj.gui.(parentStruct)(panelIndex).assayUI.recipeString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style', 'text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'String', 'Recipe File:', ...
    'FontSize', 9, ...
    'Position', [0.01, 0.951, stringBoxSize]);

% filename display box
obj.gui.(parentStruct)(panelIndex).assayUI.fileNameEdit = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style', 'edit', ...
    'BackGroundColor', [0.8, 0.8, 0.8], ...
    'Enable', 'on', ...
    'HorizontalAlignment','left', ...
    'Units', 'normalized', ...
    'FontSize', 9, ...
    'String', obj.recipeFile,...
    'Position', [0.23, 0.952, stringBoxSize]);

% % recipe load button
% obj.gui.(parentStruct)(panelIndex).assayUI.loadRecipeEdit = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'pushbutton', ...
%     'Enable', 'on', ...
%     'Units', 'normalized', ...
%     'FontSize', 9, ...
%     'String', 'Load Recipe', ...
%     'Position', [0.72, 0.65, pushButtonSize], ...
%     'Callback', {@load_recipe_cb, obj, parentStruct});

obj.gui.(parentStruct)(panelIndex).assayUI.loadRecipe = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style', 'pushbutton', ...
    'CData',  iconRead(fullfile('icons', 'file_open.png')),...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [.68, .951, .066, .035], ...
    'Callback', {@load_recipe_cb, obj, parentStruct, panelIndex});

% %% current reagent string
% obj.gui.(parentStruct)(panelIndex).assayUI.currentReagentString = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'text', ...
%     'HorizontalAlignment','left', ...
%     'BackgroundColor', [0.9, 0.9, 0.9], ...
%     'Units', 'normalized', ...
%     'String', 'Current Reagent:', ...
%     'FontSize', 9, ...
%     'Position', [0.01, 0.54, stringBoxSize]);
%
% % current reagent value box
% obj.gui.(parentStruct)(panelIndex).assayUI.reagentValue = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'text', ...
%     'Enable', 'on', ...
%     'Units', 'normalized', ...
%     'FontSize', 9, ...
%     'Position', [0.15, 0.56, 1.2*editBoxSize]);
%
% % time remaining string
% obj.gui.(parentStruct)(panelIndex).assayUI.timeRemainingString = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'text', ...
%     'HorizontalAlignment','left', ...
%     'BackgroundColor', [0.9, 0.9, 0.9], ...
%     'Units', 'normalized', ...
%     'String', 'Reagent Time Remaining:', ...
%     'FontSize', 9, ...
%     'Position', [0.47, 0.54, stringBoxSize]);
%
% % time value box
% obj.gui.(parentStruct)(panelIndex).assayUI.timeValue = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style', 'text', ...
%     'Enable', 'off', ...
%     'Units', 'normalized', ...
%     'FontSize', 9, ...
%     'Position', [0.7, 0.56, editBoxSize]);

%% pumped volume string
obj.gui.(parentStruct)(panelIndex).assayUI.pumpedVolumeString = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style','text', ...
    'BackgroundColor',[0.9 0.9 0.9 ], ...
    'HorizontalAlignment','left', ...
    'Units', 'normalized', ...
    'Position', [.01, .90, stringBoxSize], ...
    'String','Pumped Vol(uL):', ...
    'FontSize', 9);

% pumped volume display box
obj.gui.(parentStruct)(panelIndex).assayUI.pumpedVolumeDisp = uicontrol(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'Style','text', ...
    'Enable', 'on', ...
    'Units', 'normalized', ...
    'Position', [.331, .90, editBoxSize], ...
    'String', '0.0');

% % pumped volume limit string
% obj.gui.(parentStruct)(panelIndex).assayUI.limitVolumeSring = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style','text', ...
%     'BackgroundColor',[0.9 0.9 0.9 ], ...
%     'HorizontalAlignment','left', ...
%     'Units', 'normalized', ...
%     'Position', [.55, .45, stringBoxSize(1)/2, stringBoxSize(2)], ...
%     'String','Limit (uL):', ...
%     'FontSize', 9);
%
% % pumped volume limit value
% obj.gui.(parentStruct)(panelIndex).assayUI.limitVolumeDisp = uicontrol(...
%     'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
%     'Style','text', ...
%     'Enable', 'on', ...
%     'Units', 'normalized', ...
%     'Position', [.7, .47, editBoxSize]);

%% use fast il engine string
% only display and enable if N7744x installed is available
if strcmp(obj.instr.detector.Name, 'Agilent Detector N7744A')
    obj.gui.(parentStruct)(panelIndex).assayUI.fastIL_engine_string = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
        'Style', 'text', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized', ...
        'String', 'Use Fast IL engine:', ...
        'FontSize', 9, ...
        'Enable', 'on', ...
        'Position', [0.01, 0.854, stringBoxSize]);
    
    obj.gui.(parentStruct)(panelIndex).assayUI.fastIL_engine_checkbox = uicontrol(...
        'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
        'Style', 'checkbox', ...
        'BackgroundColor', [0.9, 0.9, 0.9], ...
        'Enable', 'on', ...
        'Units', 'normalized', ...
        'Position', [0.36, 0.846, 0.05, 0.05], ...
        'Callback', {@fast_IL_engine_checkbox_cb, obj});
else
    obj.AppSettings.AssayParams.UseFastILEngine = 0;
end

%% recipe summary table
if obj.AppSettings.AssayParams.TranslateRecipeTimeToSweeps
    colNamesRecipeSummary =  {'Sweeps Left','Reagent','Velocity','Well','Temp','RI','Comment'};
else
    colNamesRecipeSummary =  {'Time Left','Reagent','Velocity','Well','Temp','RI','Comment'};
end
colFormatRecipeSummary = {'char','char','char','char','char','char','char'};
colEditableRecipeSummary = [false,false,false,false,false,false,false];
colWidthRecipeSummary = {75,80,50,40,45,50,200};

obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable = [];

obj.gui.(parentStruct)(panelIndex).assayUI.recipeSummaryTable = uitable(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'ColumnName', colNamesRecipeSummary, ...
    'ColumnFormat', colFormatRecipeSummary, ...
    'ColumnEditable', colEditableRecipeSummary, ...
    'Units','normalized', ...
    'Position', [0.01, 0.47, 0.98, 0.38], ...
    'Data', obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable, ...
    'FontSize', 9, ...
    'ColumnWidth',colWidthRecipeSummary, ...
    'Enable','on', ...
    'Visible', 'on');

if (~isempty(obj.recipeFile) && ~isempty(obj.recipe))
    createRecipeTable(obj, parentStruct, panelIndex)
end

%% test summary table
colNamesTestSummary =  {'Device ID', 'Status', 'Comment'};
colFormatTestSummary = {'char',      'char',   'char'};
colEditableTestSummary = [false,      false,   false];
colWidthTestSummary = {100,     75,      200};

deviceName = fieldnames(obj.devices);
% need to make summary table accessable to scripts to update status column from scripts
obj.gui.(parentStruct)(panelIndex).assayUI.deviceTable = {};
table_index = 0;

% get a list of devices to be tested
testStatus = {'Untested', 'In progress', 'Done'};
for i = 1:length(deviceName)
    if obj.devices.(deviceName{i}).getProp('Selected')
        table_index = table_index + 1;
        obj.gui.(parentStruct)(panelIndex).assayUI.deviceTable{table_index, 1} = ...
            obj.devices.(deviceName{i}).Name;
        obj.gui.(parentStruct)(panelIndex).assayUI.deviceTable{table_index, 2} = ...
            testStatus{obj.devices.(deviceName{i}).getProp('TestStatus') + 1};
        obj.gui.(parentStruct)(panelIndex).assayUI.deviceTable{table_index, 3} = ...
            obj.devices.(deviceName{i}).Comment;
    end
end

obj.gui.(parentStruct)(panelIndex).assayUI.resultTable = uitable(...
    'Parent', obj.gui.(parentStruct)(panelIndex).assayUI.mainPanel, ...
    'ColumnName', colNamesTestSummary, ...
    'ColumnFormat', colFormatTestSummary, ...
    'ColumnEditable', colEditableTestSummary, ...
    'Units','normalized', ...
    'Position', [0.01, 0.01, 0.98, 0.455], ...
    'Data', obj.gui.(parentStruct)(panelIndex).assayUI.deviceTable, ...
    'FontSize', 9, ...
    'ColumnWidth',colWidthTestSummary, ...
    'Enable','on', ...
    'Visible', 'on');

% Popup window to load recipe file
if ~isstruct(obj.recipe) % a recipe file has NOT been loaded already
    load_recipe_cb([], [], obj, parentStruct, panelIndex)
    settings_button_cb([], [], obj);
end

end

%% Callbacks
function settings_button_cb(~, ~, obj)
obj.settingsWin('AssayParams');
end

%     function optimize_checkbox_cb(hObject, ~, obj)
%         state = get(hObject, 'UserData');
%         if state
%             set(hObject, 'UserData',0);
%             obj.AppSettings.Test.OptimizeSweepRange = 0;
%         else
%             set(hObject, 'UserData',1);
%             obj.AppSettings.Test.OptimizeSweepRange = 1;
%         end
%     end

function fast_IL_engine_checkbox_cb(hObject, ~, obj)
state = get(hObject, 'UserData');
if state
    set(hObject, 'UserData',0);
    obj.AppSettings.AssayParams.UseFastILEngine = 0;
else
    set(hObject, 'UserData',1);
    obj.AppSettings.AssayParams.UseFastILEngine = 1;
end
end

%     function batch_testing_checkbox_cb(hObject, ~, obj)
%         state = get(hObject, 'UserData');
%         if state
%             set(hObject, 'UserData',0)
%             obj.AppSettings.Test.BatchTesting = 1;
%         else
%             set(hObject, 'UserData',1)
%             obj.AppSettings.Test.BatchTesting = 1;
%         end
%     end

function load_recipe_cb(~, ~, obj, parentStruct, panelIndex)
[obj.recipeFile, path] = uigetfile('*.txt', 'Select the recipe file.');
if ~isequal(obj.recipeFile, 0) && ~isequal(path, 0)
    fn = strcat(path, obj.recipeFile);
    obj.recipe = load_recipe(fn);
    % recipe loaded, display filename
    createRecipeTable(obj, parentStruct, panelIndex);
end
end

function createRecipeTable(obj, parentStruct, panelIndex)
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable = ...
    cell(length(obj.recipe.reagent), length(fieldnames(obj.recipe)));

if obj.AppSettings.AssayParams.TranslateRecipeTimeToSweeps
    obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 1) = ...
        num2cell(round(obj.recipe.time));
else
    obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 1) = ...
        num2cell(obj.recipe.time);
end

obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 2) = ...
    obj.recipe.reagent;
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 3) = ...
    num2cell(obj.recipe.velocity);
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 4) = ...
    num2cell(obj.recipe.well);
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 5) = ...
    num2cell(obj.recipe.temp);
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 6) = ...
    num2cell(obj.recipe.ri);
obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable(:, 7) = ...
    obj.recipe.comment;

set(obj.gui.(parentStruct)(panelIndex).assayUI.recipeSummaryTable, ...
    'Data', ...
    obj.gui.(parentStruct)(panelIndex).assayUI.recipeTable);
set(obj.gui.(parentStruct)(panelIndex).assayUI.fileNameEdit, ...
    'String', ...
    obj.recipeFile);
end