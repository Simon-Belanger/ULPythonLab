classdef TEC < InstrClass
    
    % generic thermoelectric controller
    % Victor Bass 2013
    
    properties
        CurrentTemp;  % degrees C
        % temperature limits given by manufacturer
        MIN_TEMP;  % degrees C
        MAX_TEMP;  % degrees C
    end
    
    methods
        % constructor
        function self = TEC()
            self.Name = 'Virtual TEC';
            self.Group = 'TEC';
            self.MsgH = ' ';
            self.CalDate = date;
            self.Connected = 0;  % 0 = not connected, 1 = connected
            self.Busy = 0;  % 0 = not busy, 1 = busy
            % serial port connection parameters
            self.Obj = ' ';  % becomes serial port object
            self.Param.COMPort = 0;
            self.Param.BaudRate = 9600;
            self.Param.DataBits = 8;
            self.Param.StopBits = 1;
            self.Param.Terminator = 'LF';
            self.Param.Parity = 'none';
            % temp controller parameters
            self.CurrentTemp = 25;
            self.Param.TargetTemp = 37;  % degrees C
        end
    end
    
    methods
        function self = connect(self)
            self.Obj = 'VP';
            self.Connected = 1;
        end
        
        function self = disconnect(self)
            if self.Connected
                if self.Busy
                    self.stop;
                    self.Busy = 0;
                end
                self.Connected = 0;
            else
                msg = (strcat(self.Name, ' not connected.'));
                error(msg);
            end
        end
        
        % set temp instrument aims for
        function self = set_target_temp(self, temp)
            %set the temp the controller will try to maintain
            self.Param.TargetTemp = temp;
        end
        
        % start controller
        function self = start(self)
            if self.Connected
                if self.Busy
                    msg = strcat(self.Name, ' already started.');
                    error(msg);
                else
                    % commands to start the controller to target temp
                    self.Busy = 1;
                end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % stop controller
        function self = stop(self)
            if self.Connected
                if self.Busy
                    % commands to stop the controller
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' already stopped.');
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % show controller's current temperature
        function val = currentTemp(self)
            % read current temp from controller
            % store in variable CurrentTemp
            val = self.CurrentTemp;
        end
        
        % show controller's target temperature
        function val = showTargetTemp(self)
            val = self.Param.TargetTemp;
        end
        
        % show controller's temperature limits
        function self = showTempLimits(self)
            % commands to check current temp limits of machine
            % store those limits in MIN_TEMP and MAX_TEMP
            low_limit = self.MIN_TEMP;
            high_limit = self.MAX_TEMP;
            disp(strcat('Low temperature limit is ', num2str(low_limit), ' degrees C'))
            disp(strcat('High temperature limit is ', num2str(high_limit), ' degrees C'))
        end
        
    end
    
end