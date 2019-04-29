classdef Nexus3000 < InstrClass
    %NEXUS3000 Summary of this class goes here
    %   Detailed explanation goes here
    
    %     properties
    %         Name = 'Nexus 3000';
    %     end
    
    properties (Access = protected)
        PumpedVolume; % uL
        PumpPurged; % no=0, yes=1, for syringe pump
        PumpStartTime; % tic to keep track of pumped volume
        Timeout = 0.1;
        PauseTime = 0.1;  % prevents overloading of serial port
        BaudRate;
        StopBits;
        DataBits;
        Terminator;
    end
    
    methods
        % constructor
        function self = Nexus3000()
            self.Name = 'Nexus 3000';
            self.Group = 'Pump';
            self.Model = 'Nexus3000';
            self.Serial = '2172160';
            self.MsgH = ' ';
            self.CalDate = date;
            self.Busy = 0;
            self.Connected = 0;  % 0=not connected, 1=connected
            self.Obj = ' ';  % serial port object
            % serial connection properties
            self.Param.COMPort = 24;
            self.BaudRate = 9600;
            self.StopBits = 1;
            self.DataBits = 8;
            self.Terminator = 'CR/LF';
            self.Param.Parity = 'none';
            % pump properties
            
            self.Param.Velocity = 10;  % in ul/min ****10 DEFAULT****
            self.Param.SyringeDiameter = 10.3;  % in mm
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            %Postive volume values for positive pressure (expunge)
            %Negative volume values for negative pressure (intake)
            self.Param.SyringeVolume = -5000;  % in uL
            
            % derived class properties
            self.PumpedVolume = 0;
            self.PumpPurged = 0;
        end
    end
    
    methods
        function self = connect(self)
            self.Obj = serial(['COM', num2str(self.Param.COMPort)], ...
                'BaudRate', self.BaudRate, 'Parity', self.Param.Parity, ...
                'StopBits', self.StopBits, 'DataBits', self.DataBits, ...
                'Terminator',self.Terminator);
            fopen(self.Obj);
            set(self.Obj,'Timeout',self.Timeout);
            resp = query(self.Obj,['set diameter ', num2str(self.Param.SyringeDiameter)]);
            resp = query(self.Obj,['set volume ', num2str(self.Param.SyringeVolume)]);
            resp = query(self.Obj,['set rate ', num2str(self.Param.Velocity)]);
            self.Connected = 1;
        end
        
        function self = disconnect(self)
            if self.Connected ~= 0
                fclose(self.Obj);
                delete(self.Obj);
                self.Connected = 0;
            end
        end
        
        function self = start(self)
            if self.Connected == 1
                if self.Busy == 1
                    msg = 'Pump already running';
                    error(msg);
                else
                    resp = query(self.Obj,['set volume ' num2str(self.Param.SyringeVolume)]);
                    pause(self.PauseTime)
                    resp = query(self.Obj,['set rate ', num2str(self.Param.Velocity)]); 
                    pause(self.PauseTime)
                    resp = query(self.Obj,'start');
                    self.PumpStartTime = tic; % for calculating pumped volume
                    self.Busy = 1;
                end
            else
                msg = 'Pump not connected';
                error(msg);
            end
        end
        
        function self = query_parameters(self)
            resp = query(self.Obj,'view parameter');
            pause(2);
        end
        
        function self = stop(self)
            if self.Connected == 1
                if self.Busy == 1
                    resp = query(self.Obj,'stop');
                    elapsedTime = toc(self.PumpStartTime); % gives seconds spent pumping
%                     disp(['Elapsed Time: ', num2str(elapsedTime), ' s'])
%                     disp(['Flow Rate: ', num2str(self.Param.Velocity), ' uL/min'])
                    self.PumpedVolume = self.PumpedVolume + self.Param.Velocity*elapsedTime/60; % give uL pumped
%                     disp(['Pumped Volume: ', num2str(self.PumpedVolume), ' uL'])
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' is not running');
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' is not connect');
                error(msg);
            end
        end
        
%         % query pump state (pumping vs. stopped)
%         function resp = isPumping(self)
%             resp = self.Busy;
%         end
        
        
        function self = reset(self)
            resp = query(self.Obj,'reset');
        end
        
        % function to clear the pump's lines
        function self = purge(self)
            if self.Connected
                if self.Busy
                    msg = 'Cannot purge, pump still running';
                    error(msg);
                else
                    self.Busy = 1;
                    tic;
                    resp = query(self.Obj,['set volume ' num2str(self.PumpedVolume)]);
                    pause(self.PauseTime)
                    resp = query(self.Obj,['set rate ', num2str(5000)]); 
                    pause(self.PauseTime)
                    resp = query(self.Obj,'start');
                    self.PumpedVolume = 0;
                    self.PumpPurged = 1;
                    self.Busy = 0;
                end
            else
                msg = strcat(self.Name, ' not connected');
                error(msg);
            end
        end
        
        % function to get pumped volume
        function val = getPumpedVolume(self)
            if self.Busy % pump is running
%                 elapsedTime = toc(self.PumpStartTime);
%                 self.PumpedVolume = self.PumpedVolume + elapsedTime*self.Param.Velocity/60;
                val = self.PumpedVolume;
            else
                val = self.PumpedVolume;
            end
        end
        
    end
    
end

