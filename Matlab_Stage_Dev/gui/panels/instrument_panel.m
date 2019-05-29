function obj = instrument_panel(obj)

thisPanel = panel_index('instr');
instrNames = fieldnames(obj.instrDefaults);

STAT_TXT_FONT = 10; %set font of static text in panel

obj.gui.panel(thisPanel).titleText = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'text', ...
    'BackgroundColor', [0.9, 0.9, 0.9], ...
    'String', 'Instruments', ...
    'FontSize', 26, ...
    'ForegroundColor', [0.33, 0.12, 0.54], ...
    'Units', 'normalized', ...
    'Position', [.35, .71, .30, .10]);

%% Connection INDICATORS

x = 0.12;
y = 0.70;
spc = 0.06;
size = [0.015, 0.025];

% loop through number of instruments
for ii = 1:length(instrNames)
    connected = obj.instr.(instrNames{ii}).Connected;
    obj.gui.panel(thisPanel).indicator(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel),...
        'Style','text',...
        'BackGroundColor', [~connected, connected, 0], ...
        'Enable', 'off', ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size]);
end

%% STRINGS FOR EACH INSTRUMENT

x = 0.14;
y = 0.695;
spc = 0.06;
size = [0.12, 0.03];

for ii = 1:length(instrNames) % loop through number of instruments
    instrGroup = obj.instrDefaults.(instrNames{ii}); % get instrument group names
    
    obj.gui.panel(thisPanel).groupName(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel),...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size],...
        'String', [instrGroup{1}.Group, ': '], ....
        'FontSize', STAT_TXT_FONT, ...
        'FontWeight', 'bold');
end

%% POPUP MENUS FOR EACH INSTURMENT

x = 0.26;
y = 0.705;
size = [0.17, 0.025];

instr_connect_enable = cell(1, length(instrNames));
instr_disconnect_enable = cell(1, length(instrNames));
instr_setting_enable = cell(1, length(instrNames));
for ii = 1:length(instrNames) % loop through number of instruments
    instrGroup = obj.instrDefaults.(instrNames{ii}); % get instrument group names
    % create string list of instruments
    popup_list = {['<Select ', instrGroup{1}.Group, '>']};
    for jj = 1:length(instrGroup)
        popup_list{end+1} = instrGroup{jj}.Name;
    end
    default_user_instr = obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).(instrGroup{1}.Group);
    default_user_instr = find(strcmp(default_user_instr, popup_list) == 1);
    if isempty(default_user_instr)
        default_user_instr = 1;
    end
    popup_enable = 'on';
    if default_user_instr == 1
        instr_connect_enable{ii} = 'off';
        instr_disconnect_enable{ii} = 'off';
        instr_setting_enable{ii} = 'off';
    else
        if obj.instr.(instrNames{ii}).Connected
            instr_connect_enable{ii} = 'off';
            instr_disconnect_enable{ii} = 'on';
            instr_setting_enable{ii} = 'on';
            popup_enable = 'off';
        else
            instr_connect_enable{ii} = 'on';
            instr_disconnect_enable{ii} = 'off';
            instr_setting_enable{ii} = 'on';
            obj.instr.(instrNames{ii}) = ...
                obj.instrDefaults.(instrNames{ii}){default_user_instr -  1};
        end
        % Check whether appsettings have valid COMPort. If yes, assign it
        % to instr object
        if (~strcmp(obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort, '-'))
            obj.instr.(instrNames{ii}).Param.COMPort = ...
                obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort;
        else
            obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort = ...
                obj.instr.(instrNames{ii}).Param.COMPort;
        end
    end
    obj.gui.panel(thisPanel).instrumentPD(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel),...
        'Style', 'popupmenu', ...
        'String', popup_list, ...
        'Value', default_user_instr, ...
        'Enable', popup_enable, ...
        'FontSize', STAT_TXT_FONT, ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size], ...
        'Callback', {@popup_cb, ii});
end

%% COMPorts STRINGS

