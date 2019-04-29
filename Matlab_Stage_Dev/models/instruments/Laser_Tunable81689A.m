classdef Laser_Tunable81689A < Laser_Agilent8164A
    
    properties
        Cycles;
        DwellTime;
        SweepMode;
        RepeatMode;
    end
    
    methods
        function self = Laser_Tunable81689A()
            self = self@Laser_Agilent8164A();
            self.Name = 'Tunable 81689A Laser'; % name of the instrument
            self.Cycles = 1; % Sweep 1 cycles
            self.DwellTime = 0.1; % the amount of time spent at the wavelength
            self.StartWvl = 1525; % sweep wavelength (nm)
            self.StopWvl = 1526; % sweep wavelength (nm)
            self.StepWvl = 0.01; % step (nm)
            self.SweepMode = 0; % Stepped: 0 or Manual: 1
            self.RepeatMode = 0; % Oneway: 0 or Twoway: 1
            self.SweepSpeed = 5; % nm/s - Doesn't make any sense though
            self.Param.TunableLaserSlot = 1;
            self.Param.Password = '1111';
        end
        
        function connect(self)
            connect@Laser_Agilent8164A(self);
            self.GroupObj.Tunablelasersourcessweep = get(self.Obj, 'Tunablelasersourcestlssweep');
        end
        
        function [datapoints, channels] = setupSweep(self)
            % datapoints = number of datapoints for this sweep
            % channels = number of detector channels particpating in sweep
            %             disp('starting laser.setupSweep');
            %            self.GroupObj.Multiframelambdascan = get(self.Obj, 'Applicationswavelengthscanfunctionsmultiframelambdascan');
            self.Busy = 1;
            invoke(self.GroupObj.Multiframelambdascan, 'setsweepspeed', self.SweepSpeed);
            pause(self.PauseTime);
            
            datapoints = (self.StopWvl - self.StartWvl)/self.StepWvl;
            channels = 2; % Meaningless
            
            invoke(self.GroupObj.Tunablelasersourcessweep, ...
                'settlssweep', ...
                self.Param.TunableLaserSlot, ...
                self.SweepMode, ...
                self.RepeatMode, ...
                self.Cycles, ...
                self.DwellTime, ...
                self.nm2m(self.StartWvl), ...
                self.nm2m(self.StopWvl), ...
                self.nm2m(self.StepWvl), ...
                self.nm2m(self.SweepSpeed));
            
            if datapoints >= self.MaxDataPoints
                msg = strcat(self.Name, ' error. Sweep requires more datapoints than detector can support.');
                error (msg);
            end
            self.NumDataPoints = datapoints; % number of datapoints for this sweep
            self.Busy = 0;
            self.ReadyForSweep = 1;
        end
        
        % Execute sweep
        function resp = sweep(self)
            % returns array with wavelength value for each sample in (m)
            self.Busy = 1;
            if self.ReadyForSweep
                invoke(self.GroupObj.Tunablelasersourcessweep, ...
                    'tlssweepcontrol', ...
                    self.Param.TunableLaserSlot, ...
                    1);
                resp = [];
            else
                msg = strcat(self.Name, ': Need to call setupSweep before executing sweep.');
                error(msg);
            end
            self.Busy = 0;
            self.ReadyForSweep = 0;
        end
    end
end