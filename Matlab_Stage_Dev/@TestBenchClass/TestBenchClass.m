classdef TestBenchClass < handle
    % Shon Schmidt 2013
    
    properties
        
        %% object handles
        gui; % all UI elements
        instr; % all instruments
        timer;
        chip; % chip under test
        devices; % all devices on a chip
        coordsys;  %coordinate system transform
        
        %% program settings
       
        %Defautls to populate defaults
        guiDefaults;    %
        instrDefaults;  %list of intruments available
        
        %recipe file
        %  recipe.well
        %  recipe.time
        %  recipe.velocity
        %  recipe.reagent
        %  recipe.temp
        %  recipe.comment
        recipe;
        recipeFile;

        AppSettings; % active settings in the application
        
    end
    
    
    methods
        
        %% constructor
        function self = TestBenchClass
            addpath(genpath('./'));
            
            % Load Application Defaults
            ds = self.applicationDefaults();
            self.AppSettings = ds.AppSettings;
            self.guiDefaults = ds.guiDefaults;
            self.instrDefaults = ds.instrDefaults;
            
            %the saved user settings will be loaded after the startup panel
            
            % Instantiate the coordinate system class.
            %self.coordsys = CoordSysClass;  %by Jonas: is in the corvus
            %class now. 
            % Initialize the main GUI window
            self.init;
            
            self.recipe = [];
            self.recipeFile = '';
            
            self.AppSettings.Device.RatingOptions = ds.Device.RatingOptions;
            self.AppSettings.Device.ActiveDeviceList = []; % initialize?
            %DEBUG: the above settings need to be added to the update_user
            %method
        end
    end
    
    
    methods % public

        function self = load_user(self, userID)
            try
                % Load the existing user file
                userfile = strcat(self.AppSettings.path.userData, userID, '.mat');
                
                % Load all the settings for the instruments
                userobj = load(userfile);
                self.AppSettings = userobj;
                
                
                msg = sprintf('User: %s loaded!', userID);
                self.msg(msg);
                msg = sprintf('Current User: %s', userID);
                self.msg(msg);
            catch ME
                msg = strcat('ERROR: Unable to load user file: ', userID);
                self.msg(msg);
                disp(ME.message);
            end
        end
        
        function self = new_user(self, userID)
            try
                userfile = strcat(self.AppSettings.path.userData, userID, '.mat');
                if (exist(self.AppSettings.path.userData, 'dir')) ~= 7 % 7 is check for directory
                    try
                        mkdir(self.AppSettings.path.userData);
                        addpath(genpath(self.AppSettings.path.userData));
                    catch ME
                        msg = 'Cannot generate user directory!';
                        self.msg(msg);
                        disp(ME.message);
                    end
                end
                self.AppSettings.infoParams.Name = userID;              
                
                % Pass all parameters to the new user mat-file
                userobj = self.AppSettings;
                save(userfile, '-struct', 'userobj');
                
                msg = sprintf('New User: %s created!', userID);
                self.msg(msg);
                msg = sprintf('Current User: %s', userID);
                self.msg(msg);
            catch ME
                msg = sprintf('ERROR: Unable to create new user: %s', userID);
                self.msg(msg);
                disp(ME.message);
            end
        end
        
        function self = update_user(self, userID)
            try
                % Load the existing user file
                userfile = strcat(self.AppSettings.path.userData, userID, '.mat');

                % Update all parameters to the current user mat-file
                userobj = self.AppSettings;
                save(userfile, '-struct', 'userobj');
            catch ME
                msg = sprintf('ERROR: Unable to update user: %s', userID);
                self.msg(msg);
                disp(ME.message);
            end
        end
        
        function userList = getUsers(self)
            userList = self.guiDefaults.userList;
            users = dir(fullfile(self.AppSettings.path.userData, '*.mat'));
            for i = 1:length(users)
                fn = users(i,1).name; %load (username).mat
                username = fn(1:end-4); %get rid of .mat extension
                userList{end+1} = username;
            end
        end
        
        function WriteToDisk(varargin)
            
        end
        
        
        
        %% pop-up window for setting object parameters
        function obj = settingsWin(obj, paramStruct)
            numParams = length(fieldnames(obj.AppSettings.(paramStruct)));
            obj.gui.PopupWinH = dialog('WindowStyle', 'modal', ...
                'Units', 'normalized', ...
                'Resize', 'on', ...
                'Position', [.45 .75-.05*numParams .25 .05*numParams]); % need to check this
            
            % 'Position', [.45 .45 .15 .05*numParams/1.5]); % need to check this
            
            % get list of all the indices in struct
            fields = fieldnames(obj.AppSettings.(paramStruct));
            % convert struct to cell array
            cellA = struct2cell(obj.AppSettings.(paramStruct));
            
            % loop through params and create gui elements
            for ii = 1:length(fieldnames(obj.AppSettings.(paramStruct)))
                
                size = length(fieldnames(obj.AppSettings.(paramStruct)));
                
                obj.gui.paramName(ii) = uicontrol('Parent', obj.gui.PopupWinH, ...
                    'Style', 'text', ...
                    'Units', 'normalized', ...
                    'Position', [.001 .95- 0.9*ii/size .30 1/(3*numParams)], ...
                    'HorizontalAlignment', 'right', ...
                    'FontSize', 10, ...
                    'String', fields(ii));
                
                obj.gui.paramVal(ii) = uicontrol('Parent', obj.gui.PopupWinH, ...
                    'Style', 'edit', ...
                    'Units', 'normalized', ...
                    'Position', [.4 .95- 0.9*ii/size .25 1/(2*numParams)], ... %'Position', [.45 .95-ii/10 .3 .08], ...
                    'HorizontalAlignment', 'right', ...
                    'FontSize', 10, ...
                    'String', cellA{ii},...
                    'Callback', {@obj.settingsWinVal, ii, paramStruct});
            end
            
            % done button
            obj.gui.doneButton = uicontrol('Parent', obj.gui.PopupWinH, ...
                'Style', 'pushbutton', ...
                'Units', 'normalized', ...
                'Position', [.78 .05 .2 1/(2*numParams)], ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 10, ...
                'String', 'Done',...
                'Callback', @obj.settingsWinDone);
        end
        
        % settingsWinVal callback
        function obj = settingsWinVal(obj, hObject, eventData, ii, paramStruct)
            % get value
            newVal = get(hObject, 'String');
            % get list of struct fields
            fields = fieldnames(obj.AppSettings.(paramStruct));
            % set class property
            % Need to do some type checking here...
            obj.AppSettings.(paramStruct).(fields{ii}) = str2num(newVal);
        end     
    end
    
    methods (Static)
        function settingsWinDone(hObject, eventData)
            uiresume;
            delete(get(hObject, 'parent'));
            %            delete(obj.gui.PopupWinH);
        end
        
        function varargout = manageTimer(action, varargin)
            switch lower(action)
                case 'pause'
                    active_timers = timerfindall('Running', 'on');
                    numOfTimers = length(active_timers);
                    for ii=1:numOfTimers
                        stop(active_timers(ii));
                    end
                    varargout{1} = active_timers;
                case 'resume'
                    active_timers = varargin{1};
                    numOfTimers = length(active_timers);
                    for ii=1:numOfTimers
                        start(active_timers(ii));
                    end
            end
        end
    end
    
    methods (Access = private)
        function self = init(self)
            self.initialize_instr();
            self = initialize_main(self);  % init main gui window and panels
        end
        
        function self = initialize_instr(self)
            % Initiate and store user and instrument information
            instrNames = fieldnames(self.instrDefaults);
            for i = 1:length(instrNames)
                self.instr.(instrNames{i}) = self.instrDefaults.(instrNames{i}){1};
            end
        end
    end
    
    methods (Static, Access = private)
        defaultStructs = applicationDefaults();
    end
end
