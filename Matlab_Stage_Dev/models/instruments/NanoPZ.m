classdef NanoPZ < InstrClass
    
	% NanoPZ linear actuator user manual available online at:
    % http://assets.newport.com/webDocuments-EN/images/20619.pdf
    % Victor Bass 2013
    
	properties (Access = protected)
        xPos;  % stage x position
        yPos;  % stage y position
        zPos;  % stage z position
        Calibrated;  % stage calibrated
        Overshoot;
    end
    
    methods
        % constructor
        function self = NanoPZ()
            self.Name = 'NanoPZ';
            self.Group = 'Optical Stage';
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Busy = 0;
            self.Calibrated = 0;
            self.Obj = ' ';  % serial port object
            % serial port connection properties
            self.Param.COMPort = 4;
            self.Param.BaudRate = 19200;
            % motor settings shared by Corvus Eco
            self.Param.Acceleration = 0;
            self.Param.Velocity = 0;
            self.Overshoot = 0.02; % copied from Corvus Eco
            % stage positions
            self.xPos = nan;
            self.yPos = nan;
            self.zPos = nan;
        end
    end
    
    methods
        function self = connect(self)
            % checks is stage is already connected
            if self.Connected == 1
                msg = 'Optical Stage is already connected';
                error(msg);
            end
            % set serial port properties
            self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
            set(self.Obj,'BaudRate',self.Param.BaudRate);
            % try to open the connection
            try
                fopen(self.Obj);
            catch ME
                rethrow(ME);
            end
            % tell user optical stage is connected
            if strcmp(self.Obj.Status, 'open')
                self.Connected = 1;
            end
        end
        
        function self = disconnect(self)
            % check if stage is connected
            if self.Connected == 0
                msg = strcat(self.Name,':not connected');
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
        end
        
        function self = reset(self)
            if self.Connected
                if self.Busy
                    self.stop;
                    self.Busy = 0;
                end
            else
                msg = strcat(self.Name, ':not connected');
                error(msg);
            end
        end
        
        function self = send_command(self, command)
            if self.Obj.BytesAvailable > 0
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            
            if strcmp(self.Obj.Status, 'open')
                fprintf(self.Obj, command);
            else
                msg = strcat(self.Name, ':not connected');
                error(msg);
            end
        end
        
        function self = calibrate(self)
            if self.Connected
                self.Busy = 1;
                self.Calibrated = 1;
                self.xPos = 0;
                self.yPos = 0;
                self.zPos = 0;
                choose_x_motor = '1MX1'; % xxMX selects the switchbox channel for controler xx
                choose_y_motor = '1MX2';
                choose_z_motor = '1MX3';
                set_zero_position = '1OR'; % xxOR sets controller xx's motor position to 0
                self.send_command(choose_x_motor);
                self.send_command(set_zero_position);
                self.send_command(choose_y_motor);
                self.send_command(set_zero_position);
                self.send_command(choose_z_motor);
                self.send_command(set_zero_position);
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        function [x,y,z] = getPosition(self)
%             if self.Calibrated
                x = self.xPos;
                y = self.yPos;
                z = self.zPos;
%                 disp(strcat('Y position ', num2str(x)));
%                 disp(strcat('X position ', num2str(y)));
%                 disp(strcat('Z position ', num2str(z)));
%             else
%                 msg = strcat(self.Name, ' not calibrated. Cannot get position.');
%                 error(msg);
%             end
        end
        
        function self = move_x(self, distance)
            if self.Connected
%                 if self.Calibrated
                    self.Busy = 1;
                    motor_on = '1MO';  %turns on controller 1's motors
                    choose_motor = '1MX1';  %selects controller 1, motor 1
                    move_cmd = ['1PR', num2str(distance*100)];  %moves selected motor the input number of micro steps
                    % the *100 converts from ustep(default unit) to um
                    motor_off = '1MF';  %turns off controller 1's motors
                    self.send_command(motor_on);
                    self.send_command(choose_motor);
                    self.send_command(move_cmd);
                    self.send_command(motor_off);  %recommended to avoid actuator drift while switching channels
                    self.xPos = self.xPos + distance*100;
                    self.Busy = 0;
%                 else
%                     msg = strcat(self.Name, ' not calibrated. Please calibrate before moving.');
%                     error(msg);
%                 end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        function self = move_y(self, distance)
            if self.Connected
%                 if self.Calibrated
                    self.Busy = 1;
                    motor_on = '1MO';
                    choose_motor = '1MX2';  %selects controller 1, motor 2
                    move_cmd = ['1PR', num2str(distance*100)];  % the *100 converts from ustep(default unit) to um
                    motor_off = '1MF';
                    self.send_command(motor_on);
                    self.send_command(choose_motor);
                    self.send_command(move_cmd);
                    self.send_command(motor_off);
                    self.yPos = self.yPos + distance*100;
                    self.Busy = 0;
%                 else
%                     msg = strcat(self.Name, ' not calibrated. Please calibrate before moving.');
%                     error(msg);
%                 end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        function self = move_z(self, distance)
            if self.Connected
%                 if self.Calibrated
                    self.Busy = 1;
                    motor_on = '1MO';
                    choose_motor = '1MX3';  %selects controller 1, motor 3
                    move_cmd = ['1PR', num2str(distance*100)];
                    % the *100 converts from ustep(default unit) to um
                    motor_off = '1MF';
                    self.send_command(motor_on);
                    self.send_command(choose_motor);
                    self.send_command(move_cmd);
                    self.send_command(motor_off);
                    self.zPos = self.zPos + distance*100;
                    self.Busy = 0;
%                 else
%                     msg = strcat(self.Name, ' not calibrated. Please calibrate before moving.');
%                     error(msg);
%                 end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
    end
end