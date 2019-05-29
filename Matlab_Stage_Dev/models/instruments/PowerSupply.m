classdef PowerSupply < InstrClass
    
    % generic power supply
    % Victor Bass 2013
    
    properties
    end
    
    methods
        % constructor
        function self = PowerSupply()
            self.Name = 'Virtual Power Supply';
            self.Group = 'PowerSupply';
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Busy = 0;  % 0=not busy, 1 = busy
            self.Obj = ' '; % serial/GPIB object
            % power supply properties
            self.Param.Voltage = 0;  % in V
            self.Param.Current = 0;  % in A
        end
    end
    
    methods
        function self = connect(self)
            % connect to instrument
            if self.Connected
                msg = strcat(self.Name, ' already connected');
                disp(msg);
            else
                self.Obj = 'VPS';
                self.Connected = 1;
            end
        end
        
        function self = disconnect(self)
            % disconnect from instrument
            if self.Connected
                self.Connected = 0;
            else
                msg = strcat(self.Name, ' not connected');
                disp(msg);
            end
        end
        
        function self = on(self)
            % turn power on
            if self.Connected
                self.Busy = 1;
            else
                msg = strcat(self.Name, ' not connected');
                disp(msg);
            end
        end
        
        function self = off(self)
            % turn power off
            if self.Connected
                if self.Busy
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' is not on');
                    disp(msg);
                end
            else
                msg = strcat(self.Name, ' not connected');
                disp(msg);
            end
        end
        
        function self = setV(self, voltage)
            % set voltage of power
            self.Param.Voltage = voltage;
        end
        
        function self = setI(self, current)
            % set current of power
            self.Param.Current = current;
        end
        
        function val = getV(self)
            % query the set voltage
            val = self.getParam('Voltage');
        end
        
        function val = getI(self)
            % query the set current
            val = self.getParam('Current');
        end
        
    end
end