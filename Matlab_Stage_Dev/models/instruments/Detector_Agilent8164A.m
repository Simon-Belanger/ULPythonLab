classdef Detector_Agilent8164A < InstrClass
    % Shon Schmidt 2013
    properties (Access = protected)
        Password; % password to unlock the instrument
        GroupObj; % handles to group objects
        %         Libname; % for trigger control?
        %         Session; % for trigger control?
        PauseTime; % so Matlab doesn't overrun the COM port
        
        % Properties
        NumOfSlots;
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
        MaxDataPoints; % detector memory depth
        ReadyForSweep; % flag
        
        % structs/storage variables
        DataPoints; % length of Pwr and Wvl arrays, should get from detector or calc by sweep range/step
        Pwr; % Preallocate for speed
        Wvl;% Preallocate for speed
        MinWvl;
        MaxWvl;
    end
    
    %% static methods
    methods (Static)
        %% convert nm wavelength to m
        function m = nm2m(nm)
            m = nm*1e-9;
        end
    end
    
    methods
        
        
        % Constructor
        function self = Detector_Agilent8164A()
            % super class properties
            self.Name = 'Agilent 8164A Detector';
            self.Group = 'Detector';
            self.Model = '81600B';
            self.CalDate = date;
            self.Busy = 0; % not busy
            self.Connected = 0; % not connected
            
            self.Slots = [];
            self.NumOfDetectors = 0;
            self.SelectedDetectors = [];
            % initialize class properties
            self.NumOfSlots = 5;
            self.SlotNumber = 0; % slot # in mainframe
            self.ChannelNumber = 0; % channel # in slot
            self.SelectedDetectors = [];
            self.DetectorNumber = 0; % Sofware label number of detector
            self.DetectorLabel = 'Detector0'; % Legend for figure
            self.Zeroed = 0; % 0=no, 1=yes, Flag for Zeroing detector bias
            self.Clipping = 1; % 0=no, 1=yes
            self.ClipLimit = -100;
            self.RangeDecrement = 30; %for multiple scans with different range
            self.MinWvl=1480;
            self.MaxWvl=1580;
            self.MaxDataPoints = 19800; %shoudl be queried from the detector
                       % max Data points for sweep: for the agilent the
                       % sweep range is bigger thatn requested by as much
                       % as 100pm
            self.ReadyForSweep = 0; % 0=no, 1=yes
            
            % Parameters
            self.Param.COMPort = 20; %
            self.Param.AveragingTime = .0005; % s
            self.Param.RangeMode = 0; %1=auto, 0=manual, use Range val
            self.Param.PowerRange = -20; % dB
            self.Param.PowerUnit = 0; % dB=0, W=1
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            self.Param.PWMWvl = 1550;
            self.Param.WaitForCompletion = 0;
            self.Param.InternalTrigger = 1; % not sure what this does
            
            
            % structs for data
            self.DataPoints = 20000; % should get this from the detector or calc by sweep range/step
            self.Pwr = zeros(self.DataPoints, 1); % Preallocate for speed
            self.Wvl = zeros(self.DataPoints, 1); % Preallocate for speed
            self.PauseTime = .01;
        end
        
        function self = connect(self, varargin)
            if nargin == 2
                laser = varargin{1};
                if(laser.Connected) && (strcmp(laser.Name, 'Agilent8164A Laser') || strcmp(laser.Name, 'Tunable 81689A Laser'))
                    self.Obj = laser.Obj;
                    self.GroupObj.Mainframespecific = laser.GroupObj.Mainframespecific;
                    self.GroupObj.Multiframelambdascan = laser.GroupObj.Multiframelambdascan;
                    self.GroupObj.Pwmdataaquisition = laser.GroupObj.Pwmdataaquisition;
                    self.GroupObj.Powermetermodules = laser.GroupObj.Powermetermodules;
                    self.GroupObj.Utility = laser.GroupObj.Utility;
                else
                    disp('creating laser obj')
                    GPIB_address = ['GPIB0::', num2str(self.Param.COMPort), '::INSTR'];
                    self.Obj = icdevice('hp816x_v4p2', GPIB_address);
                    connect(self.Obj);
                    self.GroupObj.Mainframespecific = get(self.Obj, 'Mainframespecific');
                    self.GroupObj.Multiframelambdascan = get(self.Obj, 'Applicationswavelengthscanfunctionsmultiframelambdascan');
                    self.GroupObj.Pwmdataaquisition = get(self.Obj, 'Powermetermodulespwmdataacquisition');
                    self.GroupObj.Powermetermodules = get(self.Obj, 'Powermetermodules');
                    self.GroupObj.Utility = get(self.Obj, 'Utility');
                    self.unlock();
                end
            else % if not 4 args passed (meaning no laser handle)
                % vince, what about the case where the previous detector object connect
                % already created the self.Obj?
                GPIB_address = ['GPIB0::', num2str(self.Param.COMPort), '::INSTR'];
                self.Obj = icdevice('hp816x', GPIB_address);
                connect(self.Obj);
                self.GroupObj.Mainframespecific = get(self.Obj, 'Mainframespecific');
                self.GroupObj.Multiframelambdascan = get(self.Obj, 'Multiframelambdascan');
                self.GroupObj.Pwmdataaquisition = get(self.Obj, 'Pwmdataacquisition');
                self.GroupObj.Powermetermodules = get(self.Obj, 'Powermetermodules');
                self.GroupObj.Utility = get(self.Obj, 'Utility');
                self.unlock();
            end
            
            self.querySlotInfo(laser);
            
            % Set Power Unit to dB
            self.setPWMPowerUnit(0);
            
            % Set PWM wavelenght
            self.setPWMWvl(self.Param.PWMWvl);
            
            % self.queryPWMWvl();
            self.Pwr = zeros(self.DataPoints, 1);
            self.Wvl = zeros(self.DataPoints, 1);
            self.Connected = 1;
        end
        
        function querySlotInfo(self, laser)
            % Get Number of Detectors installed
            NumberOfSlots = 5;
            slotInfo = invoke(self.GroupObj.Mainframespecific, ...
                'getslotinformationq', NumberOfSlots, ...
                zeros(1, NumberOfSlots));
            self.NumOfDetectors = sum(slotInfo(2:end));
            self.SelectedDetectors = ones(1,self.NumOfDetectors); %preselect all detectors for auto update
            self.Slots = slotInfo(2:end);
            laser.setProp('TotalSlots', self.Slots);
            laser.setProp('TotalNumOfDetectors', self.NumOfDetectors);

            % Get Number of Detectors installed
            try
                tunableLaserSlot = laser.Param.TunableLaserSlot;
                slotInfo = invoke(self.GroupObj.Mainframespecific, ...
                    'getslotinformationq', self.NumOfSlots, ...
                    zeros(1,self.NumOfSlots));
                if tunableLaserSlot == length(slotInfo) - 1 % Laser Slot is the last slot
                    self.NumOfDetectors = sum(slotInfo(1:end-1));
                    self.Slots = slotInfo(1:end-1);
                elseif tunableLaserSlot == 0 % Laser Slot is the first slot: 0
                    self.NumOfDetectors = sum(slotInfo(2:end));
                    self.Slots = slotInfo(2:end);
                else % Laser Slot is in the middle of slots
                    self.NumOfDetectors = sum([slotInfo(1:tunableLaserSlot), slotInfo(tunableLaserSlot + 2:end)]);
                    self.Slots = [slotInfo(1:tunableLaserSlot), slotInfo(tunableLaserSlot + 2:end)];
                end
                d_dNum = self.NumOfDetectors
                d_slots = self.Slots
                self.SelectedDetectors = ones(1, self.NumOfDetectors);
            catch ME
                disp(ME.message);
                error('did not get slot info');
            end
        end
        
        % Input DetectorNumber starting from 1
        % Return the Slot number and Channel number of the chosed detector
        function [slot, channel, self] = switchDetector(self, DetectorNumber)
            % Calculate the slot and channel number for detector
            self.DetectorNumber = DetectorNumber;
            slot = 1;
            while (DetectorNumber > self.Slots(slot))
                DetectorNumber = DetectorNumber - self.Slots(slot);
                slot = slot + 1;
            end
            channel = DetectorNumber-1;
            %
            self.SlotNumber = slot;
            self.ChannelNumber = channel;
        end
        
        % Fetch sweep data
        function  [Pwr, Wvl] = getSweepData(self)
            if self.ReadyForSweep
                %data array is initialized
                for ii=1:self.NumOfDetectors
                    self.switchDetector(ii);
                    Pwr(:, ii) = zeros(1, self.DataPoints);
                    Wvl(:, ii) = zeros(1, self.DataPoints);
                    if (self.SelectedDetectors(ii))
                        [Pwr(:,ii), Wvl(:,ii)] = invoke(self.GroupObj.Multiframelambdascan, ...
                            'getlambdascanresult', ...
                            self.DetectorNumber - 1, ...
                            self.Clipping, ...
                            self.ClipLimit, ...
                            zeros(1,self.DataPoints), ...
                            zeros(1,self.DataPoints));
                    end
                end
            else
                error('DetectorClass: Sweep not setup correctly.');
            end
            self.ReadyForSweep = 0; % reset flag
        end
        
        % Fetch single power value
        function powerVal = readPower(self, DetectorNumber)
            [slot, channel] = self.switchDetector(DetectorNumber);
            %             comparision to the "FETCH" command, the "READ"
            %             command implies triggering a measurement. Make sure the
            %             timeout set is greater than the adjusted averaging time, so that the
            %             READ command will not time out;
            try
                powerVal = invoke(self.GroupObj.Powermetermodules, 'pwmreadvalue', ...
                    slot, channel);
            catch ME
                try
                    err=self.queryError();
                catch ME
                    rethrow(ME)
                end
                if err == -261
                    powerVal = -200;
                    return
                elseif err == -231  %value questionable, doesn't necessarily mean saturated
                    powerVal = 200;
                else
                    ex = MException('Detector:readPower ',...
                        strcat('Error Query returned: ',num2str(err)));
                    throw(ex);
                end
            end
        end
        
        % Fetch power value's from all detectors
        function PowerValues = readPowerAll(self)
            try
                %SlotsA = zeros(1,4); %%% ??? Not sure how many to use...
                %ChannelsA = zeros(1,4);%%% ??? Not sure how many to use...
                %ValuesA = zeros(1,20); %%% ??? Not sure how many to use...
                
                %[NumOfDetectors, ~, ~, PowerValues] = invoke( ...
                %    self.GroupObj.Powermetermodules,'pwmreadall', ...
                 %   SlotsA, ChannelsA, ValuesA);
                 PowerValues = zeros(1,self.NumOfDetectors);
                 for dd = 1:self.NumOfDetectors
                     PowerValues(dd) = self.readPower(dd);
                 end
            catch ME
                try
                    err = self.queryError();
                catch ME1
                   rethrow(ME1) 
                end
                if err == -261
                    PowerValues(1:NumOfDetectors) = self.Param.ClipLimit;
                    return
                elseif err == -231
                    PowerValues(1:NumOfDetectors) = -self.Param.ClipLimit; %value questionable
                else
                    ex = MException(self.Name,...
                        strcat('Error Query returned: ',num2str(ex)));
                    throw(ex);
                end
            %Don't rethrow ME here: needs to keep measuring.    
            end
        end
        
        
        function self=setupSweep(self, numOfDataPoints)
            reset_to_default = 0;
            self.DataPoints = numOfDataPoints;
            for ii=1:self.NumOfDetectors
                current_channel = ii-1;
                invoke(self.GroupObj.Multiframelambdascan,'setinitialrangeparams', ...
                    current_channel,reset_to_default,self.Param.PowerRange, ...
                    self.RangeDecrement);
            end
            self.ReadyForSweep = 1;            
        end
        
        
        function setPWMPowerUnit(self, PowerUnit)
            % PowerUnit: 0 to dB, 1 to W
            for i = 1:self.NumOfDetectors
                [slot, channel] = self.switchDetector(i);
                invoke(self.GroupObj.Powermetermodules, 'setpwmpowerunit', ...
                    slot, channel, PowerUnit);
            end
        end
        
        %maybe not necessary; stop logging functions
        function pwm_func_stop(self, DetectorNumber)
            self.switchDetector(DetectorNumber);
            invoke(self.GroupObj.Pwmdataaquisition,'pwmfunctionstop',...
                self.SlotNumber, self.ChannelNumber);
        end
        
        %Set up data logging if trigger set then the detectors waits for
        %trigger if not it starts recording right awy
        function [EstimatedTimeout]=start_pwm_logging(self, DetectorNumber)
            
           
            
            self.switchDetector(DetectorNumber);
            [EstimatedTimeout] = invoke(self.GroupObj.Pwmdataaquisition,...
                'setpwmlogging',self.SlotNumber,self.ChannelNumber, ...
                self.Param.AveragingTime, self.DataPoints);
        end
        
        function [LoggingConnected, LoggingResult] = get_pwm_logging(self,DetectorNumber)
            % Get data from scanning to the right
            self.switchDetector(DetectorNumber);
            LoggingResult = zeros(1,self.DataPoints);
            self.Param.PowerUnit=0; %fixed to dBm
            [LoggingConnected, LoggingResult] = invoke(self.GroupObj.Pwmdataaquisition,...
                'getpwmloggingresultsq', self.SlotNumber, self.ChannelNumber, self.Param.WaitForCompletion,...
                self.Param.PowerUnit, LoggingResult);
        end
        
        % Sets the power meter power range
        function setPWMPowerRange(self, DetectorNumber, RangeMode,PowerRange)
            self.switchDetector(DetectorNumber);
            if RangeMode ~= 0 && RangeMode ~= 1
                disp('Error: rangeMode must be 0 for manual or 1 for auto');
                return
            end
            invoke(self.GroupObj.Powermetermodules,'setpwmpowerrange',...
                self.SlotNumber, self.ChannelNumber, RangeMode, PowerRange);
        end
        
        % Queries the current PWM wavelength as well as the min and max
        % wavelength bounds
        function [currentWvl, self] = queryPWMWvl(self)
            [self.MinWvl, self.MaxWvl, currentWvl] = ...
                invoke(self.GroupObj.Powermetermodules, 'getpwmwavelengthq', self.SlotNumber, self.ChannelNumber);
        end
        
        function setPWMWvl(self, wvl)
            % Check if the wavelength is in range
            self.queryPWMWvl();
            if self.nm2m(wvl) < self.MinWvl || self.nm2m(wvl) > self.MaxWvl
                disp('Error: The speficied PWM wavelength is out of bounds!');
                return
            end
            for i = 1:self.NumOfDetectors
                [slot, channel] = self.switchDetector(i);
                invoke(self.GroupObj.Powermetermodules, 'setpwmwavelength', ...
                    slot, channel, self.nm2m(wvl));
            end
        end
        
        function setup_trigger(self,TriggerIn,TriggerOut,DetectorNumber)
            %TriggerIn=2; %0:ignore 1:single (sme), 2:complete (cme)
            %TriggerOut=0; %0:disabled, 1:at the end, 3:at the beginning
            self.switchDetector(DetectorNumber);
            invoke(self.GroupObj.Powermetermodules, 'setpwmtriggerconfiguration', self.SlotNumber, ...
                TriggerIn, TriggerOut);
            [in out] = invoke(self.GroupObj.Powermetermodules, 'getpwmtriggerconfiguration', self.SlotNumber);
        end
        
        % Returns details about a driver error
        function [errorNumber, errorMessage] = queryError(self)
            [errorNumber, errorMessage] = invoke(self.GroupObj.Utility, 'errorquery');
        end
        
        function [triggerIn, triggerOut] = getTriggerConfiguration(self, slotNumber)
            [triggerIn, triggerOut] = invoke(...
                self.GroupObj.Powermetermodules, ...
                'getpwmtriggerconfiguration', ...
                slotNumber);
        end
        
        %% Get/set properties -- need here to overload super class methods
        % set property
        function self = setProp(self, prop, val)
            %             if exist(self.(prop))
            self.(prop) = val;
            %             else
            %                 msg = strcat(self.Name, ' ', prop, ' does not exist.');
            %                 err = MException(msg);
            %                 throw(err);
            %             end
        end
        
        % get property
        function val = getProp(self, prop)
            %             if self.(prop)
            val = self.(prop);
            %             else
            %                 msg = strcat(self.Name, ' ', prop, ' does not exist.');
            %                 err = MException(msg);
            %                 throw(err);
            %             end
        end
        
        % send params (overloads superclass method)
        function sendParams(self)
            try
                for i = 1:self.NumOfDetectors
                    [slot, channel] = self.switchDetector(i);
                    % need to invoke all methods to write existing params
                    invoke(self.GroupObj.Powermetermodules, 'setpwmparameters', ...
                        slot,...
                        channel,...
                        self.Param.RangeMode,...
                        self.Param.PowerUnit,...
                        self.Param.InternalTrigger,...
                        self.nm2m(self.Param.PWMWvl),...
                        self.Param.AveragingTime,...
                        self.Param.PowerRange);
                    % these params are written when a sweep is setup
                    %   self.Param.Threshold = 0; %
                    %   self.Param.Clipping = 1; % 0=no, 1=yes
                    %   self.Param.ClipLimit = -100;
                end
            catch ME
                rethrow(ME);
            end
        end
    end
    
    
    methods (Access = private)
        function unlock(self)
            try
                [softLock, ~] = invoke(self.GroupObj.Mainframespecific, 'getlockstate');
                if softLock
                    invoke(self.GroupObj.Mainframespecific, ...
                        'lockunlockinstument', ...
                        0, self.Password);
                    disp('Laser unlocked!');
                end
            catch ME
                disp('Unable to Unlock Laser!!!');
                disp( ME.message);
            end
        end
    end
end