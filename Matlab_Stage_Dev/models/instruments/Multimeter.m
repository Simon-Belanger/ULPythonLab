classdef Multimeter < InstrClass
   
    % generic multimeter
    % Victor Bass 2013
    
    properties
    end
    
    methods
        % constructor
        function self = Multimeter()
            self.Name = 'Virtual Multimeter';
            self.Group = 'Multimeter';
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Busy = 0;  % 0=not busy, 1 = busy
            self.Obj = ' ';  % serial/GPIB object
            % multimeter parameters
            self.Param.VoltageRange = '100 mV'; % choices depend on instrument
            self.Param.CurrentRange = '100 uA'; % choices depend on instrument
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
                delete(self.Obj);
                self.Connected = 0;
            else
                msg = strcat(self.Name, ' not connected');
                disp(msg);
            end
        end
        
        function self = measure_DC_voltage(self)
            % set instrument to measure DC voltage
        end
        
        function self = measure_DC_current(self)
            % set instrument to measure DC current
        end
        
        function self = read_data(self)
            % save instrument readings in a text file
        end
    end
end