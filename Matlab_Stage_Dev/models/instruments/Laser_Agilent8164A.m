classdef Laser_Agilent8164A < InstrClass
    properties
        % need to make GroupObj public so detector class can get it
        GroupObj; % handles to group objects
        PWMSlotInfo; % number of PWM modules installed in mainframe
        NumPWMChannels; % necessary for multiframe lambda scan setup, need to get from detector obj
        StitchNum; % for saving number of stitches input by user in GUI
    end
    
    properties (Access = protected)
        Password; % password to unlock the instrument
        Libname; % for trigger control?
        Session; % for trigger control?
        PauseTime; % so Matlab doesn't overrun the COM port
        
        Lasing; % 0=off, 1=laser output enabled
        ReadyForSweep; % flag
        
        % mainframe slot info
        NumberOfSlots; % number of laser/detector slots in mainframe
        NumDataPoints; % number of data points for this sweep
        MaxDataPoints; % detector depth for sweep
        
        StartWvl; % sweep wavelength (nm)
        StopWvl; % sweep wavelength (nm)
        StepWvl; % step (nm)
        SweepSpeed; % 1=slow ... 5=fast
        NumberOfScans; % number of scans for sweep
       
        % bounds
        MinWavelength; % bounds read from instrument
        MaxWavelength; % bounds read from instrument
        MinPower; % bounds read from instrument
        MaxPower; % bounds read from instrument
        
        TotalSlots;
        TotalNumOfDetectors;
    end
    
    %% static methods
    methods (Static)
        %% convert nm wavelength to m
        function m = nm2m(nm)
            m = nm*1e-9;
        end
    end
    
    %% class methods
    methods
        
        %% constructor
        function self = Laser_Agilent8164A()
            % super class properties
            self.Name = 'Agilent8164A Laser'; % name of the instrument
            self.Group = 'Laser'; % instrument group this one belongs to
            self.Model = '8164A';
            self.CalDate = '14-June-2011';
            self.Serial = 'DE39200407';
            self.Busy = 0; % not busy
            self.Connected = 0; % not connected
            
            % other properties
            self.NumberOfSlots = 5;
            self.Lasing = 0;
            self.PauseTime = 0.01;  %
            self.ReadyForSweep = 0; % 0=no, 1=yes
            self.MaxDataPoints = 100000; % should be queried from instrument
            self.StitchNum = 0;
            self.StartWvl = 1480; % sweep wavelength (nm)
            self.StopWvl = 1580; % sweep wavelength (nm)
            self.StepWvl = 0.01; % step (nm)
            self.SweepSpeed = 5; % 1=slow ... 5=fast
            self.NumberOfScans = 0; % number of scans for sweep
            
            % instrument parameters
            self.Param.Wavelength = 1550; % wavelength (nm), needs to be set through a method so we know it changes
            
            self.Param.PowerLevel = 0; % initialize currenet power level
            self.Param.COMPort = 20; %  GPIB port #
            self.Param.TunableLaserSlot = 0; % slot 0 in mainframe
            self.Param.PowerUnit = 0; % 0=dB, 1=W
            self.Param.PowerLevel = 0; % (dB if self.Param.PowerUnit=0)
            self.Param.LowSSE = 0; % 0=no, 1=low-noise scan
            self.Param.Password = '1234';
            
            self.TotalSlots = 0;
            self.TotalNumOfDetectors = 0; %this is done now on the detector side. 
        end
        
        %% Connect
        function connect(self)
            if ~self.Connected
                self.Busy = 1;
                try
                    %% open COM port and connect to physical instrument
                    GPIB_address = strcat('GPIB0::', num2str(self.Param.COMPort), '::INSTR');
                    self.Obj = icdevice('hp816x_v4p2', GPIB_address);
                    connect(self.Obj);
                    
                    % create handles to group functions
                    self.GroupObj.Multiframelambdascan = get(self.Obj, 'Applicationswavelengthscanfunctionsmultiframelambdascan');
                    self.GroupObj.Tunablelasersources = get(self.Obj, 'Tunablelasersources');
                    self.GroupObj.Mainframespecific = get(self.Obj, 'Mainframespecific');
                    self.GroupObj.Pwmdataaquisition = get(self.Obj, 'Powermetermodulespwmdataacquisition');
                    self.GroupObj.Powermetermodules = get(self.Obj, 'Powermetermodules');
                    
                    self.register();
                    % get number of detectors installed in mainframe (for sweep)
                    self.querySlotInfo();
                    
                    % for error handling?
                    self.Libname = get(self.Obj, 'DriverName');
                    self.Session = get(self.Obj, 'Interface');
                    self.GroupObj.Utility = get(self.Obj, 'Utility');
                    
                    % if locked, unlock
                    self.unlock();
                    
                    % preset
                    self.preset();
                    
                    % get instrument parameter bounds and current settings
                    % wtf. No public field minWavelength exists for class Laser_Agilent8164A.
                    %                    wvl = self.queryWavelength();
                    pwr = self.queryPower();
                    
                    self.Connected = 1;
                    msg = strcat(self.Name, ': Successfully connected.');
                    disp(msg);
                catch ME
                    msg = strcat(self.Name, ': Cannot connect and initialize.');
                    disp(msg);
                    disp(ME.message)
                    self.Connected = 0;
                end
            else
                msg = strcat(self.Name, ': Already connected.');
                disp(msg);
            end
            self.Busy = 0;
        end
        
        function self = register(self)
            % register mainframe
            invoke(self.GroupObj.Multiframelambdascan, 'registermainframe');
        end
        
        %% Disconnect instrument
        function disconnect(self)
            self.Busy = 1;
            try
                self.off();
                invoke(self.GroupObj.Multiframelambdascan, 'unregistermainframe');
                %delete(self.GroupObj);
                disconnect(self.Obj);
                self.Connected = 0;
                delete(self.Obj);
                msg = strcat(self.Name, ' disconnected.');
                disp(msg);
            catch ME
                msg = strcat(self.Name, ' cannot disconnect laser.');
                disp(msg);
                disp(ME.message)
            end
            self.Busy = 0;
        end
        
        %% Preset laser to known state
        function preset(self)
            invoke(self.GroupObj.Mainframespecific, 'preset', self.Session)
        end
        
        %% Turn laser off
        function off(self)
            if self.Lasing
                self.Busy = 1;
                try
                    invoke(self.GroupObj.Tunablelasersources, 'settlslaserstate', self.Param.TunableLaserSlot, 0); % turn the tunable laser off
                    self.Lasing = self.laserIsOn();
                catch ME
                    msg = strcat(self.Name, ': Cannot turn laser off.');
                    disp(msg);
                    disp(ME.message)
                end
            else
                msg = strcat(self.Name, ': Already turned off.');
                disp(msg);
            end
            self.Busy = 0;
        end
        
        %% Turn laser on
        function on(self)
            if ~self.Lasing
                self.Busy = 1;
                try
                    self.setWavelength(self.Param.Wavelength);
                    self.setPower(self.Param.PowerLevel);
                    self.setLowSSE();
                    invoke(self.GroupObj.Tunablelasersources, 'settlslaserstate', self.Param.TunableLaserSlot, 1); % turn the tunable laser off
                    self.Lasing = self.laserIsOn();
                catch ME
                    msg = strcat(self.Name, ': Cannot turn laser on.');
                    disp(msg);
                    disp(ME.message)
                end
            else
                msg = strcat(self.Name, ': Already turned on.');
                disp(msg);
            end
            self.Busy = 0;
        end
        
        %% get laser state: needed in GC map
        function resp = laserIsOn(self)
            self.Busy = 1;
            resp=0;
            try
                resp = invoke(self.GroupObj.Tunablelasersources, 'gettlslaserstateq', self.Param.TunableLaserSlot);
            catch ME
                disp(ME.message)
                return
            end
            self.Busy = 0;
        end
        
        %% set laser wavelength
        function setWavelength(self,wvl)
            self.Busy = 1;
            wvlSel = 3; % I don't know what this does. Maybe it enables manual selection?
            invoke(self.GroupObj.Tunablelasersources,'settlswavelength',self.Param.TunableLaserSlot,wvlSel,self.nm2m(wvl));
            self.Param.Wavelength=wvl;
            self.Busy = 0;
        end
        
        % get wavelength
        function wvl = getWavelength(self)
            wvl = self.Param.Wavelength;
        end
        
        %% setPower
        function setPower(self,pwr) %power in dBm
            self.Busy = 1;
            powerSel = 3;  % Enables manual power control
            invoke(self.GroupObj.Tunablelasersources,'settlspower',self.Param.TunableLaserSlot,self.Param.PowerUnit,powerSel,pwr);
            self.Param.PowerLevel = pwr;
            self.Busy = 0;
        end
        
        % getPower
        function pwr = getPower(self) %power in dBm
            self.Busy = 1;
            %            pwr = self.queryLaserPower(); % should be read by detector object
            pwr = self.Param.PowerLevel;
            self.Busy = 0;
        end
        
        %% set sweep range
        function setStartWvl(self,wvl)
            self.Busy = 1;
            wvlSel = 3;
            % invoke                 %what goes here if anything?
            self.StartWvl = wvl;
            self.Busy = 0;
        end
        
        function setStopWvl(self,wvl)
            self.Busy = 1;
            wvlSel = 3;
            % invoke                 %what goes here if anything?
            self.StopWvl = wvl;
            self.Busy = 0;
        end
        
        %% Sweep
        function [datapoints, channels] = setupSweep(self)
            % datapoints = number of datapoints for this sweep
            % channels = number of detector channels particpating in sweep