x = 0.445;
y = 0.70;
size = [0.09, 0.025];
spc = 0.06;

for ii = 1:length(instrNames)
    obj.gui.panel(thisPanel).COMString(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel),...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackGroundColor', [0.9, 0.9, 0.9], ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size],...
        'String', 'COMPort: ', ....
        'FontSize', STAT_TXT_FONT, ...
        'FontWeight', 'bold');
end

%% COMPorts EDITS

x = 0.525;
y = 0.695;
size = [0.03, 0.03];
spc = 0.06;

for ii = 1:length(instrNames)
    instrGroup = obj.instrDefaults.(instrNames{ii});
    obj.instr.(instrNames{ii}).Param.COMPort = ...
        obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort;
    obj.gui.panel(thisPanel).COMPortEdit(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel), ...
        'Style', 'edit', ...
        'String', obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort, ...
        'Visible', 'on',...
        'Enable', instr_connect_enable{ii}, ...
        'FontSize', STAT_TXT_FONT, ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size], ...
        'Callback', {@COMPort_cb, ii});
end

%% Connect BUTTONS

x = 0.58;
y = 0.69;
size = [0.09, 0.045];
spc = 0.06;

for ii = 1:length(instrNames) % loop through number of instruments
    obj.gui.panel(thisPanel).connectButton(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel), ...
        'Style', 'pushbutton', ...
        'String', 'Connect', ...
        'Visible', 'on', ...
        'Enable', instr_connect_enable{ii}, ...
        'FontSize', STAT_TXT_FONT, ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size], ...
        'Callback', {@connect_cb, ii});
end

%% Disconnect BUTTONS

x = 0.68;
y = 0.69;
size = [0.09, 0.045];
spc = 0.06;

for ii = 1:length(instrNames) % loop through number of instruments
    obj.gui.panel(thisPanel).disconnectButton(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel), ...
        'Style', 'pushbutton', ...
        'String', 'Disconnect', ...
        'Visible', 'on', ...
        'Enable', instr_disconnect_enable{ii}, ...
        'FontSize', STAT_TXT_FONT, ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size], ...
        'Callback', {@disconnect_cb, ii});
end

%% Setting BUTTONS

x = 0.78;
y = 0.69;
size = [0.09, 0.045];
spc = 0.06;

for ii = 1:length(instrNames) % loop through number of instruments
    obj.gui.panel(thisPanel).settingButton(ii) = uicontrol(...
        'Parent', obj.gui.panelFrame(thisPanel), ...
        'Style', 'pushbutton', ...
        'String', 'Setting', ...
        'Visible', 'on', ...
        'Enable', instr_setting_enable{ii}, ...
        'FontSize', STAT_TXT_FONT, ...
        'Units', 'normalized',...
        'Position', [x, y - ii*spc, size], ...
        'Callback', {@setting_button_cb, ii});
end

%% ALL BUTTONS

x = 0.60;
y = y - (length(instrNames) + 1.5) * spc;
size = [0.12, 0.045];

obj.gui.panel(thisPanel).connectAllButton = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'pushbutton', ...
    'String', 'Connect All', ...
    'Visible', 'on', ...
    'Enable', 'on', ...
    'FontSize', STAT_TXT_FONT, ...
    'Units', 'normalized',...
    'BackgroundColor', [0 1 0],...
    'Position', [x, y, size], ...
    'Callback', @connect_all_button_cb);

obj.gui.panel(thisPanel).disconnectAllButton = uicontrol(...
    'Parent', obj.gui.panelFrame(thisPanel), ...
    'Style', 'pushbutton', ...
    'String', 'Disconnect All', ...
    'Visible', 'on', ...
    'Enable', 'on', ...
    'FontSize', STAT_TXT_FONT, ...
    'BackgroundColor', [1 0 0],...
    'Units', 'normalized',...
    'Position', [x + .125, y, size], ...
    'Callback', @disconnect_all_button_cb);

