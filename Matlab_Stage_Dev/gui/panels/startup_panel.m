function obj = startup_panel(obj)

% get the numerical index for this panel
thisPanel = panel_index('user');

%% User List
% Get available users
defaultUserList = obj.getUsers();

%%
% --------------------------- Title Text ---------------------------------
obj.gui.panel(thisPanel).titleText = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'text', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'String', 'User and Bench', ...
    'FontSize', 26, ...
    'ForegroundColor', [0.33, 0.12, 0.54], ...
    'Units', 'normalized', ...
    'Position', [.35, .66, .30, .10]);

% ----------------------------- User Popup -------------------------------
x = .37;
y = .54;
popupSize = [.26, .05];

obj.gui.panel(thisPanel).usersPopup = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'popupmenu', ...
    'String', defaultUserList, ...
    'FontSize', 12, ...
    'Units', 'normalized', ...
    'Position', [x, y, popupSize], ...
    'Callback', @users_popup_cb);

obj.gui.panel(thisPanel).userString = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'text', ...
    'String', 'User: ', ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [x - .06, y + .005, .06, .04], ...
    'BackgroundColor', [0.9, 0.9, 0.9]);

% ----------------------- Bench Revision Popup ---------------------------
obj.gui.panel(thisPanel).benchPopup = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'popupmenu', ...
    'String', obj.guiDefaults.benchList, ...
    'Enable', 'off', ...
    'FontSize', 12, ...
    'Units', 'normalized', ...
    'Position', [x, y - .08, popupSize], ...
    'Callback', @bench_selection_cb);

obj.gui.panel(thisPanel).benchString = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'text', ...
    'String', 'Bench version: ', ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [x - .13, y - .075, .13, .04], ...
    'BackgroundColor', [0.9, 0.9, 0.9] );


% Setting this panel to be visible
set(obj.gui.tabFrame(thisPanel), 'Visible', 'on')
set(obj.gui.tab(thisPanel), 'BackgroundColor', [0.9 0.9 0.9]);
set(obj.gui.panelFrame(thisPanel), 'Visible', 'on');


%% Callbacks function

    function users_popup_cb(hObject, eventData)
        % Index of user name in the popup
        valUser = get(hObject, 'Value');
        % List of all the selections
        userList = obj.getUsers();
        % The specific user ID
        userID = userList{valUser};
        
        if valUser == 1
            % Reset bench popup and disable next button
            set(obj.gui.panel(thisPanel).benchPopup, 'Value', 1);
            set(obj.gui.panel(thisPanel).benchPopup, 'Enable', 'off');
            set(obj.gui.nextButton, 'Enable', 'off');
        % -------------------------- NEW USER ----------------------------
        elseif valUser == 2
            try
                % Pop up dialog to create new user
                newUserID = userManagement('new user');
                if(~isempty(newUserID))
                    % Create defaults and save .mat file
                    obj.new_user(newUserID);
                    % Automatically choose the new user in the popup menu
                    userList = obj.getUsers();
                    userIDIndex = find(strcmp(newUserID, userList) == 1);
                    set(hObject, 'String', userList);
                    set(hObject, 'Value', userIDIndex);
                    % Enable next selection
                    set(obj.gui.panel(thisPanel).benchPopup, 'Enable', 'on');
                else
                    set(hObject, 'Value', 1);
                    set(obj.gui.panel(thisPanel).benchPopup, 'Value', 1);
                end
            catch ME
                obj.msg('Error: No New User generated!');
                disp(ME.message);
            end
        % ----------------------- DELETE USER ----------------------------
        elseif valUser == 3
            if length(userList) > 3 % Has stored user file to be deleted
                deleteList = userList(4:end);
                try
                    % pop-up window to get user name to delete
                    deleteUserID = userManagement('delete user', deleteList);
                    if(~isempty(deleteUserID))
                        % Delete user mat-file and directory
                        userfile = strcat(obj.AppSettings.path.userData, deleteUserID, '.mat');
                        delete(userfile);
                        % send msg to debug window
                        msg = sprintf('User: %s deleted.', deleteUserID);
                        obj.msg(msg);
                        % keep next selection disabled until a valid user is selected
                        set(obj.gui.panel(thisPanel).benchPopup, 'Enable', 'off');
                        % Remove deleted user name
                        deleteIndex = find(strcmp(deleteUserID, deleteList));
                        if deleteIndex ~= length(deleteList)
                            deleteList(deleteIndex:end-1) = deleteList(deleteIndex+1:end);
                        end
                        deleteList = deleteList(1:end-1);
                        userList(4:end-1) = deleteList;
                        userList = userList(1:end-1);
                        set(hObject, 'String', userList);
                    end
                    % Reset user and bench popups
                    set(hObject, 'Value', 1);
                    set(obj.gui.panel(thisPanel).benchPopup, 'Value', 1);
                catch ME
                    msg = sprintf('Error: Unable to delete user: %s', deleteUserID);
                    obj.msg(msg);
                    disp(ME.message);
                end
            else
                obj.msg('No existing user to delete');
            end
        % ---------------------- EXISTING USER ---------------------------
        else
            try
                obj.load_user(userID);
                % Enable next selection
                set(obj.gui.panel(thisPanel).benchPopup, 'Enable', 'on');
                % Automatically select bench version
                benchList = get(obj.gui.panel(thisPanel).benchPopup, 'String');
                defaultUserBench = strcat(obj.AppSettings.infoParams.School, ' biobench');
                defaultUserBench = find(strcmp(defaultUserBench, benchList));
                if isempty(defaultUserBench)
                    defaultUserBench = 1;
                end
                if defaultUserBench ~= 1
                    set(obj.gui.panel(thisPanel).benchPopup, 'Value', defaultUserBench);
                    set(obj.gui.nextButton, 'Enable', 'on');
                end
            catch ME
                disp(ME.message)
            end
        end
    end

    function bench_selection_cb(hObject, eventData)
        valBench = get(hObject, 'Value');
        strBench = get(hObject, 'String');
        strBench = strBench{valBench};
        
        if(~isempty(strfind(strBench, 'UW')))
            obj.AppSettings.infoParams.School = 'UW';
        elseif(~isempty(strfind(strBench, 'UBC')))
            obj.AppSettings.infoParams.School = 'UBC';
        end
        
        if valBench ~= 1
            set(obj.gui.nextButton, 'Enable', 'on');
        else
            set(obj.gui.nextButton, 'Enable', 'off');
        end
    end
end
