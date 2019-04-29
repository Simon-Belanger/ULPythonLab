function obj = initialize_NEXT_BACK(obj)

obj.gui.nextButton = uicontrol('Parent', obj.gui.benchMainWindow, ...
    'Style', 'pushbutton', ...
    'String', 'Next >', ...
    'Enable', 'off', ...
    'FontSize', 12, ...
    'Units', 'normalized', ...
    'Position', [.89, .09, .07, .05], ...
    'Callback', {@next_button_cb, obj});

obj.gui.backButton = uicontrol('Parent', obj.gui.benchMainWindow, ...
    'Style', 'pushbutton', ...
    'String', '< Back', ...
    'Visible', 'off', ...
    'Enable', 'off', ...
    'FontSize', 12, ...
    'Units', 'normalized', ...
    'Position', [.79, .09, .07, .05], ...
    'Callback', {@back_button_cb, obj});

end
%%
function next_button_cb(~, ~, obj)
set(obj.gui.nextButton, 'Enable', 'off');
set(obj.gui.backButton, 'Visible', 'on', 'Enable', 'on');
% Find the current tab and panel
currentPanel = findobj(obj.gui.panelFrame, 'flat', 'Visible', 'on');
currentTab = findobj(obj.gui.tab, 'flat', 'BackgroundColor', [0.9 0.9 0.9]);
panelIndex = find(obj.gui.panelFrame == currentPanel);
tabIndex = find(obj.gui.tab == currentTab);
% Make the current tab and panel unseen
set(currentPanel, 'Visible', 'off');
set(currentTab, 'BackgroundColor', [0.8 0.8 0.8]);
% Get the name of current panel and determine the next step
currentPanelName = panel_index(panelIndex);
switch currentPanelName
    case 'User'
        % Generate/Refresh the next panel --- Task
        obj = task_panel(obj);
    case 'Task'
        %  Generate/Refresh the next panel --- Instruments
        obj = instrument_panel(obj);
    case 'Instr'
        %  Generate/Refresh the next panel --- Mount
        obj = mount_align_panel(obj);
    case 'Mount'
        %  Generate/Refresh the next panel --- Chip Registration
        obj = register_panel(obj);
        try
            obj.instr.camera.close();
        end
    case 'Register'
        %  Generate/Refresh the next panel --- Select Devices
        obj = devices_panel(obj);
        try
            obj.instr.camera.close();
        end
    case 'Devices'
        %  Generate/Refresh the next panel --- Run Assay
        obj = test_panel(obj);
    case 'Test'
        %  Generate/Refresh the next panel --- Analyze data
        obj = analyze_panel(obj);
end
% If current panel is not yet the last panel (Analysis), make the
% next panel visible
if panelIndex < length(obj.gui.panelFrame)
    nextPanel = obj.gui.panelFrame(panelIndex + 1);
    nextTab = obj.gui.tab(tabIndex + 1);
    set(nextPanel, 'Visible', 'on');
    set(nextTab, 'BackgroundColor', [0.9 0.9 0.9]);
elseif (panelIndex + 1) == length(obj.gui.panelFrame)
    set(obj.gui.nextButton, 'Visible', 'on', 'Enable', 'off', 'String', 'Done');
end

% ---------------- Update current User parameters ----------------
userID = obj.AppSettings.infoParams.Name;
obj.update_user(userID);
end
% --------------------------------------------------------------------

function back_button_cb(~, ~, obj)
set(obj.gui.nextButton, 'Visible', 'on', 'Enable', 'on');
% Find the current tab and panel
currentPanel = findobj(obj.gui.panelFrame, 'flat', 'Visible', 'on');
currentTab = findobj(obj.gui.tab, 'flat', 'BackgroundColor', [0.9 0.9 0.9]);
panelIndex = find(obj.gui.panelFrame == currentPanel);
tabIndex = find(obj.gui.tab == currentTab);
% Make the current tab and panel unseen
set(currentPanel, 'Visible', 'off');
set(currentTab, 'BackgroundColor', [0.8 0.8 0.8]);
% If current panel is not the first panel (User), make the
% previous panel visible
if panelIndex > 1
    PreviousPanel = obj.gui.panelFrame(panelIndex - 1);
    PreviousTab = obj.gui.tab(tabIndex - 1);
    set(PreviousPanel, 'Visible', 'on');
    set(PreviousTab, 'BackgroundColor', [0.9 0.9 0.9]);
end
% Get the name of current panel and determine the next step
panelName = panel_index(panelIndex);
switch panelName
    case 'Task'
        set(obj.gui.backButton, 'Visible', 'off');
    case 'Analyze'
        set(obj.gui.nextButton, 'String', 'Next >');
    case 'Mount'
        try
            obj.instr.camera.close();
        end
    case 'Register'
        try
            obj.instr.camera.close();
        end
end
delete(allchild(currentPanel));
end

