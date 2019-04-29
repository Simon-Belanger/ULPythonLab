function obj = mount_align_panel(obj)

thisPanel = panel_index('mount');

set(obj.gui.nextButton, 'Enable', 'on'); % Temporary

%% INSTR UI PANELS
% ui panel parameters (size)
camera_width = 0.63;
camera_height = 0.91;
ui_x = camera_width + 0.015;
ui_y = 0.02;
ui_width = 0.99 - ui_x;
ui_height = 0;
ui_position = [ui_x, ui_y, ui_width, ui_height];

% Microscope Camera ui Panel
obj = camera_ui(...
    obj, ...
    'mount', ...
    obj.gui.panelFrame(thisPanel), ...
    [.01, .02, camera_width, camera_height]);

% Fluidic Pump ui Panel
if (obj.instr.pump.Connected)
    ui_position(4) = 0.16;
    obj = pump_ui(...
        obj, ...
        'mount', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
end

% Fluidic Stage ui
if (obj.instr.fluidicStage.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.16;
    obj = fluidic_tray_ui(...
        obj, ...
        'mount', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
end

% Optical Stage ui
if (obj.instr.opticalStage.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.26;
    obj = optical_stage_ui(...
        obj, ...
        'mount', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
end

% TEC ui
if (obj.instr.thermalControl.Connected)
    ui_position(2) = ui_position(2) + ui_position(4);
    ui_position(4) = 0.16;
    obj = TEC_ui(...
        obj, ...
        'mount', ...
        obj.gui.panelFrame(thisPanel), ...
        ui_position);
end
end