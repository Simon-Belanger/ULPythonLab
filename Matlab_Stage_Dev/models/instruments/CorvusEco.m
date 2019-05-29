classdef CorvusEco < InstrClass & CoordSysClass
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        Overshoot;
        PauseTime;
        Timeout;
        Calibrated;
        xPos;
        yPos;
        zPos;
        %ValidCoordinateSystem;
    end
    
    methods
        
        %% constructor
        function self = CorvusEco()
            % super class properties
            self.Name = 'CorvusEco'; % name of the instrument
            self.Group = 'OpticalStage'; % instrument group this one belongs to
            self.Connected = 0;
            self.Busy = 0;
            self.Model = 'SMC-corvus eco'; % instrument model #
            self.Serial = '1204-0403';
            self.CalDate = ''; % calibration date on instr
            
            
            % instrument parameters
            self.Param.COMPort = 11;
            self.Param.BaudRate = 57600;
            self.Param.StopBits = 0;
            self.Param.Parity = 0;
            self.Param.Acceleration = 500; % mm/s^2
            self.Param.Velocity = 5; % mm/s
            
            % object properties
            self.Calibrated = 0; % stage calibrated
            self.xPos = nan; % initialize to nan to ensure calibration
            self.yPos = nan; % initialize to nan to ensure calibration
            self.zPos = nan; % initialize to nan to ensure calibration
            self.Overshoot = 0.02; % mm
            self.PauseTime = 0.03; % mm
            self.Timeout = 10; % s
            %self.ValidCoordinateSystem=0; %0: no coord Sys set up. 1: set up
            %uncomment if you don't derive from CoordSys class
        end
        
        %% connect
        function self = connect(self)
            
            %check if already open
            if self.Connected  %1: stage is ready
                err = MException(strcat(self.Name,':Connect'),...
                    'optical stage is already connected');
                throw(err);
            end
            
            % open port
            self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
            set(self.Obj,'BaudRate',self.Param.BaudRate);
            try
                fopen(self.Obj);
            catch ME
                rethrow(ME);
            end
            
            %optical stage is connected
            self.Connected = 1;
            
            %Enable Axis
            try
                for axis_num = 1:3
                    self.send_command(['1 ', num2str(axis_num), ' setaxis']);
                    %self.send_command([num2str(axis_num), ' getaxis']);
                    %response = self.read_response();
                end
                self.send_command('-1 getaxis');
                incoming = self.read_response();
            catch ME
                rethrow(ME)
            end
            in = str2num(incoming);
            if ~in(1) || ~in(2) || ~in(3)
                err = MException(strcat(self.Name,':EnableAxis'),...
                    'optical stage axis are not enabled');
                throw(err);
            end
            
            % Set units to mm
            self.send_command('2 0 setunit');
            self.send_command('2 1 setunit');
            self.send_command('2 2 setunit');
            self.send_command('2 3 setunit');
            
            % Set acceleration
            self.Param.Velocity = 5;
            self.Param.Acceleration = 500;
            
            % Set acceleration function
            self.send_command('0 setaccelfunc');
            
            %used for mapping
            trigger_distance_time = self.Param.Velocity/self.Param.Acceleration;
            self.Overshoot = max(0.04,(1/2)*self.Param.Acceleration*(trigger_distance_time.^2))*1000; %Stored in [um]
            
            % Set output port
            self.send_command('1 setout');
            
            % Set trigger out
            self.send_command('10 0 1 ot');
        end
        
        %% disconnect
        function self = disconnect(self)
            if self.Connected
                try
                    fclose(self.Obj);
                    delete(self.Obj);
                    self.Connected = 0;
                catch ME
                    error(ME.message)
                end
            else
                msg = strcat(self.Name, ' is not connected.');
                error(msg);
            end
        end
        
        %% set velocity
        function self = setVelocity(self, vel)
            %disp 'inside the set velocity function'
            if self.Connected
                command = [num2str(vel), ' sv'];
                self.send_command(command);
                self.send_command('gv');
                if str2num(self.read_response()) ~= vel
                    self.Param.Velocity = vel;
                end
                self.Param.Velocity = vel;
            end
        end
        
        %% set acceleration
        function self = setAcceleration(self, accel)
            if self.Connected
                command = [num2str(accel), ' sa'];
                self.send_command(command);
                self.send_command('ga');
                if str2num(self.read_response()) ~= accel
                    self.Param.Acceleration = accel;
                end  %this doesn't make sense here
                self.Param.Acceleration = accel;
            end
        end
        
        function [response, self] = read_response(self)
            response = '0';
            if ~self.Connected
                err = MException(strcat(self.Name,':Read'),...
                    'optical stage status: closed');
                throw(err);
            end
            start_time = tic;
            while toc(start_time) < self.Timeout
                if self.Obj.BytesAvailable > 0
                    response = fscanf(self.Obj);
                    break
                else
                    pause(self.PauseTime);
                end
            end
            if toc(start_time) >= self.Timeout
                err = MException(strcat(self.Name,':ReadTimeOut'),...
                    'optical stage connection timed out');
                throw(err);
            end
        end
        
        function self = check_status(self)
            self.Connected = 1;
            self.send_command('st');
            pause(self.PauseTime);
            resp = ~bitget(uint8(num2str(self.read_response())),1)
            self.Connected = resp(end);
        end
        
        %% send command
        function self = send_command(self, command)
            if self.Obj.BytesAvailable > 0  %empty buffer
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            
            if self.Connected
                fprintf(self.Obj, command);
            else
                err = MException(strcat(self.Name,':Send'),...
                    'optical stage status: connection closed');
                throw(err);
            end
        end
        
        function self = wait_for_command(self)
            start_time = tic;
            while (~self.Obj.BytesAvailable && toc(start_time) < self.Timeout)
                pause(self.PauseTime);
            end
            if toc(start_time) >= self.Timeout
                err = MException(strcat(self.Name,':WaitForCommand'),...
                    'optical stage connection timed out');
                self.send_command('clear'); %Clears stack on Corvus
                throw(err);
            end
        end
        
        %% calibrate command
        function self = calibrate(self)
            if self.Connected
                if self.Busy
                    msg = strcat(self.Name, ' in motion. Wait until stopped to calibrate.');
                    error(msg);
                else
                    self.Busy = 1;
                    %                     cal_command = '0 0 0 setpos';  % sets the current position as the origin for all three axes
                    %                     self.send_command(cal_command);
                    %                     self.xPos = 0;
                    %                     self.yPos = 0;
                    %                     self.zPos = 0;
                    self.Calibrated = 1;
                    self.Busy = 0;
                end
            else
                err = MException(strcat(self.Name,':Calibration'),...
                    'Calibration: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        %% move commands
        function self = move_y(self, distance)
            if self.Connected
                %                 if self.Calibrated
                self.Busy = 1;
                move_cmd = [num2str(distance/1000), ' 0 0 r'];
                end_cmd = '0 0 0 r';
                stop_cmd = 'st';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                %                    self.yPos = self.yPose + distance/1000;
                self.Busy = 0;

            else
                err = MException(strcat(self.Name,':MoveY'),...
                    'move_y: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        function self = move_x(self, distance)
            if self.Connected
                %                 if self.Calibrated
                self.Busy = 1;
                move_cmd = ['0 ', num2str(distance/1000), ' 0 r'];  %stage takes mm. the classes have um.
                end_cmd = '0 0 0 r';
                stop_cmd = 'st';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                %                    self.xPos = self.xPose + distance/1000;
                self.Busy = 0;

            else
                err = MException(strcat(self.Name,':MoveX'),...
                    'move_x: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        function self = move_z(self, distance)
            if self.Connected
                %                 if self.Calibrated
                self.Busy = 1;
                move_cmd = ['0 0 ', num2str(distance/1000), ' r'];
                end_cmd = '0 0 0 r';
                stop_cmd = 'st';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                %                    self.zPos = self.zPos + distance/1000;
                self.Busy = 0;

            else
                err = MException(strcat(self.Name,':MoveZ'),...
                    'move_z: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        function self = set_trigger_config(self,status)
            %status: not use here
            if self.Connected
                % Set output port
                self.send_command('1 setout');
            else
                err = MException(strcat(self.Name,':set_trigger_config'),...
                    'optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        function self = triggered_move(self, direction, move_distance, trigger_pos)
            self.Busy = 1;
            if strcmp(direction,'right')
                dir = 1;
            elseif strcmp(direction, 'left')
                dir = 0;
            else
                self.Busy=0;
                err = MException(strcat(self.Name,':TriggerMove'),...
                    'triggered move_y: invalid direction');
                throw(err);
            end
            
            %[trigger_pos][dir][axis][time][pol out][output] wpot
            pol = 0; %0: active low, 1: active high
            output = 1; %1,2,3 Equivalent I/O interface ouputs (pull up is soldered to 1)
            time = 5; %0-1000ms
            axis = 1;
            
            %move first, because wpot will block all incoming messages
            % relative movement comand 'x 0 0 rmove',
            move_cmd = [num2str(move_distance/1000), ' 0 0 rmove'];
            end_cmd = '0 0 0 r';
            stop_cmd = 'st';
            trig_cmd = [num2str(trigger_pos/1000), ' ', num2str(dir), ' ',num2str(axis),' ',num2str(time),' ',num2str(pol),' ',num2str(output),' wpot'];
            
            try
                self.send_command(move_cmd);
                self.send_command(trig_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
            catch ME
                %Could try to fix it here.
                self.Busy=0;
                rethrow(ME);
            end
            self.wait_for_command();
            self.Busy = 0;
            
        end

        function self = moveTo(self, x, y)
            % x,y are device coordinates from gds file
                             
            
            if self.coordSysIsValid
                try
                    [xx yy zz]=self.getPosition();
                catch ME
                    rethrow(ME)
                end
                ZPos = num2str(zz/1000); %getPosition gets it back in [um] stages needs it in[mm]
                
                msg = strcat(self.Name, ': moving to ', x, ',', y);
                disp(msg);
                %compute the strage position
                motor_pos=self.transform([x;y])
                
                disp('transformation of GDS coordinates:');
                disp(strcat('GDS: ', num2str(x),',',num2str(y)));
                disp(strcat('Motor pos: ', num2str(motor_pos(1)),',',num2str(motor_pos(2))));
                
                self.Busy = 1;
                move_cmd = [num2str(motor_pos(2)/1000), ' ', num2str(motor_pos(1)/1000), ' ', ZPos, ' m'];
                stop_cmd = 'st';
                end_cmd = '0 0 0 r';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                self.Busy = 0;
                
               
            else
                msg = strcat(self.Name, ': No valid coordinate system. Cannot move.');
                err = MException(strcat(self.Name,':moveTo'),msg);
                error(msg);
                throw(err);
            end

            
        end
         
        % set property
        function self = setProp(self, prop, val)
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
        
        %% get position
        function [xx, yy, zz] = getPosition(self)
            self.Busy = 1;
            xx=0; yy=0; zz=0;
            tries =0;
            error_flag=1;
            while (error_flag)
                error_flag = 0; % Ideally this would only happen once.
                if strcmp(self.Obj.Status,'open')
                    try %maybe this needs to be taken one level up?
                        self.send_command('pos');
                        self.wait_for_command();
                        incoming=self.read_response();
                        absPos = str2num(incoming);
                        yy = absPos(1)*1000;
                        xx = absPos(2)*1000;
                        zz = absPos(3)*1000;  % output all in [um]
                        
                    catch ME
                        % could add self diagnostics here;
                        error_flag = 1; 
                        tries = tries + 1; 
                        if numel(absPos)~=3
                            try
                                self.send_command('clear'); %delete the stack in the controller
                                pause(0.1);
                                if self.Obj.BytesAvailable > 0  %empty buffer
                                    fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
                                end
                                pause(0.1);
                            catch ME
                                self.Busy = 0;
                                rethrow(ME);
                            end
                        end
                        if (tries==5)
                            self.Busy = 0; 
                            rethrow(ME);
                        end
                    end
                else
                    err = MException(strcat(self.Name,':GetPosition'),...
                        'COM connection is either closed or non responsive');
                    self.Busy = 0;
                    throw(err);
                end
            end
            self.Busy = 0;
        end
        
                
        function self = abort(self)
            try
                self.send_command('Ctrl-C')
            catch ME
                msg = cellstr(ME.message);
                error(msg);
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
    
    
    %Private methods.
    methods (Access = private)
        
        function self = move_abs_x(self, absX)
            if self.Connected
                [xx yy zz]=self.getPosition();
                absY = num2str(yy/1000);
                absZ = num2str(zz/1000);
                self.Busy = 1;
                move_cmd = [absY, ' ', num2str(absX/1000), ' ', absZ, ' m'];
                stop_cmd = 'st';
                end_cmd = '0 0 0 r';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                self.Busy = 0;
            else
                err = MException(strcat(self.Name,':MoveAbsX'),...
                    'move_abs_x: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        function self = move_abs_y(self, absY)
            if self.Connected
                [xx yy zz]=self.getPosition();
                absY = num2str(xx/1000);
                absZ = num2str(zz/1000);
                self.Busy = 1;
                move_cmd = [num2str(absY/1000), ' ', absX, ' ', absZ, ' m'];
                stop_cmd = 'st';
                end_cmd = '0 0 0 r';
                self.send_command(move_cmd);
                self.send_command(end_cmd);
                self.send_command(stop_cmd);
                self.wait_for_command();
                self.Busy = 0;
            else
                err = MException(strcat(self.Name,':MoveAbsY'),...
                    'move_abs_y: optical stage not connected');
                self.Busy=0;
                throw(err);
            end
        end
        
        
    end
    
    
    
    
end

