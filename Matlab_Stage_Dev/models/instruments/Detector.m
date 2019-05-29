classdef Detector < InstrClass
    properties (Access = protected)
        % copied from Detector_Agilient8164A class
        Password; % password to unlock the instrument
        GroupObj; % handles to group objects
        %         Libname; % for trigger control?
        %         Session; % for trigger control?
        PauseTime; % so Matlab doesn't overrun the COM port
        
        % Properties
        Slots;
        NumOfDetectors;
        SelectedDetectors;
        SlotNumber; % Need to redefine
        ChannelNumber; % Need to redefine
        DetectorNumber; % Sofware label number of detector
        DetectorLabel; % Legend for figure
        Zeroed; % Flag for Zeroing detector bias
        Clipping; % 0=no, 1=yes
        ClipLimit;
        RangeDecrement; %for multiple scans with different range
        MaxDataPoints; % memory detector depth
        ReadyForSweep; % flag, 1=yes, 0=no
        
        % structs/storage variables
        DataPoints; % length of Pwr and Wvl arrays, should get from detector or calc by sweep range/step
        Pwr; % Preallocate for speed
        Wvl;% Preallocate for speed
        MinWvl;
        MaxWvl;
    end
    
    methods (Static)
        function m = nm2m(nm)
            % convert nm to m (for working with wavelengths)
            m = nm*1e-9;
        end
    end
    
    methods
        function self = Detector()
            self.Name = 'Virtual Detector'; % name of the instrument
            self.Group = 'Detector'; % instrument group this one belongs to
            self.Model = 'Virtual';
            self.CalDate = date;
            self.PauseTime = .01;
            self.Connected = 0;  % 1=connected, 0=not connected
            self.Busy = 0; % 1=busy, 0=not busy
            
            self.Slots = (1:3);
            self.NumOfDetectors = 3;
            self.SelectedDetectors = ones(1, 3);
            
            % class properties
            self.SlotNumber = 1;
            self.ChannelNumber = 1;
            self.DetectorNumber = 1;
            self.DetectorLabel = 'Detector1';
            self.Zeroed = 0;
            self.Clipping = 1; % 0=no, 1=yes
            self.ClipLimit = -100;
            self.RangeDecrement = 30; % for multiple scans with different ranges
            self.MinWvl = 1480;
            self.MaxWvl = 1580;
            self.MaxDataPoints = 19800; % should be queried from detector
            self.ReadyForSweep = 0; % 0=no, 1=yes
            
            % Parameters
            self.Param.COMPort = 0; %
            self.Param.AveragingTime = .0005; % s
            self.Param.RangeMode = 0; %0=auto, 1=manual, use Range val
            self.Param.PowerRange = -20; % dB
            self.Param.PowerUnit = 0; % dB=0, W=1
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            self.Param.PWMWvl = 1550;
            self.Param.WaitForCompletion = 0;
            self.Param.InternalTrigger = 1; % not sure what this does
            
            % structs for data
            self.DataPoints = 20000; % should query from detector or calculate
            self.Pwr = zeros(20000, 1); % Preallocate for speed
            self.Wvl = zeros(20000, 1); % Preallocate for speed
            self.PauseTime = 0.01; % seconds
        end
        
        function self = connect(self, laser)
            self.Connected = 1;
            % for testing detector_ui
            self.NumOfDetectors = 3;
            self.Slots = (1:3);
            self.SlotNumber = 1;
            self.ChannelNumber = 1;
            self.DetectorNumber = 1;
            
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            self.Param.PowerUnit = 0;
        end
        
        function [slot, channel, self] = switchDetector(self, DetectorNumber)
            % copied from Detector_Agilent8164A
            self.DetectorNumber = DetectorNumber;
            DetectorNumber = DetectorNumber + 1; % Temporary add 1 to calculate the slot and channel number
            slot = 1;
            while (DetectorNumber > self.Slots(slot))
                DetectorNumber = DetectorNumber - self.Slots(slot);
                slot = slot + 1;
            end
            channel = DetectorNumber - 1;
            self.SlotNumber = slot;
            self.ChannelNumber = channel;
        end
        
        function [pwrData, wvlData] = getSweepData(self)
            % same wavelength array for all detectors
            if self.ReadyForSweep
                % pre-allocate
                pwrData = zeros(self.DataPoints,self.NumOfDetectors);
                wvlData = zeros(self.DataPoints,self.NumOfDetectors);
                % fill array w/ data
                wvl = linspace(self.MinWvl, self.MaxWvl, self.DataPoints);
                for ii=1:self.NumOfDetectors
                    x0 = 1;
                    x2 = randi([round(self.DataPoints/3), round(self.DataPoints*2/3)], 1);
                    x4 = self.DataPoints;
                    x1 = round(x2 - self.DataPoints/1000 + 50*rand());
                    x3 = round(x2 + self.DataPoints/1000 + 50*rand());
                    % create unique random data for each detector
                    pwrData(x0:x1, ii) = -20;
                    pwrData(x1:x2, ii) = linspace(-20, -45, x2 - x1 + 1);
                    pwrData(x2:x3, ii) = linspace(-45, -20, x3 - x2 + 1);
                    pwrData(x3:x4, ii) = -20;
                    pwrData(:, ii) = pwrData(:, ii) + rand(self.DataPoints, 1);
                    wvlData(:,ii) = wvl;
                end
            else
                error('DetectorClass: sweep not setup correctly.');
            end
        end
        
        function powerVal = readPower(self, detectorNumber)
            powerVal = 1e-3*rand(1);
        end
        
        function [NumOfDetectors, PowerValues] = readPowerAll(self)
            NumOfDetectors = self.NumOfDetectors;
            PowerValues = rand(1, NumOfDetectors);
        end
        
        function setupSweep(self, numOfDataPoints)
            self.DataPoints = numOfDataPoints;
            self.ReadyForSweep = 1; % 0=no, 1=yes
        end
        
        function setPWMPowerUnit(self, PowerUnit)
            % PowerUnit: 0 to dB, 1 to W
            self.Param.PowerUnit = PowerUnit;
        end
        
        function pwm_func_stop(self, DetectorNumber)
            self.switchDetector(DetectorNumber);
        end
        
        function [EstimatedTimeout] = start_pwm_logging(self, DetectorNumber)
            self.switchDetector(DetectorNumber);
            EstimatedTimeout = rand(1);
        end
        
        function [LoggingConnected, LoggingResult] = get_pwm_logging(self, DetectorNumber)
            self.switchDetector(DetectorNumber);
            LoggingResult = zeros(1, self.DataPoints);
            self.Param.PowerUnit = 0;
            LoggingConnected = zeros(1, self.DataPoints);
        end
        
        function setPWMPowerRange(self, DetectorNumber, RangeMode, PowerRange)
            self.switchDetector(DetectorNumber);
            if RangeMode ~= 0 && RangeMode ~= 1
                disp('Error: rangeMode must be 0 for manual or 1 for auto');
            end
        end
        
        function [currentWvl, self] = queryPWMWvl(self)
            currentWvl = self.Wvl;
        end
        
        function setPWMWvl(self, wvl, DetectorNumber)
            self.queryPWMWvl;
            if self.nm2m(wvl) < self.MinWvl || self.nm2m(wvl) > self.MaxWvl
                disp('Error: The speficied PWM wavelength is out of bounds!');
                return
            end
        end
        
        function setup_trigger(self,TriggerIn,TriggerOut,DetectorNumber)
            self.switchDetector(DetectorNumber);
        end
        
        function [errorNumber, errorMessage] = queryError(self)
            errorNumber = rand(1,1);
            errorMessage = 'error string';
        end
        
        % get/set prop/param -- needed to overload superclass methods
        function self = setProp(self, prop, val)
            self.(prop) = val;
        end
        
        function val = getProp(self, prop)
            val = self.(prop);
        end
        
        function sendParams(self)
        end
        
        function self = disconnect(self)
            self.Connected = 0;
        end
    end
    
    methods (Access = private)
        function unlock(self)
            disp('Virtual detector unlocked!');
        end
    end
end