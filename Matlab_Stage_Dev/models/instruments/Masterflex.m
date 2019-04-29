classdef Masterflex < InstrClass
    
    % Masterflex 7550-20 pump manual pdf:
    % http://www.masterflex.com/Assets/manual_pdfs/A-1299-0726.pdf
    % Victor Bass 2013
    
    properties (Access = protected)
        PumpedVolume;  % in uL
        PumpPurged;  % does this only apply to syringe pump?
        PumpStartTime;  % to keep track of pumped volume
        Timeout = 2; % time-out time for reads
        PauseTime = 0.1; % brief pause so Matlab doesn't overrun serial port
        % pump rpm limits specified by manufacturer
        MIN_RPM = 1.6;
        MAX_RPM = 100;
    end
    
    methods
        %constructor
        function self = Masterflex()
            self.Name = 'Masterflex';
            self.Group = 'Pump';
            self.Model = '7550-20';
            self.MsgH = ' ';
            self.CalDate = date;
            self.Busy = 0;
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Obj = ' ';  % serial port object
            % serial connection properties
            self.Param.COMPort = 21;
            self.Param.BaudRate = 4800;
            self.Param.StopBits = 1;
            self.Param.DataBits = 7;
            self.Param.Parity = 'odd';
            self.Param.Terminator = 'CR';
            % pump properties
            self.Param.Velocity = 10;  % in ul/min
            self.Param.TubeDiameter = 0.79;  % in mm
            self.Param.PurgeTime = 10;
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            % derived class properties
            self.PumpedVolume = 0;
            self.PumpPurged = 0;
        end
    end
    
    methods (Static)
        function rtn = convert2rpm(vel, tubeD)
            % this function converts velocity and tube diameter to rpm
            rtn = vel/(2*pi^2*(tubeD/2)^3);
        end
    end
    
    methods
        function self = connect(self)
            % check if already open
            if self.Connected== 1  %1: stage is connected
                err = MException('FluidicPump:Connection',...
                    'fluidic pump is already connected');
                throw(err);
            end
            % set serial port properties
            self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
            set(self.Obj,'BaudRate',self.Param.BaudRate);
            set(self.Obj,'StopBits',self.Param.StopBits);
            set(self.Obj,'DataBits',self.Param.DataBits);
            set(self.Obj,'Parity',self.Param.Parity);
            set(self.Obj,'Terminator',self.Param.Terminator);
            
            try
                fopen(self.Obj);
            catch ME
                rethrow(ME);
            end
            if strcmp(self.Obj.Status, 'open')
                self.send_command(5);  %5=dec code for <ENQ>, which initializes connection to pump
                self.Connected= 1;
            end
        end
        
        function self = disconnect(self)
            % check if pump is connected
            if self.Connected == 0
                msg = 'Pump is not connected';
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
        
        function self = send_command(self, command)
            % sends ASCII commands through serial port to control pump
            % <STX> starts commands, <CR> terminates them
            if self.Obj.BytesAvailable > 0  %empty buffer
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            if strcmp(self.Obj.Status, 'open')
                fwrite(self.Obj, 02);  % sends ASCII dec code 02, means <STX>, required to start commands to pump
                fprintf(self.Obj, command);  % adds specified terminator (CR) to end of commands
            else
                err = MException('FluidicPump:Com',...
                    'fluidic pump status: connection closed');
                throw(err);
            end
        end
        
        function self = start(self)
            %send ASCII codes to start pump
            %P02 sends commands to pump 02, 02 is the default pump number
            %S+10 sets speed to 10rpm clockwise
            %G0 tells pump to pump continuously until halt command is given
            if self.Connected == 0
                % ensures pump is connected to serial port before starting
                msg = 'Pump not connected';
                error(msg);
            else
                if self.Busy
                    % ensures pump has not started already
                    msg = strcat(self.Name,' already started');
                    error(msg);
                end
                self.Busy = 1;  % shows pump has been started
                rpm = self.convert2rpm(self.Param.Velocity,self.Param.TubeDiameter);
                if rpm < self.MIN_RPM || rpm > self.MAX_RPM
                    msg = 'Specified rpm out of range. Aborting.';
                    error(msg);
                end
                rpm = num2str(rpm);
                set_motor = strcat('P02S+',rpm);  %sets pump speed to calculated rpm, clockwise direction
                start_motor = 'P02G0';   %commands pump to pump until stop command issued
                self.send_command(set_motor);
                self.send_command(start_motor);
                self.PumpStartTime = tic;
            end
        end
        
        function self = stop(self)
            % send decimal ASCII codes to stops the pump
            % H sends halt command
            if self.Connected == 1
                if self.Busy == 1
                    stop_motor = 'P02H';
                    self.send_command(stop_motor);
                    elapsedTime = toc(self.PumpStartTime);    %gives time spent pumping in seconds
                    % give uL pumped
                    self.PumpedVolume = self.PumpedVolume + self.Param.Velocity*elapsedTime/1000/60; % uL to mL, min to sec
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' is not running');
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' is not connected');
                error(msg);
            end
        end
        