checkStatus();
%% CALLBACKS
%% POPUP CALLBACKS

    function popup_cb(hObject, ~, instrIndex)
        instrGroup = obj.instrDefaults.(instrNames{instrIndex});
        valInstr = get(hObject, 'Value');
        if valInstr ~= 1
            % Instantiate the specific instrument object
            obj.instr.(instrNames{instrIndex}) = ...
                obj.instrDefaults.(instrNames{instrIndex}){valInstr - 1};
            set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).connectButton(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).disconnectButton(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).settingButton(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'String', ...
                num2str(obj.instr.(instrNames{instrIndex}).Param.COMPort));
            % Update current user setting
            obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).(instrGroup{1}.Group)...
                = obj.instr.(instrNames{instrIndex}).Name;
        else
            set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).connectButton(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).disconnectButton(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).settingButton(instrIndex), 'Enable', 'off');
            obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).(instrGroup{1}.Group)...
                = strcat('<Select ', instrGroup{1}.Group, '>');
            obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort = '-';
        end
        checkStatus();
    end
%% COMPORT CALLBACKS
    function COMPort_cb(hObject, ~, instrIndex)
       instrGroup = obj.instrDefaults.(instrNames{instrIndex});
       strCOM = get(hObject, 'String');
       if (strcmp(strCOM, '-') || ~isempty(strfind(strCOM, 'USB')))
           % Instrument is no chosen or this is an USB Port
           obj.instr.(instrNames{instrIndex}).Param.COMPort = strCOM;
           obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort = strCOM;
       else
           valCOM = str2double(strCOM);
           obj.instr.(instrNames{instrIndex}).Param.COMPort = valCOM;
           obj.AppSettings.(strcat(instrGroup{1}.Group, 'Params')).COMPort = valCOM;
       end
    end
%% CONNECT BUTTON CALLBACK
    function connect_cb(~, ~, instrIndex)
        instrType = instrNames{instrIndex};
        thisInstr = obj.instr.(instrType).Name;
        wb_msg = ['Searching ', instrType, ': ', thisInstr, ' ...'];
        wh = waitbar(0, wb_msg, ...
            'Name', 'Please Wait', ...
            'WindowStyle', 'modal');
        movegui(wh, 'center');
        if isempty((obj.instr.(instrType)))
            wb_msg = ['Unable to connect ', thisInstr];
            waitbar(0.2, wh, wb_msg);
            wb_msg = 'Connection failed!!!';
            waitbar(0, wh, wb_msg);
            pause(0.5);
            delete(wh);
            return
        end
        wb_msg = strcat(instrType, ': ', thisInstr, ' Founded!');
        waitbar(0.2, wh, wb_msg);
        wb_msg = strcat('Connecting to ', instrType, ': ', thisInstr, '...');
        waitbar(0.4, wh, wb_msg);
        % Connect instrument
        if (instrIndex ~= 2)
            obj.instr.(instrType).connect();
        elseif (instrIndex == 2) % Detector
            obj.instr.(instrType).connect(obj.instr.laser);
        end
        
        if (obj.instr.(instrType).isConnected)
            waitbar(0.6, wh);
            set(obj.gui.panel(thisPanel).indicator(instrIndex), 'BackGroundColor',[0 1 0]);
            set(obj.gui.panel(thisPanel).instrumentPD(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).connectButton(instrIndex), 'Enable', 'off');
            set(obj.gui.panel(thisPanel).disconnectButton(instrIndex), 'Enable', 'on');
            waitbar(0.8, wh);
            wb_msg = [instrType, ': ', thisInstr, ' Connected!'];
            waitbar(1, wh, wb_msg);
            pause(0.5);
            msg = [instrType, ': ', thisInstr, ' connected'];
            obj.msg(msg)
        else
            wb_msg = ['Fail to connect ', thisInstr];
            waitbar(0, wh, wb_msg);
            msg = ['Unable to connect ', thisInstr];
            obj.msg(msg)
            pause(0.5);
        end
        checkStatus();
        delete(wh);
    end

