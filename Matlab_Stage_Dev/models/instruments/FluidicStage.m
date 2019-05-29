classdef FluidicStage < InstrClass
    % Shon Schmidt 2013
    
%    properties (Access = protected)
    properties
        xPos; % stage x position
        zPos; % stage y position
        Calibrated; % stage calibrated
        TrayLoaded; % 0=no, 1=yes, tray loaded
        TrayEjected; % 0=no, 1=yes, tray ejected
        WellNumber; % current well number
        FrontPlateType;
        BackPlateType;
        PlateList;
        CurrentWell;
    end
    
    methods
        % constructor
%        function self = FluidicStage(gui)
        function self = FluidicStage()
            self.Connected = 0;
            self.Busy = 0;
            self.Name = 'Virtual Fluidic Stage'; % name of the instrument
            self.Group = 'FluidicStage'; % instrument group this one belongs to
            self.Calibrated = 0; % stage calibrated
            self.Param.COMPort = 0;
            self.Param.BaudRate = 0;
            self.Param.StopBits = 0;
            self.Param.Parity = 0;
            self.Param.Acceleration = 500; % is this cm/sec?
            self.Param.Velocity = 5; % is this cm/sec?
            self.xPos = nan; % initialize to nan to ensure calibration
            self.zPos = nan; % initialize to nan to ensure calibration
            self.TrayLoaded = 0;
            self.TrayEjected = 0;
            self.WellNumber = 0;
            self.FrontPlateType = 12;
            self.BackPlateType = 3;
            self.PlateList = -1;
            self.CurrentWell = 0;
        end
        
        % connect to instrument
        function self = connect(self)
            %            try
            self.Obj = 'VS';
            %             catch ME
            %                 self.MsgWin(ME.message);
            %                 return
            %             end
            self.Connected = 1;
            self.Calibrated = 1;
        end
        
        % disconnect from instrument
        function self = disconnect(self)
            if self.Connected
                if self.Busy % is running, stop it first
                    self.stop();
                    self.Busy = 0;
                end
                self.Connected = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % reset
        function self = reset(self)
            if self.Connected
                if self.Busy % is running, stop it first
                    self.stop();
                    self.Busy = 0;
                end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % calibrate stage
        function self = calibrate(self)
            if self.Connected
                self.Busy = 1;
                self.Calibrated = 1;
                self.xPos = 0;
                self.zPos = 0;
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % get position
        function [x,y] = getPosition(self)
            if self.Calibrated
                x = self.xPos;
                y = self.zPos;
            else
                msg = strcat(self.Name, ' not calibrated. Cannot get position.');
                error(msg);
            end
        end
        
        % move X
        function self = move_x(self, distance)
            if self.Calibrated
                self.Busy = 1;
                pause(distance / self.Param.Velocity); % time to move distance
                self.xPos = self.xPos + distance;
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not calibrated. Cannot get position.');
                error(msg);
            end
        end
        
        % move Z
        function self = move_z(self, distance)
            if self.Calibrated
                self.Busy = 1;
                pause(distance / self.Param.Velocity); % time to move distance
                self.zPos = self.zPos + distance;
                self.Busy = 0;
            else
                msg = strcat(self.Name, ' not calibrated. Cannot get position.');
                error(msg);
            end
        end
        
        % move to well
        function move_to_well(self, target_well)
            startTime = tic;
            while self.Busy
                msg = strcat(self.Name, ' busy. Waiting... ', num2str(toc(startTime)));
                disp(msg);
                pause (1);
            end
            if self.Calibrated
                if self.TrayLoaded
                    self.Busy = 1;
                    self.WellNumber = target_well;
                    self.CurrentWell = target_well;
                    msg = strcat(self.Name, ': Moved to well ', num2str(target_well));
                    disp(msg);
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' tray not loaded. Cannot move to well ', num2str(target_well));
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' not calibrated.');
                error(msg);
            end
        end
        
        % eject tray
        function ejectTray(self)
            if self.Connected
                self.TrayLoaded = 0;
                self.Busy = 1;
                self.Busy = 0;
                self.TrayEjected = 1;
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
        
        % current well number
        function result = currentWell(self)
            result = self.WellNumber;
        end
        
        % load tray
        function loadTray(self)
            if self.Connected
                if self.TrayEjected
                    self.Busy = 1;
                    self.TrayEjected = 0;
                    self.TrayLoaded = 1;
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' tray not loaded.');
                    error(msg);
                end
            else
                msg = strcat(self.Name, ' not connected.');
                error(msg);
            end
        end
    end
end