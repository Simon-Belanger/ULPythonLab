classdef Laser_Santur1550 < InstrClass
    % Victor Bass 2013
    
    % Problems:
    % no command to set power given in documentation
    % wvl range is about 1529 to 1567 calculated from available channels
    % channel range is 13.25 to 61 in increments of 0.25
    
    % Power supply should be set to 3.3 Volts and be able to provide 3 Amps
    
    % channel sets output frequency
    % setting channel to 15.25 sets 191525 GHz frequency
    
    % need a good way to read responses from the machine
    % every response has a terminator that stops fscanf, so it would take
    % many calls of it to get the whole response to certain commands
        % maybe a for loop until it gives an error?
        % or a while loop, stopping once there's an error
    % not sure if terminator stops fread, but would have to convert from
    % binary to characters if/when using it
    
    % wvl/frequency converter: http://www.photonics.byu.edu/fwnomograph.phtml
    
    properties (Access = protected)
        PauseTime; % so Matlab doesn't overrun the COM port
        Lasing; % indicates when laser output is on, 0=off, 1=on
        MAX_WVL;
        MIN_WVL;
        SweepPause; % gives laser time to adjust wvl during sweep function
        PWMSlotInfo; % number of PWM modules installed in mainframe
        NumPWMChannels; % necessary for multiframe lambda scan setup, need to get from detector obj
        StitchNum; % for saving number of stitches input by user in GUI
        
        TotalSlots;
        TotalNumOfDetectors;
    end
    %% Static Methods
    methods (Static)
        function m = nm2m(nm)
            % convert nm to m, for wavelengths
            m = nm*1e-9;
        end
        
        function ghz = wvl2ghz(wvl)
            % convert wavelength(nm) to gigahertz(GHz)
            % command syntax sets ghz of laser outpus
            % equation: frequency * wavelength = c = 3e8 m/s = light speed
            ghz = (3e8)/wvl; % wvl should be in nm
        end
        
        function wvl = ghz2wvl(ghz)
            % convert hertz (GHz) to wavelength (nm)
            % for displaying ghz sent to instrument as wavelength
            ghz = (ghz*100) + 190000; % convert to actual frequency of channel
            wvl = (3e8)/ghz; % gives units of nm
        end
    end
    %% Constructor
    methods
        function self = Laser_Santur1550()
            self.Name = 'Santur 1550 Laser';
            self.Group = 'Laser';
            self.Model = 'TL-2020-C-152-AOG';
            self.Serial = 'k127615';
            
            self.Connected = 0; % 0=not connected, 1=connected
            self.Busy = 0; % 0=not busy, 1=busy
            
            % connection properties
            self.Param.COMPort = 6; %23
            self.Param.BaudRate = 19200;
            self.Param.DataBits = 8;
            self.Param.Parity = 'none';
            self.Param.Terminator = 'CR';
            
            % instrument parameters
            self.Param.OutputPowerLevel = 0; % dB
            self.Param.PowerUnit = 0; % 0=dB, 1=W
            self.Param.Wavelength = 1550; % wavelength (nm)
            self.Param.TriggerInEnable = 0; % Boolean, 0=no, 1=yes
            self.Param.TriggerOutEnable = 0; % Boolean, 0=no, 1=yes
            self.Param.NumberOfSweepStitches = 0; % 0=no stitching, >0=stitching
            self.Param.StartWvl = 1480; % wavelength (nm)
            self.Param.StopWvl = 1580; % wavelength (nm)
            self.Param.SweepSpeed = 5; % 1=slow ... 5=fast
            self.Param.PowerLevel = 0;
            
            self.PauseTime = 0.01;
            self.Lasing = 0;
            self.MIN_WVL = 1529;
            self.MAX_WVL = 1567;
            self.SweepPause = 2;
        end
    end
    %% Class Methods
    methods
        %% Connect and Disconnect
        function self = connect(self)
            % connect to instrument
            % check if already connected
            if self.Connected== 1  %1: stage is connected
                err = MException('Laser:Connection',...
                    'laser is already connected');
                throw(err);
            end
            % set serial port object properties
            self.Obj = serial(['COM', num2str(self.Param.COMPort)]);
            set(self.Obj,'BaudRate',self.Param.BaudRate);
            set(self.Obj,'DataBits',self.Param.DataBits);
            set(self.Obj,'Parity',self.Param.Parity);
            set(self.Obj,'Terminator',self.Param.Terminator);
            % try to open connection to instrument
            try
                fopen(self.Obj);
            catch ME
                rethrow(ME);
            end
            if strcmp(self.Obj.Status, 'open')
                self.Connected= 1;
                msg = strcat(self.Name, ' is connected');
                disp(msg);
            end
            self.querySlotInfo();
        end
        
        function self = disconnect(self)
            % disconnect from instrument
            % check if laser is connected before trying to disconnect
            if self.Connected == 0
                msg = 'Laser is not connected';
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
        
        %% Query slot info for sweep preparation
        function querySlotInfo(self)
            self.NumPWMChannels = 0;
            self.PWMSlotInfo = [];
            self.TotalSlots = 0;
            self.TotalNumOfDetectors = 0;
        end
        
        %% On and Off
        function self = on(self)
            % turn laser output on
            if self.Connected
                if ~self.Lasing
                    self.Busy = 1;
                    ghz = self.wvl2ghz(self.Param.Wavelength);
                    ghz = (ghz - 190000)/100;
                    % need to round to nearest .0, .25, .5, or .75
                    rounder = floor(ghz);
                    rounded = ghz - rounder;
                    if rounded ~= 0 && rounded ~= 0.25 && rounded ~= .5 && rounded ~= .75
                        % make sure ghz value will be accepted by laser
                        if rounded < 0.25
                            ghz = ghz - rounded;
                        elseif rounded < 0.5
                            ghz = ghz - rounded + 0.25;
                        elseif rounded < 0.75
                            ghz = ghz - rounded + 0.5;
                        else
                            ghz = ghz - rounded +0.75;
                        end
                        % inner 'if' rounds to lowest accepted GHz value
                        % (results in higher wavelength)
                    end
                    % display wavelength being set to user
                    wavelength = self.ghz2wvl(ghz);
                    wvl_msg = strcat([num2str(wavelength), ' nm']);
                    disp(wvl_msg);
                    % stop function if frequency is out of accepted range
                    if ghz < 13.25
                        msg = 'Specified frequency is too high';
                        error(msg);
                    elseif ghz > 61
                        msg = 'Specified frequency is too low';
                        error(msg);
                    end
                    % send command to laser
                    on_command = strcat(['C ', num2str(ghz)]);
                    self.send_command(on_command);
                    self.Lasing = 1;
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ': Already turned on.');
                    disp(msg);
                end
            else
                msg = strcat(self.Name, ' is not connected');
                disp(msg);
            end
        end
        
        function self = off(self)
            % turn laser output off
            if self.Connected
                if self.Lasing
                    self.Busy = 1;
                    stop_command = 'C X'; % command to turn off laser output
                    self.send_command(stop_command);
                    pause(self.PauseTime);
                    self.Lasing = 0;
                    self.Busy = 0;
                else
                    msg = strcat(self.Name, ' is not on.');
                    disp(msg);
                end
            else
                msg = strcat(self.Name, ' is not connected');
                disp(msg);
            end
        end
        
        function self = setTriggerPassThru(self)
            % Do nothing
        end
        
        %% sweep
        function sweep(self)
            self.Busy = 1;
            self.Lasing = 1;
            % cycle through all channels with a for loop
            for i = 1:192
                % there are 192 available channels
                disp(num2str(i))
                ghz = 61.25 - (i*0.25); % move through channels from low wvl to high wvl
                on_command = strcat(['C ', num2str(ghz)]);
                self.send_command(on_command);
                pause(self.SweepPause); % make sure module has time to change channels
            end
            
            self.off;
            self.Lasing = 0;
            self.Busy = 0;
        end
        
        %% set and get Wavelength
        function setWavelength(self, wvl)
            % set the wvl parameter
            % convert to GHz to send to instrument in the self.on command
            self.Param.Wavelength = wvl;
        end
        
        function val = getWavelength(self)
            % read set wavelength from class
            val = self.Param.Wavelength;
        end
        
        %% Send_command
        function self = send_command(self, command)
            % sends commands through serial port to control laser
            if self.Obj.BytesAvailable > 0  %empty buffer
                fscanf(self.Obj, '%s', self.Obj.BytesAvailable);
            end
            if strcmp(self.Obj.Status, 'open')
                fprintf(self.Obj, command);
            else
                err = MException('Laser:Com',...
                    'laser status: connection closed');
                throw(err);
            end
        end
        
        function val = getProp(self, prop)
            val = self.(prop);
        end
        
        function self = setProp(self, prop, val)
            self.(prop) = val;
        end
    end
end

%% Command list

% 'C xx.yy'  Sets module to output channel xx.yy and turns ouput on
% 'C AVAIL'  Response lists output channels availablie to module
% 'C X'      Turns output off
% 'C ?'      Response gives current output channel
% 'S'        Response gives module status
% 'Q ID'     Response gives manufacturer, model, serial number
% 'Q REV'    Response gives software version
% 'OG M'     Response give maximum allowed off-grid frequency shift
% 'OG x.y'   Sets off-grid frequency shift to x.y GHz
% 'OG'       Response gives current off-grid frequency shift
% 'OG X'     Turns off off-grid tuning (same as 'OG 0.0')