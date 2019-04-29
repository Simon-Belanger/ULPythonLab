classdef ChipClass < handle
    
    properties
        % devices
        DevicesList;
        AlignmentDevices;
        FunctionalDevices;
        TestStructures;
        BarCode;
        Mode;
        UntestedDevices;
        GoodDevices;
        BadDevices;
        TestPassThreshold;
        CurrentLocation; % current device
        
        % chip-specific
        Name;
        DeviceFile;
        DeviceData;
        DieID;
        
        FabricationDate;
        Designer;
        gdsFile;
        
        % history
        HistoryFile;
    end
    
    methods
        %% constructor
        function self = ChipClass(varargin)
            % Set default properties for this class
            benchObj = varargin{1};
            self.Name = varargin{2};
            benchObj.devices = [];
            self.loadDeviceFile(benchObj);
            self.CurrentLocation = '';
        end
        
        %% load devices file (coordinates file)
        function self = loadDeviceFile(self, benchObj)
            % Load data for each device on the chip into an object
            % Store data in self.DeviceData
            
            % Filename
            fn = strcat(self.Name, '.txt');

            % Check to see if file exists, if not throw error
            if exist(fn, 'file')
                load_devices(benchObj, fn);
            else
                msg = strcat(fn, ' does not exist. Cannot load devices.');
                error(msg);
            end
        end
        
        %% save history to text file
        function self = save_history(self, text, user_date_time)
            % write string from text box into a text file
            % should include date+time, user
            fileID = fopen('target_file.txt', 'a');
            fprintf(fileID, '%c', user_date_time);
            fprintf(fileID, '%c', text);
            fclose(fileID);
        end
        
    end
    
    methods (Access = private)
        function [data_dir_path, log_file] = check_directory(self, testData, testType, dtStr)
            % check for a file containing chip history
            % C:/testData/<chip_name>/<dieID>/<testType>/<date>/'fileName.txt'
            
            dir = [testData,'\'];
            % check for test data directory
            if ~exist(dir,'dir')
                mkdir(dir);
                msg = 'Creating test data directory';
                disp(msg);
            else
                msg = 'Found test data director';
                disp(msg);
            end
            
            dir = [testDataDir,'\',self.Name,'\'];
            % check for chip type
            if ~exist(dir,'dir')
                mkdir(dir);
            end
            
            dir = [testDataDir,'\',self.Name,'\',self.DieID,'\'];
            % check for specific chip
            if ~exist(dir,'dir')
                mkdir(dir);
            end
            
            dir = [testDataDir,'\',self.Name,'\',self.DieID,'\',testType,'\'];
            % check for test type
            if ~exist(dir,'dir')
                mkdir(dir);
            end
            
            dir = [testDataDir,'\',self.Name,'\',self.DieID,'\',testType,'\',dtStr,'\'];
            % check for date/time of test
            if ~exist(dir,'dir')
                mkdir(dir);
            end
            
            data_dir_path = [testDataDir,'\',self.Name,'\',self.DieID,'\',testType,'\',dtStr,'\'];
            log_file = [testDataDir,'\',self.Name,'\',self.DieID,'\',testType,'\',dtStr,'\log_file.txt'];
        end
        
    end
    
end

