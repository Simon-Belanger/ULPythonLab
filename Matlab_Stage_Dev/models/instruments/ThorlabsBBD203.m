classdef ThorlabsBBD203 < InstrClass & CoordSysClass
    %UNTITLED Summary of this class goes here
    %   Detail description goes here
    
    properties (Access = protected)
        figActX; %Active X elements need a figure to load
        Timeout;
        isMoving; 
        Overshoot;

        
    end
    
    methods
        
        %%constructor
        function self = ThorlabsBBD203()
            %Superclass properties
            self.Name = 'ThorlabsBBD203'; % instrument name (for pull-down menus)
            self.Group = 'OpticalStage'; % instrument group (ex: laser, pump, stage, etc.)
            self.Model = 'BDC203'; % I think ; instrument model #
            self.Serial = 'xxxxx';
            self.CalDate = ''; % calibration date on instr
            self.Busy = 0; % instrument is busy=1, not=0
            self.Connected = 0; % instrument connected=1, disconnect=0
            self.isMoving = 0; %
            
            %instrument parameters
            self.Param.COMPort = 'NaN';
            self.Param.SN1 = 94833200;  %Serial number for Axis X linear stage
            self.Param.SN2 = 94833201;  %Serial number for Axis Y linear stage
            self.Param.Velocity = 3; %mm/s
            self.Param.Acceleration = 500; %mm/s^2
            
            self.Timeout = 40; % s; needs to be longer than the longest move over the whole chip
            self.Overshoot = 20; %in [um] 
            %self.Param; % instrument parameters, assign in constructor
            
        end
    
        %%connect
        function self = connect(self)
            
            %Create figure: Active X elements need a figure to load
            self.figActX = figure(...
                'Name','Thorlab Stage Controller',...
                'Menu','None',...
                'WindowStyle','normal',...
                'Visible','on',...  %This can be switched off later
                'Position',[10, 360, 820, 390],...
                'CloseRequestFcn', {@self.close_figActX});
            try
                self.Obj.hActX1 = actxcontrol('MGMOTOR.MGMotorCtrl.1',...
                    'Position', [20 20 400 300],...
                    'parent', self.figActX); % Create ActiveX Controller X-Axis
                self.Obj.hActX2 = actxcontrol('MGMOTOR.MGMotorCtrl.1',...
                    'Position', [420 20 400 300],...
                    'parent', self.figActX); % Create ActiveX Controller Y-Axis
            catch ME
                close(self.figActX); %delete figure
                rethrow(ME);
            end
            
            %init X-Axis
            self.Obj.hActX1.StartCtrl; %Start control
            set(self.Obj.hActX1,'HWSerialNum', self.Param.SN1); % set the serial number
            self.Obj.hActX1.Identify; %Identify the device
            pause(2); %waiting for the GUI to load up
            
            self.Obj.hActX1.registerevent({'MoveComplete', @self.MoveCompleteHandler1;...
                'HomeComplete', @self.HomeCompleteHandler1}); %Event handing callbacks setup
            %init Y-Axis
            self.Obj.hActX2.StartCtrl; %Start control
            set(self.Obj.hActX2,'HWSerialNum', self.Param.SN2); % set the serial number
            self.Obj.hActX2.Identify; %Identify the device
            pause(2); %waiting for the GUI to load up
            
            self.Obj.hActX2.registerevent({'MoveComplete', @self.MoveCompleteHandler2;...
                'HomeComplete', @self.HomeCompleteHandler2}); %Event handing callbacks setup
            
            self.setVelocity(self.Param.Velocity);
            self.setAcceleration(self.Param.Acceleration);
            
            %optical stage is connected; set flag. 
            self.Connected = 1; 
        end
        
        %%callback function for ActX figure
        function self = close_figActX(self,hObject,eventdata)
           delete(gcbf);
        end
        
        %%Disconnect stage controller
        function self = disconnect(self)
            if self.Connected
                self.Obj.hActX1.StopCtrl();
                self.Obj.hActX2.StopCtrl();
                self.Connected = 0; 
                close(self.figActX); %delete invisible figure 
            else
                msg = strcat(self.Name, ' is not connected'); 
                error(msg); 
            end
        end
        %% Event handlers
        function MoveCompleteHandler1(self,varargin)
            self.isMoving = 0;
            disp('X-axis move complete: in event handler');
        end
        function MoveCompleteHandler2(self,varargin)
            self.isMoving = 0; 
            disp('Y-axis move complete: in event handler');
        end
        
        %% set velocity
        function self = setVelocity(self, vel)
            if self.Connected
                self.Obj.hActX1.SetVelParams(0,0,self.Param.Acceleration,vel); %Set max velocity
                self.Obj.hActX2.SetVelParams(0,0,self.Param.Acceleration,vel); %Set max velocity
                self.Param.Velocity = vel;
                t=vel/self.Param.Acceleration;
                self.Overshoot = (1/2)*self.Param.Acceleration*(t^2)*1e3; %Convert from mm to microns
            end
        end
        %% set acceleration
        function self = setAcceleration(self, accel)
            if self.Connected
                self.Obj.hActX1.SetVelParams(0,0,accel,self.Param.Velocity); %Set max velocity
                self.Obj.hActX2.SetVelParams(0,0,accel,self.Param.Velocity); %Set max velocity
                self.Param.Acceleration = accel;
                t = self.Param.Velocity/accel;
                self.Overshoot = (1/2)*accel*(t^2)*1e3; %Convert form mm to microns
            end
        end
        
        
        %% move commands
        function self = move_x(self, distance)
            %distance in um
            if self.Connected
                self.Busy = 1; 
                self.isMoving = 1; 
                self.Obj.hActX2.SetRelMoveDist(0,distance/1000);
                self.Obj.hActX2.MoveRelative(0,1==0);
                t1=clock;
                while (self.isMoving==1  && etime(clock,t1)<self.Timeout)
                    pause(0.01);
                end
                self.Busy = 0;
            else
               err = MException(strcat(self.name,':MoveX'),...
                   'move_x: optical stage not connected');
               self.Busy=0;
               throw(err); 
            end
        end
        function self = move_y(self, distance)
            %distance in um
            if self.Connected
                self.Busy = 1;
                self.isMoving = 1;
                self.Obj.hActX1.SetRelMoveDist(0,distance/1000);
                self.Obj.hActX1.MoveRelative(0,1==0);
                t1=clock;
                while (self.isMoving==1  && etime(clock,t1)<self.Timeout)
                    pause(0.01);
                end
                 self.Busy = 0;               
            else
                err = MException(strcat(self.name,':MoveX'),...
                    'move_x: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        function self = move_z(self, distance)
            %distance in um
           zz = 0; %Dummy function; no motorized z-axis 
        end
        function self = moveTo(self, x,y)
            %x, y are device coordinates from gds file
            if self.coordSysIsValid
                msg = strcat(self.Name, ': moving to ', x, ',', y);
                disp(msg);
                %compute motor position from GDS coordinates
                motor_pos =self.transform([x;y]);
                %DEBGU: display text
                disp('transformation of GDS coordinates:');
                disp(strcat('GDS: ', num2str(x),',',num2str(y)));
                disp(strcat('Motor pos: ', num2str(motor_pos(1)),',',num2str(motor_pos(2))));
                
                self.Busy = 1; 
                self.move_abs_x(motor_pos(1));
                self.move_abs_y(motor_pos(2));
                
                self.Busy = 0;
            else
                err = MException(strcat(self.name,':moveTo'),...
                    'coordinate System is not setup');
                self.Busy=0;
                throw(err);
            end
        end
        
        %%getPosition
        function [xx,yy,zz] = getPosition(self)
            %out put in um (convert from mm to um)
            if self.Connected
                self.Busy = 1;
                xx = 0; yy = 0; zz = 0; %zz: dummy variable; no motorized Z-Axis
                xx = self.Obj.hActX2.GetPosition_Position(0)*1000;
                yy = self.Obj.hActX1.GetPosition_Position(0)*1000;
                
                
                self.Busy = 0;
            else
                err = MException(strcat(self.name,':GetPosition'),...
                    'optical stage not connected');
                self.Busy=0;
                throw(err);              
           end
        end
        
        function self = set_trigger_config(self, status)
            switch status
                case 0 %Switch off
                    a=0;b=1;c=1;
                case 1 %Switch on
                    a=0; b=1; c=6;
            end
            %Goes high when max velocity reached
            self.Obj.hActX1.SetDCTriggerParams(a,b,c);
        end
        
        function self = triggered_move(self,direction,move_distance,trigger_pos)
            %distance in um
            %trigger_pos is ignored as thorlabs stage is velocity triggered
            if self.Connected
                self.Busy = 1; 
                self.isMoving = 1; 
                self.Obj.hActX1.SetRelMoveDist(0,move_distance/1000);
                self.Obj.hActX1.MoveRelative(0,1==1);
                t1=clock;
                while (self.isMoving==1  && etime(clock,t1)<self.Timeout)
                    pause(0.01);
                end
                self.Busy = 0;
            else
               err = MException(strcat(self.name,':TrigMoveY'),...
                   'trig_move_Y: optical stage not connected');
               self.Busy=0;
               throw(err); 
            end            
        end
        
        %set property
        function self = setProp(self,prop,val)
            if self.(prop)
                self.(prop) = val;
            else
                msg = strcat(' ', prop, ' does not exist.');
                err = MException(strcat(self.Name,':setProp'),msg);
                throw(err);                
            end
        end
         
        % get property
        function val = getProp(self, prop)
            if self.(prop)
                val = self.(prop);
            else
                msg = strcat(self.Name, ' ', prop, ' does not exist.');
                err = MException(strcat(self.Name,':getProp'),msg);
                throw(err);
            end
        end       
        
         %% send params (overloads super class method)
        function sendParams(self)
            try
                self.setAcceleration(self.Param.Acceleration);
                self.setVelocity(self.Param.Velocity);
            catch ME
                rethrow(ME);
            end
        end
        
        
    end
    
    %%Private methods
    methods (Access = private)
        function self = move_abs_x(self, absX)
            %absX is in um 
            if self.Connected
                self.Busy = 1; 
                self.isMoving = 1;
                self.Obj.hActX2.SetAbsMovePos(0,absX/1000)
                self.Obj.hActX2.MoveAbsolute(0,1==0);
                t1=clock;
                while (self.isMoving==1  && etime(clock,t1)<self.Timeout)
                    pause(0.01);
                end
                self.Busy = 0; 
            else
                err = MException(strcat(self.name,':Move Abs X'),...
                    'move_x: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        function self = move_abs_y(self, absY)
            %absY is in um 
            if self.Connected
                self.Busy = 1;
                self.isMoving = 1;
                self.Obj.hActX1.SetAbsMovePos(0,absY/1000)
                self.Obj.hActX1.MoveAbsolute(0,1==0);
                t1=clock;
                while (self.isMoving==1  && etime(clock,t1)<self.Timeout)
                    pause(0.01);
                end
                self.Busy = 0;
            else
                err = MException(strcat(self.name,':Move Abs Y'),...
                    'move_y: optical stage not connected');
                self.Busy=0;
                throw(err);
            
            end
        end
    end
    
    
end