classdef Multimeter_Agilent_34411A < InstrClass
    
    % Victor Bass 2013
    
   properties
    end
    
    methods
        % constructor
        function self = Multimeter_Agilent_34411A()
            self.Name = 'Agilent Multimeter';
            self.Group = 'Multimeter';
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Busy = 0;  % 0=not busy, 1 = busy
            self.Obj = ' ';  % serial/GPIB object
            % multimeter parameters
            self.Param.VoltageRange = '100 mV'; % choices: 100 mV, 1 V, 10 V, 100 V, 1000 V
            self.Param.CurrentRange = '100 uA'; % choices: 100 uA, 1 mA, 10 mA, 100 mA, 1 A, 3 A
        end
    end
    
    methods
        function self = connect(self)
        end
        function self = disconnect(self)
        end
        
        function self = setTrigger(self)
            immediate_trigger = 'trig:sour imm';  % command to constantly take readings
            self.send_command(immediate_trigger);
        end
        
        function self = measure_DC_voltage(self)
            volt_range_cmd = strcat(['sens:volt:dc:rang:upp ', self.Param.VoltageRange]); % set voltage measurement range
            dc_volt_cmd = 'meas:volt:dc';  % command to start measuring dc voltage
            % send commands to instrument
            self.send_command(volt_range_cmd);
            self.send_command(dc_volt_cmd);
        end
        
        function self = measure_DC_current(self)
            curr_range_cmd = strcat(['sens:curr:dc:rang:upp ', self.Param.CurrentRange]); % set current measurement range
            dc_curr_cmd = 'meas:curr:dc';  % command to start measuring dc current
            % send commands to instrument
            self.send_command(curr_range_cmd);
            self.send_command(dc_curr_cmd);
        end
        
        function self = read_data(self, file_name)
            if self.Connected
                % get readings from memory and store in text file
                get_data_cmd = 'data:data? nvmem';  % command to return all readings stored in non-volatile memory
                data = query(self.Obj, get_data_cmd);  % should send command and get response
                %             self.send_commad(get_data_cmd);
                %             data = fread(self.Obj);
                fileName = strcat(file_name, '.txt');
                fileID = fopen(fileName, 'a');
                fprintf(fileID, '%c', data);
                % does this need fclose(fileID) at the end?
            else
                msg = 'Multimeter not connected';
                disp(msg);
            end
        end
        
        function self = send_command(self, command)
            % copied from NanoPZ
            if self.Obj.BytesAvailable > 0
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            
            if strcmp(self.Obj.Status, 'open')
                fprintf(self.Obj, command);
            else
                msg = 'Optical Stage not connected';
                error(msg);
            end
        end
    end
    
end