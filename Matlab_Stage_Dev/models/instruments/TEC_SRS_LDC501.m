classdef TEC_SRS_LDC501 < InstrClass
    
    properties (Access = protected)

        Autotune_StepSize;   % set the temperature control autotune step size in Amm. The default value is 10% of TILM, up to 25%.
        Thermo_type;  % set the temperature sensor type, NTC10uA=0; NTC100uA=1, NTC1mA=2, NTCAUTO=3, RTD=4, LM355=5, AD590=6    
        Control; %1: TEC temp control on ; 0: TEC control off
        
        Trip_off_Thermometer;    % set the TEC trip off upon thermometer fault (No=1,Yes=1)
        Trip_off_MaxTemp;        % set the TEC trip off upon exceeding max temp (No=1,Yes=1)
        Trip_off_MinTemp;        % set the TEC trip off upon exceeding min temp (No=1,Yes=1)
        Trip_off_MaxCurrent;     % set the TEC trip off upon excedding max current (No=1,Yes=1)
        Trip_off_MaxVoltage;     % set the TEC trip off upon exceeding max voltage (No=1,Yes=1)
        
        NTC_Model;    % set the NTC calibration mode. Beta=0, SHH=1, NONE=2;
%moved to AppSettings
%         SHH_A;        % A=1.20836e-3;
%         SHH_B;        % B=2.41165e-4;
%         SHH_C;        % C=1.48267e-7;
%         P_gain;       %set the temperature control loop proportional gain
%         I_gain;       % sett the temperature control loop integral gain
%         D_gain;       % set the temperature control loop derivative gain
        MIN_TEMP;  % degrees C   10 degree
        MAX_TEMP;  % degrees C   120 degree
        MAX_CURRENT; % in amps, given by peltier cooler manufacturer  1.4 A
        MAX_V;     % in volts  8.5V
        MAX_R;     % upper resitance limit in kilo ohm
        MIN_R;     % lower resistance limit in kilo ohm
        
        Timeout;  %COM timeout

    end
    
    methods
        % constructor
        function self = TEC_SRS_LDC501()
            self.Name = 'SRS LDC501';
            self.Group = 'TEC';
            self.Model = 'LDC501';
            self.Serial = 'xx';
            self.MsgH = ' ';
            self.CalDate = date;
            self.Connected = 0;  % 0 = not connected, 1 = connected
            self.Busy = 0;  % 0 = not busy, 1 = busy
            self.Timeout = 10; %com time out
            
          
            self.Autotune_StepSize=0.14;   % set the temperature control autotune step size in Amm. The default value is 10% of TILM, up to 25%.
            self.Control = 0; 
            self.Thermo_type=3; 

            self.NTC_Model=1; % set the NTC calibration mode. Beta=0, SHH=1, NONE=2;
            
            self.Trip_off_Thermometer=1;    % set the TEC trip off upon thermometer fault (No=1,Yes=1)
            self.Trip_off_MaxTemp=1;        % set the TEC trip off upon exceeding max temp (No=1,Yes=1)
            self.Trip_off_MinTemp=1;        % set the TEC trip off upon exceeding min temp (No=1,Yes=1)
            self.Trip_off_MaxCurrent=0;     % set the TEC trip off upon excedding max current (No=1,Yes=1)
            self.Trip_off_MaxVoltage=0;     % set the TEC trip off upon exceeding max voltage (No=1,Yes=1)
            
            self.MIN_TEMP=10;  % degrees C   10 degree
            self.MAX_TEMP=80;  % degrees C   120 degree
            self.MAX_CURRENT=1.4; % in amps, given by peltier cooler manufacturer  1.4 A
            self.MAX_V=8.5;     % in volts  8.5V
            self.MAX_R=20e3;     % upper resitance limit in kilo ohm
            self.MIN_R=100;     % lower resistance limit in kilo ohm
            
            % serial port connection parameters
            self.Obj = ' ';  % becomes serial port object
            self.Param.COMPort = 3; % GPIB address
            self.Param.BaudRate = 9600;
            self.Param.DataBits = 8;
            self.Param.StopBits = 1;
            self.Param.Terminator = 'LF';
            self.Param.Parity = 'none';
            self.Param.UpdatePeriod = 10; % (s) update reading timer
            self.Param.TargetTemp= 25; 
            %The following are needed for current or resistance control
            %self.Param.TargetCurrent = 1; in Amperes 
            %self.Param.TargetResistance = 10; in kOhms
                
        end
    end
    
    
 % -----------------------------TEC connection----------------------------- 
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
                constant_t_cmd = 'TMOD CT';  % the default mode is constant temp (CT) mode 
                self.send_command(constant_t_cmd); % sets instrument to constant temperature mode
                self.set_hi_t_limit(self.MAX_TEMP);
                self.set_low_t_limit(self.MIN_TEMP);
                self.set_hi_c_limit(self.MAX_CURRENT);
                self.set_hi_v_limit(self.MAX_V);
                self.set_hi_r_limit(self.MAX_R);
                self.set_low_r_limit(self.MIN_R);
                
                self.set_thermo_type(self.Thermo_type);
                
                self.set_Trip_off_Thermometer(self.Trip_off_Thermometer);
                self.set_Trip_off_MaxTemp(self.Trip_off_MaxTemp);
                self.set_Trip_off_MinTemp(self.Trip_off_MinTemp);
                self.set_Trip_off_MaxCurrent(self.Trip_off_MaxCurrent);
                self.set_Trip_off_MaxVoltage(self.Trip_off_MaxVoltage);
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
        
        function self = PID_calibration(self,Autotune,P,I,D)
            %checks if AppSettings.TEC.Autotune is set to 1
            if Autotune ==1
                self.autotune();
            else
                %if 0 then set PID manually
                %get PID values from AppSettings.TEC
                self.set_P_gain(P);
                self.set_I_gain(I);
                self.set_D_gain(D);
            end
        end
        function self = set_thermistor_model(self,SSH_A,SSH_B,SSH_C)
            self.set_calib_mode(self,self.NTC_Model)
            % set the NTC calibration mode. Beta=0, SHH=1, NONE=2;
            self.set_SHH_A(SHH_A);
            self.set_SHH_B(SHH_B);
            self.set_SHH_C(SHH_C);
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
            self.Param.TargetTemp =temp; 
            set_Temp_Setpoint = strcat(['TEMP ', num2str(self.Param.TargetTemp)]);
            self.send_command(set_Temp_Setpoint);
          end
          
          function self = set_Current_Setpoint(self, current)
            %set the current of the controller
            self.Param.TargetCurrent = current;
            set_Current_Setpoint = strcat(['TCUR ', num2str(current)]);
            self.send_command(set_Current_Setpoint);
          end
        
          function self=set_resistance_Setpoint(self,resistance)
             %set the TEC resistance setpint in kilo ohm
             self.TargetResistance=resistance;
             set_Resistance_Setpoint=strcat(['TRTH ',num2str(resistance)]);
             self.send_command(set_Resistance_Setpoint);
          end
          
   %%%---------------------TEC monitor ---------------------------------       
          
        function [temp, self] = currentTemp(self)
            % query the sensor temperature in �C
            check_temp = 'TTRD?';
            self.send_command(check_temp);
            temp = self.read_response();
            %disp(['Current temp is ', temp,'�C']);
        end
        
        function [current, self]=check_current_current(self)
            % qurey the TEC operating current in ampere
             check_current='TIRD?';
             self.send_command(check_current);
             current=self.read_response();
             disp(['Current current is ', current,'A']);
        end  
        
        function [voltage, self]=check_current_voltage(self)
            % query the TEC voltage in volts
             check_voltage='TVRD?';
             self.send_command(check_voltage);
             voltage=self.read_response();
             disp(['Current voltage is ',voltage,'V']);         
        end 
          
        function self=check_raw_thermometer(self)
            %query the raw sensor value in kilo ohm,voltes or micro ampere
            check_thermometer='TRAW?';
            self.send_command(check_thermometer);
            thermometer=self.read_response;
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
    % Proportional-integral-differential(PID). P: -0.62A/�C, I:0.131/s; D:1.90s
   
     function self=autotune(self)
            %Tunes the PID controller automatically
           set_Autotune=strcat('TUNE 1');
           self.send_command(set_Autotune);
     end
    
     function self=set_Autotune_StepSize(self)
          % se the temperature control autotune step size in Amp
          set_Autotune_StepSize=strcat(['TATS ',num2str(self.Autotune_StepSize)]);
          self.send_command(set_Autotune_StepSize);     
     end
     
     function self=set_P_gain(self,P)
         % set the temperature control loop proportional gain in A/�C
         set_P_gain=strcat(['TPGN ', num2str(P)]);
         self.send_command(set_P_gain);
     end 
     
     function self=set_I_gain(self,I)
         % set the temperature control loop integral gain in /s
         set_I_gain=strcat(['TIGN ', num2str(I)]);
         self.send_command(set_I_gain);
     end 
     
     function self=set_D_gain(self,D)
         % set the temperature control loop derivative gain in s
         set_D_gain=strcat(['TDGN ', num2str(D)]);
         self.send_command(set_D_gain);
     end 
     
  %%%---------------------TEC  sensor commands---------------------------   
     
    function self=set_thermo_type(self,Type)
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
        set_SHH_A=strcat(['TSHA ',num2str(A)]);
        self.send_command(set_SHH_A);
     end
   
       function self=set_SHH_B(self,B)  
        % set the Sternhart-Hart Coefficient B
        set_SHH_B=strcat(['TSHB ',num2str(B)]);
        self.send_command(set_SHH_B);
       end
   
       function self=set_SHH_C(self,C)  
        % set the Sternhart-Hart Coefficient C
        set_SHH_C=strcat(['TSHC ',num2str(C)]);
        self.send_command(set_SHH_C);
       end
    
   
  %%%-------------------TEC trip-off-----------------------------------
  
  function self=set_Trip_off_Thermometer(self,status)
      % set the TEC trip off upon thermometer fault (No=0,Yes=1)
      self.Trip_off_Thermometer=status;
      set_Trip_off_Thermometer=strcat(['TTSF ',num2str(status)]);
      self.send_command(set_Trip_off_Thermometer);
  end
  
  function self=set_Trip_off_MaxTemp(self,status)
    % set the TEC trip off upon exceeding max Temp (No=0,Yes=1)
      self.Trip_off_MaxTemp=status;
      set_Trip_off_MaxTemp=strcat(['TTMX ',num2str(self.Trip_off_MaxTemp)]);
      self.send_command(set_Trip_off_MaxTemp);
  end
  
  function self=set_Trip_off_MinTemp(self,status)
    % set the TEC trip off upon exceeding min Temp (No=0,Yes=1)
      self.Trip_off_MinTemp=status;
      set_Trip_off_MinTemp=strcat(['TTMN ',num2str(self.Trip_off_MinTemp)]);
      self.send_command(set_Trip_off_MinTemp);
  end
      
   function self=set_Trip_off_MaxCurrent(self,status)
    % set the TEC trip off upon exceeding current limit (No=0,Yes=1)
      self.Trip_off_MaxCurrent=status;
      set_Trip_off_MaxCurrent=strcat(['TTIL ',num2str(self.Trip_off_MaxCurrent)]);
      self.send_command(set_Trip_off_MaxCurrent);
   end
   
  function self=set_Trip_off_MaxVoltage(self,status)
    % set the TEC trip off upon exceeding voltage limit (No=0,Yes=1)
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
   
   function [response, self] = read_response(self)
       response = '0';
       if ~self.Connected
           err = MException(strcat(self.Name,':Read'),...
               'temperature controller status: closed');
           throw(err)
       end
       start_time = tic;
       while toc(start_time) < self.Timeout
           if self.Obj.BytesAvailable >0
               response = fscanf(self.Obj);
               break
           else
               pause(self.PauseTime);
           end
       end
       if toc(start_time) >= self.Timeout
           err = MExcetpion(strcat(self.Name,':ReadTimeOut'),...
               'temprature controller timed out');
           throw(err);
       end
   end
        
   function self = start(self)
      %Todo; error handling
      cmd=strcat('TEON 1');
      self.send_command(cmd);
      self.Control = 1; 
   end
   
   function self = stop(self)
       %TODO: error handling
       cmd = ('TEON 0');
       self.send_command(cmd);
       self.Control= 0; 
   end
   
   
    end
    
end
