classdef Laser_SRS_LDC501 < InstrClass
    properties
        % need to make GroupObj public so detector class can get it
        GroupObj; % handles to group objects
        PWMSlotInfo; % number of PWM modules installed in mainframe
        NumPWMChannels; % necessary for multiframe lambda scan setup, need to get from detector obj
        StitchNum; % for saving number of stitches input by user in GUI
    end
    
    properties (Access = protected)
%% old

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
        
        TotalSlots;
        TotalNumOfDetectors;
        
%% new
        
        Temp_Setpoint;  % degrees C  
        Current_Setpoint      % in ampere
        Resistance_Setpoint  % in kilo ohm
        
        MIN_TEMP;  % degrees C   10 degree
        MAX_TEMP;  % degrees C   120 degree
        MAX_CURRENT; % in amps, given by peltier cooler manufacturer  1.4 A
        MAX_V;     % in volts  8.5V
        MAX_R;     % upper resitance limit in kilo ohm
        MIN_R;     % lower resistance limit in kilo ohm
  
        Autotune;    %set the temperature control autotune process (off=0, on=1)
        Auto_StepSize;   % set the temperature control autotune step size in Amm. The default value is 10% of TILM, up to 25%.
        P_gain;       %set the temperature control loop proportional gain
        I_gain;       % sett the temperature control loop integral gain
        D_gain;       % set the temperature control loop derivative gain
        
        Trip_off_Thermometer;    % set the TEC trip off upon thermometer fault (No=1,Yes=1)
        Trip_off_MaxTemp;        % set the TEC trip off upon exceeding max temp (No=1,Yes=1)
        Trip_off_MinTemp;        % set the TEC trip off upon exceeding min temp (No=1,Yes=1)
        Trip_off_MaxCurrent;     % set the TEC trip off upon excedding max current (No=1,Yes=1)
        Trip_off_MaxVoltage;     % set the TEC trip off upon exceeding max voltage (No=1,Yes=1)
        
        Thermo_type;  % set the temperature sensor type, NTC10uA=0; NTC100uA=1, NTC1mA=2, NTCAUTO=3, RTD=4, LM355=5, AD590=6    
        NTC_Model;    % set the NTC calibration mode. Beta=0, SHH=1, NONE=2;
        SHH_A;        % A=1.20836e-3;
        SHH_B;        % B=2.41165e-4;
        SHH_C;        % C=1.48267e-7;

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
        function self = Laser_SRS_LDC501()
            % super class properties
            self.Name = 'Laser SRS LDC501'; % name of the instrument
            self.Group = 'Laser'; % instrument group this one belongs to
            self.Model = 'SRS_LDC501';
            self.CalDate = date;
            self.Serial = '98602';
            self.Busy = 0; % not busy
            self.Connected = 0; % not connected
            
            % other properties
            self.NumberOfSlots = 0;
            self.TunableLaserSlot = 0; % determined in slot info function
            self.Password = '1234';
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
            self.Param.COMPort = 5; %  GPIB port #
            self.Param.TunableLaserSlot = 0; % slot 0 in mainframe
            self.Param.PowerUnit = 0; % 0=dB, 1=W
            self.Param.PowerLevel = 0; % (dB if self.Param.PowerUnit=0)
            self.Param.LowSSE = 0; % 0=no, 1=low-noise scan
            
            self.TotalSlots = 0;
            self.TotalNumOfDetectors = 0;
        end
    end
        
   %% Connect
   methods
        
        %% Preset laser to known state
        function preset(self)
            invoke(self.GroupObj.Mainframespecific, 'preset', self.Session)
        end
        
        %% Turn laser off
        function off(self)
            if self.Lasing
                self.Busy = 1;
                try
                    invoke(self.GroupObj.Tunablelasersources, 'settlslaserstate', self.TunableLaserSlot, 0); % turn the tunable laser off
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
                    invoke(self.GroupObj.Tunablelasersources, 'settlslaserstate', self.TunableLaserSlot, 1); % turn the tunable laser off
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
                resp = invoke(self.GroupObj.Tunablelasersources, 'gettlslaserstateq',0); % slot = 0
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
            invoke(self.GroupObj.Tunablelasersources,'settlswavelength',self.TunableLaserSlot,wvlSel,self.nm2m(wvl));
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
            invoke(self.GroupObj.Tunablelasersources,'settlspower',self.TunableLaserSlot,self.Param.PowerUnit,powerSel,pwr);
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
            self.GroupObj.Multiframelambdascan = get(self.Obj, 'Applicationswavelengthscanfunctionsmultiframelambdascan');
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
                invoke(self.GroupObj.Tunablelasersources,'settlsopticaloutput',self.TunableLaserSlot,self.Param.LowSSE);
            end
            self.Busy = 0;
        end
        
        %% send params (overloads superclass method)
        function sendParams(self)
            Attenuation = 0;
            try
                invoke(self.GroupObj.Tunablelasersources,'settlsparameters',...
                    self.TunableLaserSlot,...
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
                0);
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
                invoke(self.GroupObj.Tunablelasersources, 'gettlswavelengthq', self.TunableLaserSlot);
        end
        
        %% Returns the current laser power as well as the min and max power bounds
        function [pwr] = queryPower(self)
            [~, self.MinPower, ~, self.MaxPower, pwr] = invoke(self.GroupObj.Tunablelasersources,...
                'gettlspowerq', self.TunableLaserSlot);
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
                        0, self.Password);
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
                self.NumPWMChannels = sum(slotInfo(2:end));
                self.PWMSlotInfo = slotInfo(2:end);
                l_dNum = self.NumPWMChannels
                l_slots = self.PWMSlotInfo
            catch ME
                error('did not get slot info');
                disp(ME.message)
            end
        end
        
    end
    
