function obj = initialize_main(obj)

% initialize object for handles
obj.gui = [];

%% Initialize the main GUI window
% Main GUI Window
obj.gui.benchMainWindow = figure(...
    'Visible', 'off', ...
    'Menu', 'None', ...
    'Name', 'Test Bench GUI', ...
    'NumberTitle', 'off', ...
    'Units', 'normalized', ...
    'Position', [0 0 .84 .84],...
    'DeleteFcn', @gui_delete);

% Bottom panel for designer usage
obj.gui.designerPanel = uipanel(...
    'Parent', obj.gui.benchMainWindow, ...
    'BackGroundColor', [0.9, 0.9, 0.9], ...
    'Units', 'normalized', ...
    'Position', [.01, .01, 0.98, .055]);


% Initialize 8 stepwise panels
obj = initialize_panels(obj);

% Initialize 8 stepwise tabs
obj = initialize_tabs(obj);

% Initialize Debug Window
obj = initialize_console(obj);

% Initialize the NEXT & BACK button
obj = initialize_NEXT_BACK(obj);

%%
% Build the first panel --- Users
obj = startup_panel(obj);

% Show the GUI window and move it to the center of the screen
movegui(obj.gui.benchMainWindow, 'center');
set(obj.gui.benchMainWindow, 'Visible', 'on');

%%  Callback functions
    function gui_delete(~, ~)
        %this needs to be written in a more consisten way
        %hack for now. make sure that the com port objects are all deleted
        instrNames = fieldnames(obj.instrDefaults);
        wb_msg = strcat('Checking instruments ...');
        wh = waitbar(0, wb_msg, ...
            'Name', 'Please Wait', ...
            'WindowStyle', 'modal');
        movegui(wh, 'center');
        for i = 1:length(instrNames)
            wb_msg = strcat('Checking connection status of ', instrNames{i}, ' ...');
            waitbar(i/10, wh, wb_msg);
            if(obj.instr.(instrNames{i}).Connected == 1)
                obj.instr.(instrNames{i}).disconnect();
                wb_msg = strcat(instrNames{i}, ' disconnected!');
                waitbar(i/10, wh, wb_msg);
            end
        end
        waitbar(1, wh, 'All instruments are dissconnected!');
        waitbar(1, wh, 'Safe to close application');
        pause(1);
        delete(wh);
        
        delete(timerfindall);
        delete(instrfindall);
        try
            delete(imaqfind);
        catch
            disp('Image Aquisition Toolbox is not installed.');
        end
        close(obj.gui.benchMainWindow);
    end

end