%             disp('starting laser.setupSweep');
%            self.GroupObj.Multiframelambdascan = get(self.Obj, 'Applicationswavelengthscanfunctionsmultiframelambdascan');
            self.Busy = 1;
            invoke(self.GroupObj.Multiframelambdascan,'setsweepspeed',self.SweepSpeed);
            pause(self.PauseTime);
            
            [datapoints, channels] = invoke(self.GroupObj.Multiframelambdascan,...
                'preparemflambdascan',self.Param.PowerUnit, ...
                self.Param.PowerLevel, self.Param.LowSSE, ...
                self.NumberOfScans, self.TotalNumOfDetectors, ...
                self.nm2m(self.StartWvl), self.nm2m(self.StopWvl), self.nm2m(self.StepWvl));
            if datapoints >= self.MaxDataPoints
                msg = strcat(self.Name, ' error. Sweep requires more datapoints than detector can support.');
                error (msg);
            end
            self.NumDataPoints = datapoints; % number of datapoints for this sweep
            self.Busy = 0;
            self.ReadyForSweep = 1;
%             disp('laser.setupSweep complete');
        end
        
        % get sweep parameters
        function [start_wvl,end_wvl,averaging_time,sweep_speed] = getSweepParams(self)
            self.Busy = 1;
            [start_wvl,end_wvl,averaging_time,sweep_speed] = invoke(...
                self.GroupObj.Multiframelambdascan,'getmflambdascanparametersq');
            self.Busy = 0;
        end
        
        % execute sweep
        function resp = sweep(self)