%% new methods

    methods
        function self = connect(self)
            %first check if connected already
            if self.Connected == 1 %1 means connected
                err = MException('ThermalController:Connection',...
                    'thermal controller is already connected');
                throw(err);
            end
            % connect to GPIB port
            try
                self.Obj = gpib('ni',1,self.Param.COMPort);
                fopen(self.Obj);
            catch ME
                error (ME.message);
            end
            
            try
                constant_t_cmd = 'TMOD CC';  % the default mode is constant temp (CT) mode 
                self.send_command(constant_t_cmd); % sets instrument to constant temperature mode

            catch ME
                rethrow(ME);
            end
            
         %  if connection successful, tell user and change self.Connected
            if strcmp(self.Obj.Status, 'open')
                self.Connected = 1;
                msg = strcat(self.Name, ' connected');
                disp(msg);
            end
        end
        
        function self = disconnect(self)
            % check if stage is connected
            if self.Connected == 0
                msg = strcat(self.Name,' is not connected');
                error(msg);
            end
            % try to close connection and delete serial port object
            try
                fclose(self.Obj);
                delete(self.Obj);
            catch ME
                error(ME.message);
            end
            self.Connected = 0;
            msg = strcat(self.Name, ' disconnected');
            disp(msg);
        end
        
    
        
   %%%----------------------TEC limit setting--------------------------------     
               
        
        function self = set_hi_t_limit(self, temp)
            %set the maximum temp of the controller
            self.MAX_TEMP = temp;
            set_hi_temp = strcat(['TMAX ', num2str(self.MAX_TEMP)]);
            self.send_command(set_hi_temp);
          end
        
        function self = set_low_t_limit(self, temp)
            %set the minimum temp of the controller
            self.MIN_TEMP = temp;
            set_low_temp = strcat(['TMIN ',num2str(self.MIN_TEMP)]);
            self.send_command(set_low_temp);
        end
        
        function self = set_hi_c_limit(self,current)
            % set the current limit of the controller
            self.MAX_CURRENT= current;
            set_hi_c = strcat(['TILM ',num2str(self.MAX_CURRENT)]);
            self.send_command(set_hi_c);
        end
        
         function self = set_hi_v_limit(self,voltage)
            % set the voltage limit of the controller
            self.MAX_V= voltage;
            set_hi_v = strcat(['TVLM ',num2str(self.MAX_V)]);
            self.send_command(set_hi_v);
         end
        
          function self = set_hi_r_limit(self,resistance)
            % set the maximum resistance in kilo ohm
            self.MAX_R=resistance;
            set_hi_r = strcat(['TRMX ',num2str(self.MAX_R)]);
            self.send_command(set_hi_r);
         end   
         
          function self = set_low_r_limit(self,resistance)
            % set the minimum resisance in kilo ohm
            self.MIN_R=resistance;
            set_low_r = strcat(['TRMN ',num2str(self.MIN_R)]);
            self.send_command(set_low_r);
          end   
         
  %%%-------------------------TEC setting commands---------------------------
  
          function self = set_Temp_Setpoint(self, temp)
            %set the current temp of the controller
            self.Temp_Setpoint = temp;
            set_Temp_Setpoint = strcat(['TEMP ', num2str(self.Temp_Setpoint)]);
            self.send_command(set_Temp_Setpoint);
          end
          
          function self = set_Current_Setpoint(self, current)
            %set the current of the controller
            self.Current_Setpoint = current;
            set_Current_Setpoint = strcat(['TCUR ', num2str(self.Current_Setpoint)]);
            self.send_command(set_Current_Setpoint);
          end
        
          function self=set_resistance_Setpoint(self,resistance)
             %set the TEC resistance setpint in kilo ohm
             self.Resistance_Setpoint=resistance;
             set_Resistance_Setpoint=strcat(['TRTH ',num2str(self.Resistance_Setpoint)]);
             self.send_command(set_Resistance_Setpoint);
          end
          
   %%%---------------------TEC monitor ---------------------------------       
          
        function self = check_temp(self)
            % query the sensor temperature in °C
            check_temp = 'TTRD?';
            self.send_command(check_temp);
            temp = fscanf(self.Obj);
            disp(['Current temp is ', temp,'°C']);
        end
        
        function self=check_current(self)
            % qurey the TEC operating current in ampere
             check_current='TIRD?';
             self.send_command(check_current);
             current=fscanf(self.Obj);
             disp(['Current current is ', current,'A']);
        end  
        
        function self=check_voltage(self)
            % query the TEC voltage in volts
             check_voltage='TVRD?';
             self.send_command(check_voltage);
             voltage=fscanf(self.Obj);
             disp(['Current voltage is ',voltage,'V']);         
        end 
          
        function self=check_raw_thermometer(self)
            %query the raw sensor value in kilo ohm,voltes or micro ampere
            check_thermometer='TRAW?';
            self.send_command(check_thermometer);
            thermometer=fscanf([self.Obj]);
            disp(['Current thermometer is ',thermometer]);     
        end
        
        function self=check_temperature_SensorStatus(self)
            % query the sensor status. Return OK=1 or Fault=0, based on
            % whether the sensor reading is within hardware bounds
            check_temperature_SensorStatus='TSNS?';
            self.send_command(check_temperature_SensorStatus);
            temperature_SensorStatus=fscanf([self.Obj]);
           if temperature_SensorStatus==0     
            disp('Currrent temperature sensor status is fault');     
           else
             disp('Currrent temperature sensor status is OK');           
           end
        end
        
      
        
        
        
   %%%-------------------TEC configuration setting----------------------
    % Proportional-integral-differential(PID). P: -0.62A/°C, I:0.131/s; D:1.90s
   
     function self=set_Autotune(self,value)
           % set the temperature control autotune process (off=0, on=1)
           self.Autotune=value;
           set_Autotune=strcat(['TUNE ',num2str(self.Autotune)]);
           self.send_command(set_Autotune);
     end
    
     function self=set_Auto_StepSize(self,stepsize)
          % se the temperature control autotune step size in Amp
          self.Auto_StepSize=stepsize;
          set_Auto_StepSize=strcat(['TATS ',num2str(self.Auto_StepSize)]);
          self.send_command(set_Auto_StepSize);     
     end
     
     function self=set_P_gain(self,P)
         % set the temperature control loop proportional gain in A/°C
         self.P_gain=P;
         set_P_gain=strcat(['TPGN ', num2str(self.P_gain)]);
         self.send_command(set_P_gain);
     end 
     
     function self=set_I_gain(self,I)
         % set the temperature control loop integral gain in /s
         self.I_gain=I;
         set_I_gain=strcat(['TIGN ', num2str(self.I_gain)]);
         self.send_command(set_I_gain);
     end 
     
     function self=set_D_gain(self,D)
         % set the temperature control loop derivative gain in s
         self.D_gain=D;
         set_D_gain=strcat(['TDGN ', num2str(self.D_gain)]);
         self.send_command(set_D_gain);
     end 
     
  %%%---------------------TEC  sensor commands---------------------------   
     
    function self=set_Thermo_type(self,Type)
        % set the temperature sensor type, NTC10uA=0; NTC100uA=1, 
        % NTC1mA=2, NTCAUTO=3, RTD=4, LM355=5, AD590=6
        self.Thermo_type=Type;
        set_Thermo_type=strcat(['TSNR ',num2str(self.Thermo_type)]);
        self.send_command(set_Thermo_type);
    end
    function self=set_calib_mode(self,Model)  
        % set the NTC calibration mode. Beta=0, SHH=1, NONE=2;
        self.NTC_Model=Model;
        set_calib_mode=strcat(['TMDN ',num2str(self.NTC_Model)]);
        self.send_command(set_calib_mode);
    end
   
     function self=set_SHH_A(self,A)  
        % set the Sternhart-Hart Coefficient A
        self.SHH_A=A;
        set_SHH_A=strcat(['TSHA ',num2str(self.SHH_A)]);
        self.send_command(set_SHH_A);
     end
   
       function self=set_SHH_B(self,B)  
        % set the Sternhart-Hart Coefficient B
        self.SHH_B=B;
        set_SHH_B=strcat(['TSHB ',num2str(self.SHH_B)]);
        self.send_command(set_SHH_B);
       end
   
       function self=set_SHH_C(self,C)  
        % set the Sternhart-Hart Coefficient C
        self.SHH_C=C;
        set_SHH_C=strcat(['TSHC ',num2str(self.SHH_C)]);
        self.send_command(set_SHH_C);
       end
    
   
  %%%-------------------TEC trip-off-----------------------------------
  
  function self=set_Trip_off_Thermometer(self,status)
      % set the TEC trip off upon thermometer fault (No=1,Yes=1)
      self.Trip_off_Thermometer=status;
      set_Trip_off_Thermometer=strcat(['TTSF ',num2str(status)]);
      self.send_command(set_Trip_off_Thermometer);
  end
  
  function self=set_Trip_off_MaxTemp(self,status)
    % set the TEC trip off upon exceeding max Temp (No=1,Yes=1)
      self.Trip_off_MaxTemp=status;
      set_Trip_off_MaxTemp=strcat(['TTMX ',num2str(self.Trip_off_MaxTemp)]);
      self.send_command(set_Trip_off_MaxTemp);
  end
  
  function self=set_Trip_off_MinTemp(self,status)
    % set the TEC trip off upon exceeding min Temp (No=1,Yes=1)
      self.Trip_off_MinTemp=status;
      set_Trip_off_MinTemp=strcat(['TTMN ',num2str(self.Trip_off_MinTemp)]);
      self.send_command(set_Trip_off_MinTemp);
  end
      
   function self=set_Trip_off_MaxCurrent(self,status)
    % set the TEC trip off upon exceeding current limit (No=1,Yes=1)
      self.Trip_off_MaxCurrent=status;
      set_Trip_off_MaxCurrent=strcat(['TTIL ',num2str(self.Trip_off_MaxCurrent)]);
      self.send_command(set_Trip_off_MaxCurrent);
   end
   
  function self=set_Trip_off_MaxVoltage(self,status)
    % set the TEC trip off upon exceeding voltage limit (No=1,Yes=1)
      self.Trip_off_MaxVoltage=status;
      set_Trip_off_MaxVoltage=strcat(['TTVL ',num2str(self.Trip_off_MaxVoltage)]);
      self.send_command(set_Trip_off_MaxVoltage);
  end
     
           
           
   %%%----------------------------------------------------------        
     
        
        function self = send_command(self, command)
            if self.Obj.BytesAvailable > 0
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            
            if strcmp(self.Obj.Status,'open')  %if connection is open
                fprintf(self.Obj, command);
            else
                err = MException('ThermalController:Com',...
                    'thermal controller Connected: connection closed');
                throw(err);
            end
        end
 
        function self = start(self)
            set_temp = strcat(['tec:t ',num2str(self.Param.TargetTemp)]);
            %the space is required, so use [] to make strcat preserve it
            start_tec = strcat('tec:output 1');
            self.send_command(set_temp);
            self.send_command(start_tec);
        end
        
        function self = stop(self)
            stop_tec = ('tec:output 0');
            self.send_command(stop_tec);
        end
        
      
    end
    
end