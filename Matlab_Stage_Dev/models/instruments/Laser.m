classdef Laser < InstrClass
    % Shon Schmidt 2013
    
    properties
        % copied from Laser_Avilent8164A class
        % need to make GroupObj public so detector class can get it
        GroupObj; % handles to group objects
        NumPWMChannels; % necessary for multiframe lambda scan setup, need to get from detector obj
        PWMSlotInfo; % number of PWM modules installed in mainframe
        StitchNum; % for saving number of stitches input by user in GUI
    end
    
    properties (Access = protected)
        % copied from Laser_Avilent8164A class
        Password; % password to unlock the instrument
        Libname; % for trigger control?
        Session; % for trigger control?
        PauseTime; % so Matlab doesn't overrun the COM port
        
        Lasing; % 0=off, 1=laser output enabled
        ReadyForSweep; % flag
        
        % mainframe slot info
        NumberOfSlots; % number of laser/detector slots in mainframe
        TunableLaserSlot; % determined in slot info function
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
    end
    
    % static methods
    methods (Static)
        % convert nm wavelength to m
        function m = nm2m(nm)
            m = nm*1e-9;
        end
    end
    
    methods
        function self = Laser()
            self.Name = 'Virtual Laser'; % name of the instrument
            self.Group = 'Laser'; % instrument group this one belongs to
            self.Model = 'Virtual Model';
            self.CalDate = date;
            self.Serial = 'Virtual';
            self.Busy = 0; % not busy
            self.Connected = 0; % not connected
            
            % other properties
            self.NumberOfSlots = 5;
            self.TunableLaserSlot = 1;
            self.Password = 'swordfish';
            self.Lasing = 0; % 0=off, 1=laser output enabled
            self.PauseTime = 0.01; % seconds
            self.ReadyForSweep = 0; % 0=no, 1=yes
            self.MaxDataPoints = 20000; % should query from instrument for real instruments
            self.StitchNum = 0;
            self.StartWvl = 1480; % sweep wavelength (nm)
            self.StopWvl = 1580; % sweep wavelength (nm)
            self.StepWvl = 0.01; % step (nm)
            self.SweepSpeed = 5; % 1=slow ... 5=fast
            self.NumberOfScans = 1; % number of scans for sweep
            
            % instrument parameters
            self.Param.Wavelength = 1550; % wavelength (nm), set through a method so we know it changes

            self.Param.PowerLevel = 0; % initialize currenet power level
            self.Param.COMPort = 0; %  RS232/GPIB port #
            self.Param.TunableLaserSlot = 0; % slot 0 in mainframe
            self.Param.PowerUnit = 0; % 0=dB, 1=W
            self.Param.PowerLevel = 0; % (dB if self.Param.PowerUnit=0)
            self.Param.LowSSE = 0; % 0=no, 1=low-noise scan
        end
        
        function self = connect(self)
            self.Connected = 1;
        end
        
        function self = disconnect(self)
            if self.Connected
                self.Busy = 0;
                self.Connected = 0;
                delete(self.Obj);
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        function preset(self)
        end
        
        function self = off(self)
            if self.Connected
                while self.Busy
                    msg = strcat(self.Name, ' busy. Waiting...');
                    disp(msg);
                end
                self.Lasing = 0;
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        function self = on(self)
            if self.Connected
                while self.Busy
                    msg = strcat(self.Name, ' busy. Waiting...');
                    disp(msg);
                end
                self.Busy = 1;
                self.setWavelength(self.Param.Wavelength);
                self.setPower(self.Param.PowerLevel);
                self.setLowSSE();
                self.Lasing = 1;
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        function resp = laserIsOn(self)
            self.Busy = 1;
            resp = 0;
            self.Busy = 0;
        end
        
        function setWavelength(self,wvl)
            self.Busy = 1;
            self.Param.Wavelength = wvl;
            self.Busy = 0;
        end
        
        function wvl = getWavelength(self)
            wvl = self.Param.Wavelength;
        end
        
        function setPower(self, pwr) % pwr in dBm
            self.Busy = 1;
            self.Param.PowerLevel = pwr;
            self.Busy = 0;
        end
        
        function pwr = getPower(self) % pwr in dBm
            self.Busy = 1;
            pwr = self.Param.PowerLevel;
            self.Busy = 0;
        end
        
        function setStartWvl(self,wvl)
            self.Busy = 1;
            self.StartWvl = wvl;
            self.Busy = 0;
        end
        
        function setStopWvl(self,wvl)
            self.Busy = 1;
            self.StopWvl = wvl;
            self.Busy = 0;
        end
        
        function [datapoints, channels] = setupSweep(self) 
            % fake setup Sweep
            datapoints = 20000;
            channels = 3;
        end
        
        function [start_wvl,end_wvl,averaging_time,sweep_speed] = getSweepParams(self)
            self.Busy = 1;
            start_wvl = self.StartWvl;
            end_wvl = self.StopWvl;
            averaging_time = 1;
            sweep_speed = self.SweepSpeed;
            self.Busy = 0;
        end
        
        function resp = sweep(self)
            if self.Connected
                while self.Busy
                    msg = strcat(self.Name, ' busy. Waiting...');
                    disp(msg);
                end
                resp = zeros((self.StopWvl-self.StartWvl)/self.StepWvl, self.MaxDataPoints);
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        function [NumPWMChannels, PWMSlotInfo] = getDetectorSlotInfo(self)
            NumPWMChannels = self.NumPWMChannels ;
            PWMSlotInfo = self.PWMSlotInfo;
        end
        
        function setLowSSE(self)
            self.Busy = 1;
            if self.Param.LowSSE
            end
            self.Busy = 0;
        end
        
        function sendParams(self)
        end
        
        function self = setProp(self, prop, val)
                self.(prop) = val;
        end
        
        function val = getProp(self, prop)
                val = self.(prop);
        end
        
        
        function self = armTrigger(self)
            if self.Connected
                if self.Param.TriggerInEnable
                    msg = strcat(self.Name, ': arming input trigger.');
                    disp(msg);
                elseif self.Param.TriggerOutEnable
                    msg = strcat(self.Name, ': arming output trigger.');
                    disp(msg);
                else
                    msg = strcat(self.Name, ': no trigger enabled.');
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
    end
    
    methods (Access = private)
        function [Wavelength] = queryWavelength(self)
            Wavelength = self.Param.Wavelength;
        end
        
        function [pwr] = queryPower(self)
            pwr = self.PowerUnit;
        end
        
        function [errorNumber, errorMessage] = getError(self)
            errorNumber = rand(0, 1);
            errorMessage = 'Virtual Laser error';
        end
        
        function unlock(self)
            self.Busy = 1;
            self.Busy = 0;
        end
        
        function querySlotInfo(self)
        end
    end
end