%             disp('starting laser.sweep');
            % returns array with wavelength value for each sample in (m)
            self.Busy = 1;
            if self.ReadyForSweep
                try
                    resp = invoke(self.GroupObj.Multiframelambdascan, ...
                        'executemflambdascan', zeros(1,self.NumDataPoints));
                catch ME
                    disp(ME.message)
                end
            else
                msg = strcat(self.Name, ': Need to call setupSweep before executing sweep.');
                error(msg);
            end
            self.Busy = 0;
            self.ReadyForSweep = 0;
%             disp('laser.sweep complete');
        end
        
        %% get detector info
        function [NumPWMChannels, PWMSlotInfo] = getDetectorSlotInfo(self)
            NumPWMChannels = self.NumPWMChannels ;
            PWMSlotInfo = self.PWMSlotInfo;
        end
        
        %% set SSE
        function setLowSSE(self) %power in dBm
            self.Busy = 1;
            if self.Param.LowSSE
                invoke(self.GroupObj.Tunablelasersources,'settlsopticaloutput',self.Param.TunableLaserSlot,self.Param.LowSSE);
            end
            self.Busy = 0;
        end
        
        %% send params (overloads superclass method)
        function sendParams(self)
            Attenuation = 0;
            try
                invoke(self.GroupObj.Tunablelasersources,'settlsparameters',...
                    self.Param.TunableLaserSlot,...
                    self.Param.PowerUnit,...,
                    self.Param.LowSSE,...
                    self.Lasing,...
                    self.Param.PowerLevel,...
                    Attenuation,...
                    self.nm2m(self.Param.Wavelength));
                
                % these get set in setting up a sweep
                %  nm2m(self.Param.StepWvl),...
                %  self.Param.SweepSpeed,...
                %  self.Param.NumberOfScans,...
                %  nm2m(self.Param.StartWvl),...
                %  num2m(self.Param.StopWvl,...
                
            catch ME
                rethrow(ME);
            end
        end
        
        
        % set property
        function self = setProp(self, prop, val)
            % if self.(prop)  %testing this way is not valid. prop can be 0
            self.(prop) = val;
            %else
            %   msg = strcat(self.Name, ' ', prop, ' does not exist.');
            %   err = MException(self.Name,msg);
            %   throw(err);
            %end
        end
        
        % get property
        function val = getProp(self, prop)
            %if self.(prop)
            val = self.(prop);
            %else
            %   msg = strcat(self.Name, ' ', prop, ' does not exist.');
            %   err = MException(self.Name,msg);
            %   throw(err);
            %end
        end
        
        function [triggerIn, triggerOut] = getTriggerSetup(self)
            [triggerIn, triggerOut] = invoke(...
                self.GroupObj.Tunablelasersources, ...
                'gettlstriggerconfiguration', ...
                self.Param.TunableLaserSlot);
            disp('trigger values from Laser_Agilent8164A.getTriggerSetup func:')
            disp(triggerIn);
            disp(triggerOut);
        end
        
        function [triggerIn, triggerOut] = setTriggerPassThru(self)
            % shons note: with the n7744 as the detector, the mainframe
            % needs to pass through the optical stage trigger for map_gc
            % and course_align routines. this should be written to be more
            % generic when we get it working
            
            % first parameter
            % 3 = ?
            % 2 = pass thru
            % 1 = default
            % 0 = disable
            % not sure what the other three parameters are for, set to 0
            invoke(self.GroupObj.Mainframespecific,...
                'standardtriggerconfiguration', 2, 0, 0, 0);
            [triggerIn, triggerOut] = self.getTriggerSetup();
        end
    end
    
    % Private methods
    methods (Access = private)
        
        %% Returns the current wavelength and the min and max wavelength bounds
        
        function [Wavelength] = queryWavelength(self)
            [self.minWavelength, ~, self.maxWavelength, Wavelength] =...
                invoke(self.GroupObj.Tunablelasersources, 'gettlswavelengthq', self.Param.TunableLaserSlot);
        end
        
        %% Returns the current laser power as well as the min and max power bounds
        function [pwr] = queryPower(self)
            [~, self.MinPower, ~, self.MaxPower, pwr] = invoke(self.GroupObj.Tunablelasersources,...
                'gettlspowerq', self.Param.TunableLaserSlot);
        end
        
        %% Returns details about a driver error
        function [errorNumber, errorMessage] = getError(self)
            [errorNumber, errorMessage] = invoke(self.GroupObj.Utility, 'errorquery');
        end
        
        %% unlock instrumnent
        function unlock(self)
            self.Busy = 1;
            try
                [softLock, ~] = invoke(self.GroupObj.Mainframespecific, 'getlockstate');
                if softLock
                    invoke(self.GroupObj.Mainframespecific, ...
                        'lockunlockinstument', ...
                        0, self.Param.Password);
                end
            catch ME
                disp('Unable to Unlock Laser.');
                disp( ME.message);
            end
            self.Busy = 0;
        end
        
        %% Query slot info for sweep preparation
        function querySlotInfo(self)
            try
                slotInfo = invoke(self.GroupObj.Mainframespecific, ...
                    'getslotinformationq', self.NumberOfSlots, ...
                    zeros(1,self.NumberOfSlots));
                if self.Param.TunableLaserSlot == length(slotInfo) - 1 % Laser Slot is the last slot
                    self.NumPWMChannels = sum(slotInfo(1:end-1));
                    self.PWMSlotInfo = slotInfo(1:end-1);
                elseif self.Param.TunableLaserSlot == 0 % Laser Slot is the first slot: 0
                    self.NumPWMChannels = sum(slotInfo(2:end));
                    self.PWMSlotInfo = slotInfo(2:end);
                else % Laser Slot is in the middle of slots
                    self.NumPWMChannels = sum([slotInfo(1:self.Param.TunableLaserSlot), slotInfo(self.Param.TunableLaserSlot + 2:end)]);
                    self.PWMSlotInfo = [slotInfo(1:self.Param.TunableLaserSlot), slotInfo(self.Param.TunableLaserSlot + 2:end)];
                end
                l_dNum = self.NumPWMChannels
                l_slots = self.PWMSlotInfo
            catch ME
                error('did not get slot info');
                disp(ME.message)
            end
        end
        
    end
end