%         % query pump state (pumping vs. stopped)
%         function resp = isPumping(self)
%             resp = self.Busy;
%         end
        
        
        function val = getPumpedVolume(self)
            if (self.Busy) % pump is running
                elapsedTime = toc(self.PumpStartTime);
                self.PumpedVolume = self.PumpedVolume + elapsedTime*self.Param.Velocity/1000/60; % uL to mL, min to sec
                val = self.PumpedVolume;
                % restart pump time
                self.PumpStartTime = tic;
            else % pump is stopped
                val = self.PumpedVolume;
            end
        end
        
        function self = purge(self)
            if self.Connected == 1
                if self.Busy == 1
                    msg = 'Pump running. Wait until it stops to purge it';
                    error(msg);
                else
                    self.Busy = 1;
                    purge_lines = 'P02S+30G0';
                    stop_motor = 'P02H';
                    self.PumpStartTime = tic;
                    self.send_command(purge_lines);
                    pause(self.Param.PurgeTime);
                    self.send_command(stop_motor);
                    elapsedTime = toc(self.PumpStartTime);
                    self.PumpedVolume = self.PumpedVolume + self.Param.Velocity*elapsedTime/1000/60; % uL to mL, min to sec
                    self.Busy = 0;
                    self.PumpPurged = 1;
                end
            else
                msg = strcat(self.Name, ' not connected');
                error(msg);
            end
        end
        
        function val = isPurged(self)
            val = self.PumpPurged;
        end
    end
    
    methods
        % are these methods needed?
        function self = check_status(self)
            self.send_command('P02I');  %I requests pump status
            pause(self.PauseTime);
            % get and display reponse from pump to status request
            response = fscanf(self.Obj);
            disp(response);
            %the response should be P02Ixxxxx
            %to interpret the response, see the user manual at:
            %http://www.masterflex.com/Assets/manual_pdfs/A-1299-0726.pdf
            %section 1.8 of appendix A: Pump Drive Communication
        end
        
        function self = reset(self)
            %This function resets the instrument and PumpedVolume tracking
            % steps:
            % 1. check to see if instr handle exists, if so, delete it
            % 2. re-create instrument handle and open port
            % 3. initialize instrument communications
            % 4. validate instrument communication
            % 5. set flags and reset PumpedVolume
            
            % 1
            if self.Connected == 1
                stop_motor = [02;80;48;50;72;13];
                %stop_motor = <STX> P 0 2 H <CR>
                self.send_command(stop_motor);   %makes sure the pump is stopped before trying to reset the connection
                fclose(self.Obj);
                delete(self.Obj);
                clear self.Obj;
                self.Connected = 0;
            end
            
            %2
            self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
            set(self.Obj,'BaudRate',self.Param.BaudRate);
            set(self.Obj,'DataBits',self.Param.DataBits);
            set(self.Obj,'Parity',self.Param.Parity);
            set(self.Obj,'Terminator',self.Param.Terminator);
            try
                fopen(self.Obj);
            catch ME
                rethrow(ME);
            end
            if strcmp(self.Obj.Status, 'open')
                self.Connected= 1;
            end
            
            %3
            self.send_command(5);  % 5 = dec code for <ENQ>, which initializes connection to pump
            
            %4
            set_motor = 'P02S+10';
            self.send_command(set_motor);    %pump should acknowldege this command
            connection_check = fread(self.Obj);   %expected value is 6, dec code for <ACK>
            if connection_check ~= 6
                %close, delete, clear connection again
                fclose(self.Obj);
                delete(self.Obj);
                clear(self.Obj);
                %re-initialize and open connection
                self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
                set(self.Obj,'BaudRate',self.Param.BaudRate);
                set(self.Obj,'DataBits',self.Param.DataBits);
                set(self.Obj,'Parity',self.Param.Parity);
                set(self.Obj,'Terminator',self.Param.Terminator);
                fopen(self.Obj);
                disp('Pump Reconnect attempted again')
            else
                disp('Pump connection validated')
            end
            
            %5
            self.PumpedVolume = 0;  % reset pumped volume
            self.PumpPurged = 0 ;  % reset if pump purged or not
        end
    end
end
