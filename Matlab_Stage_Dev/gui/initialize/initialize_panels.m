function obj = initialize_panels(obj)

list = panel_index('all');
numOfPanels = length(list);

obj.gui.panelFrame = zeros(1, numOfPanels);

for ii = 1:numOfPanels
    obj.gui.panelFrame(ii) = uipanel(...
        'Parent', obj.gui.benchMainWindow, ...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized', ...
        'Visible', 'off', ...
        'Position', [.01, .065, 0.75, 0.925]);
    obj.gui.panel(ii) = struct();
end
end