classdef Power_Supply_AgilentE3634A < InstrClass
    % the user manual for this instrument is available online at:
    % http://cp.literature.agilent.com/litweb/pdf/E3634-90001.pdf
    % Victor Bass 2013
    properties
    end
    
    methods
        % constructor
        function self = Power_Supply_AgilentE3634A()
            self.Name = 'Agilent Power Supply';
            self.Group = 'Power Supply';
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Busy = 0;  % 0=not busy, 1 = busy
            self.Obj = ' '; % serial/GPIB object
            % port properties
            self.Param.COMPort = 7; % GPIB address
            self.Param.BaudRate = 9600;
            self.Param.Parity = 'none';
            self.Param.DataBits = 8;
            % power supply properties
            self.Param.Voltage = 0;  % in V
            self.Param.Current = 0;  % in A
        end
    end
    
    methods
        function self = connect(self)
            % connect to instrument over RS232 port
            if self.Connected == 1  % check if supply is already connected
                msg = 'Power Supply is already connected';
                error(msg);
            end
            % create GPIB connection
            % connect to GPIB port
            try
                self.Obj = gpib('agilent',0',self.Param.COMPort);
                fopen(self.Obj);
            catch ME
                error (ME.message);
            end
            
%             % create serial port object
%             self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
%             set(self.Obj, 'BaudRate', self.Param.BaudRate,...
%                 'Parity', self.Param.Parity,...
%                 'DataBits', self.Param.DataBits);
%             % try to open the connection
%             try
%                 fopen(self.Obj);
%                 self.Connected = 1;
%             catch ME
%                 rethrow(ME);
%             end
            
            if strcmp(self.Obj.Status, 'open')
                remote_cmd = 'syts:rem';  % sets instrument to remote mode, recommended for RS232 operation
                trigger_cmd = 'trig:sour imm';  % sets instrument to be triggered by remote operator
                
                self.send_command(remote_cmd);
                self.send_command(trigger_cmd);
            end
        end
        
        function self = disconnect(self)
            % check if stage is connected
            if self.Connected == 0
                msg = 'Power Supply is not connected';
                error(msg);
            end
            % try to close connection and delete serial object
            try
                fclose(self.Obj);
                delete(self.Obj);
                self.Connected = 0;
            catch ME
                error(ME.message);
            end
        end
        
        function self = on(self)
            % sets voltage and current, then turns instrument on
            apply_cmd = strcat(['appl ', num2str(self.Param.Voltage),...
                ', ', num2str(self.Param.Current)]); % command to set V and I
            start_cmd = 'outp on';  % sets output on
            
            self.send_command(apply_cmd);
            self.send_command(start_cmd);
        end
        
        function self = off(self)
            % turns instrument off
            stop_cmd = 'outp off';  % sets output off
            self.send_command(stop_cmd);
        end
        
        function self = send_command(self, command)
            % write commands to the instrument over the serial port
            % copied from NanoPZ class
            if self.Obj.BytesAvailable > 0
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            
            if strcmp(self.Obj.Status, 'open')
                fprintf(self.Obj, command);
            else
                msg = 'Power Supply is not connected';
                error(msg);
            end
        end
        
        function self = setV(self, voltage)
            % change the set voltage (in V)
            self.Param.Voltage = voltage;
            setV_cmd = strcat('volt ', num2str(self.Param.Voltage));  % sets supply voltage
            self.send_command(setV_cmd);
        end
        
        function self = setI(self, current)
            % change the set current (in A)
            self.Param.Current = current;
            setI_cmd = strcat('curr ', num2str(self.Param.Current));  % sets supply current
            self.send_command(setI_cmd);
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