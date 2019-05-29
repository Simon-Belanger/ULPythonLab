classdef Pump < InstrClass
    % Shon Schmidt 2013
    
    properties (Access = protected)
        PumpedVolume; % uL
        PumpPurged; % no=0, yes=1, for syringe pump
        PumpStartTime; % tic to keep track of pumped volume
    end
    
    methods
        % constructor
        %        function self = Pump(gui)
        function self = Pump()
            % superclass properties
            %            self.MsgH = gui.debug_msg;
            self.MsgH = '';
            self.Name = 'Virtual Pump';
            self.Group = 'Pump';
            self.Model = 'Shons pump';
            self.CalDate = date;
            self.Busy = 0;
            self.Connected = 0;
            %             set(self.PopupWin,'callback',@obj.updatePreferencesPSD_callback);
            %             function updatePreferencesPSD_callback(obj,varargin)
            self.Param.COMPort = 0;
            self.Param.BaudRate = 9600;
            self.Param.PurgeTime = 1;
            self.Param.Velocity = 10;
            self.Param.MaxVolume = 5;
            self.Param.TubeID = 0.02;
            self.Param.UpdatePeriod = 0.5; % update reading timer: 0.5s
            self.Param.SyringeVolume = 5000; % uL
            % additional derived class properties
            self.PumpedVolume = 0;
            self.PumpPurged = 0;
        end
        
        % connect to instrument
        function self = connect(self)
            %            try
            self.Obj = 'VP';
            %            catch ME
            %                self.MsgH(ME.message);
            %                return
            %            end
            self.Connected = 1;
%             disp(num2str(self.Connected));
        end
        
        % disconnect from instrument
        function self = disconnect(self)
            if self.Connected
                if self.Busy % pump is running, stop it first
                    self.stop();
                    self.Busy = 0;
                end
                self.Connected = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        % reset
        function self = reset(self)
            if self.Connected
                if self.Busy % pump is running, stop it first
                    self.stop();
                    self.Busy = 0;
                end
                self.PumpedVolume = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        % purge lines
        function self = purge(self)
            if self.Connected
                self.Busy = 1;
                self.PumpStartTime = tic;
                pause(self.Param.PurgeTime); % time to expunge syringe or line on parastoltic pump
                elapsedTime = toc(self.PumpStartTime);
                self.PumpedVolume = self.PumpedVolume + elapsedTime*self.Param.Velocity/1000/60; % uL to mL, seconds to minutes
                self.Busy = 0;
                self.PumpPurged = 1;
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        function val = isPurged(self)
            val = self.PumpPurged;
        end
                
        % start pump
        function self = start(self)
            if self.Connected == 1
                if self.Busy
                    msg = strcat(self.Name, ' already started.');
                    disp(msg);
                else
                    % start the pump
                    self.PumpStartTime = tic;
                    self.Busy = 1;
                end
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
        % stop pump
        function self = stop(self)
            if self.Connected
                if self.Busy
                    % stop the pump
                    elapsedTime = toc(self.PumpStartTime);
                    self.PumpedVolume = self.PumpedVolume + elapsedTime*self.Param.Velocity/1000; % uL to mL
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' already stopped.');
                    disp(msg);
                end
            else
                msg = strcat(self.Name, ' not connected.');
                disp(msg);
            end
        end
        
%         % query pump state (pumping vs. stopped)
%         function resp = isPumping(self)
%             resp = self.Busy;
%         end

        % get pumped volume
        function val = getPumpedVolume(self)
            if (self.Busy) % pump is running
                elapsedTime = toc(self.PumpStartTime);
                self.PumpedVolume = self.PumpedVolume + elapsedTime*self.Param.Velocity/1000; % uL to mL
                val = self.PumpedVolume;
                % restart pump time
                self.PumpStartTime = tic;
            else % pump is stopped
                val = self.PumpedVolume;
            end
        end
        
    end
end