%% DISCONNECT BUTTON CALLBACK
    function disconnect_cb(~, ~, instrIndex)
        instrType = instrNames{instrIndex};
        thisInstr = obj.instr.(instrType).Name;
        wb_msg = strcat('Searching ', instrType, ': ', thisInstr, ' ...');
        wh = waitbar(0, wb_msg, ...
            'Name', 'Please Wait', ...
            'WindowStyle', 'modal');
        movegui(wh, 'center');
        if isempty((obj.instr.(instrType)))
            wb_msg = strcat('Unable to find', thisInstr);
            waitbar(0.2, wh, wb_msg);
            wb_msg = ['Failed to disconnect ', thisInstr];
            waitbar(0, wh, wb_msg);
            pause(0.5);
            delete(wh);
            return
        end
        if (~obj.instr.(instrType).isConnected)
            wb_msg = [instrType, ' is not connected'];
            waitbar(0, wh, wb_msg);
            pause(0.5);
            delete(wh);
            return
        end
        wb_msg = [instrType, ' Founded!'];
        waitbar(0.2, wh, wb_msg);
        wb_msg = ['Disconnecting ', instrType, ': ', thisInstr, '...'];
        waitbar(0.4, wh, wb_msg);
        obj.instr.(instrType).disconnect(); % Need to ponder whether pass the obj in
        if (~obj.instr.(instrType).isConnected)
            waitbar(0.6, wh);
            set(obj.gui.panel(thisPanel).indicator(instrIndex), 'BackGroundColor',[1 0 0]);
            set(obj.gui.panel(thisPanel).instrumentPD(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).connectButton(instrIndex), 'Enable', 'on');
            set(obj.gui.panel(thisPanel).disconnectButton(instrIndex), 'Enable', 'off');
            waitbar(0.8, wh);
            wb_msg = [instrType, ': ', thisInstr, ' disconnected!'];
            waitbar(1, wh, wb_msg);
            pause(0.5);
            msg = [instrType, ': ', thisInstr, ' disconnected'];
            obj.msg(msg)
        else
            wb_msg = ['Fail to disconnect ', thisInstr];
            waitbar(0, wh, wb_msg);
            msg = ['Unable to disconnect ', thisInstr];
            obj.msg(msg)
            pause(0.5);
        end
        checkStatus();
        delete(wh);
    end

%% Setting BUTTON CALLBACKS
    function setting_button_cb(~, ~, instrIndex)
        obj.instr.(instrNames{instrIndex}).settingsWin();
        set(obj.gui.panel(thisPanel).COMPortEdit(instrIndex), 'String', ...
                num2str(obj.instr.(instrNames{instrIndex}).Param.COMPort));
    end
%% ALL BUTTON CALLBACKS

    function connect_all_button_cb(~, ~)
        for instrIndex = 1:length(instrNames)
            valInstr = get(obj.gui.panel(thisPanel).instrumentPD(instrIndex), 'Value');
            if valInstr ~= 1 && ~obj.instr.(instrNames{instrIndex}).Connected;
               connect_cb([], [], instrIndex);
            end
        end
        checkStatus();
    end

    function disconnect_all_button_cb(~, ~)
        for instrIndex = 1:length(instrNames)
            valInstr = get(obj.gui.panel(thisPanel).instrumentPD(instrIndex), 'Value');
            if valInstr ~= 1 && obj.instr.(instrNames{instrIndex}).Connected;
               disconnect_cb([], [], instrIndex);
            end
        end
        checkStatus();
    end

    function checkStatus()
        set(obj.gui.nextButton, 'Enable', 'on');
        for instrIndex = 1:length(instrNames)
            valInstr = get(obj.gui.panel(thisPanel).instrumentPD(instrIndex), 'Value');
            if (valInstr ~= 1)
                instrType = instrNames{instrIndex};
               if(~obj.instr.(instrType).isConnected)
                   set(obj.gui.nextButton, 'Enable', 'off');
                   break;
               end
            end
        end
    end
end