function [LAMBDAARRAY, POWERARRAY]=test_script_Agilent_mainframe(varargin)
%Test script to test Agilent mainfram 8164A (with laser and detector set)
%Does a multiframe lambda scan
%Does a scan point by point
%
%Inputs: OUTPUTFILENAME, SETSTART, SETSTOP, SETSTEP, SETTEMP, SETTEMPHOLDTIME, SETSWEEPSPEED,
%SETPOWER, SETPWMCHANNELS, SETPWMCHANNEL, SETNUMBEROFSCANS,
%SETINITIALRANGE, SETRANGEDECREMENT
%
%OUTPUTFILENAME: data will be saved in .mat file as well as .fig files;
%intput type: string
%START and STOP: wavelength range in nm
%STEP: uniform scanning step in nm
%SETTEMP: set temperature, in C; input type: string
%SETTEMPHOLDTIME;  % temperature stablization time, in minutes
%SETSWEEPSPEED: options of 0 to 4 with 0=40 nm/s; 1=20 nm/s; 2= 10 nm/s; 3=5nm
%/s; 4=0.5 nm/s
%INPUTPOWER: in dBm
%SETNUMBEROFSCANS: use multiple scans can cover the whole range of interest
%(ATD dynamic range is 40 dB); 0 = 1 scan, 1 = 2 scans, 2 = 3 scans
%SETINITIALRANGE: uplimit of 1st scan, in dBm
%SETRANGEDECREMENT: uplimit of 2nd scan will be RANGEDECREMENT (in dB) than
%that of 1st scan;
%



deviceObj = icdevice('hp816x_v4p2', 'GPIB0::20::INSTR');
connect(deviceObj)
%
groupObj.MFL = get(deviceObj, 'Applicationswavelengthscanfunctionsmultiframelambdascan'); %creating group object to call functions in the group
groupObj.TLS = get(deviceObj, 'Tunablelasersources');
groupObj.PM = get(deviceObj, 'Powermetermodules');

%
POWERUNIT = 0; %% 0 = dBm, 1 = W
INPUTPOWER = 0; %% 0 dBm
OPTICALOUTPUT = 0; %% 0 = HighPower, 1 = LowSSE
NUMBEROFSCANS = 0; %% 0 = 1 Scan, 1 = 2 Scan, 2 = 3 Scan
PWMCHANNELS = 4; %% 1 = 1 Power Meter Channel
STEPSIZE = 10e-12; %10e-12; %% Step wavelength in meters
STARTWVL = 1480e-9;
STOPWVL = 1580e-9;
SETSWEEPSPEED=1;  %Depending on laser this can only go to 4
%
SETRESETTODEFAULT = 0;
INITIALRANGE = 0;
RANGEDECREMENT = 10;  %must be positive value;
PWMCHANNEL1 = 0; %% 0=1st PM Channel; 1=2nd
PWMCHANNEL2 = 1; %% 0=1st PM Channel; 1=2nd
PWMSlot = 1; 
AVGTIME = 0.0005; %in [s]
TLSSlot = 0;
LASERSTATE = 1;

CLIPTOLIMIT = 1; %% 0 = False, 1 = True
CLIPPINGLIMIT = -200; % Clipping Limit

disp('Connect to laser: initiate group objects');
%Prepare for multiframe lambda scan
invoke(groupObj.MFL,'registermainframe'); %registering mainframe
invoke(groupObj.MFL,'setinitialrangeparams',PWMCHANNEL1,SETRESETTODEFAULT,INITIALRANGE,RANGEDECREMENT);
invoke(groupObj.MFL,'setinitialrangeparams',PWMCHANNEL2,SETRESETTODEFAULT,INITIALRANGE,RANGEDECREMENT);
%
invoke(groupObj.MFL,'setsweepspeed',SETSWEEPSPEED);
%

invoke(groupObj.PM, 'setpwmwavelength', ...
                   PWMSlot, PWMCHANNEL1, 1550e-9);




disp('Prepare lambda scan');
%setting up the parameters for executemflambdascan
[DATAPOINTS,CHANNELS] =invoke(groupObj.MFL,'preparemflambdascan',POWERUNIT,INPUTPOWER,OPTICALOUTPUT,NUMBEROFSCANS,PWMCHANNELS,STARTWVL,STOPWVL,STEPSIZE);

WAVELENGTHARRAY = zeros(1,DATAPOINTS);
POWERARRAY = zeros(PWMCHANNELS, DATAPOINTS);
LAMBDAARRAY = zeros(PWMCHANNELS, DATAPOINTS);
disp('Start Scan...');
invoke(groupObj.MFL,'executemflambdascan', WAVELENGTHARRAY);

disp('Scan done - getting data...');
%
[POWERARRAY(1,:),LAMBDAARRAY(1,:)] = invoke(groupObj.MFL,'getlambdascanresult',PWMCHANNEL1,CLIPTOLIMIT,CLIPPINGLIMIT,POWERARRAY(1,:),LAMBDAARRAY(1,:));
[POWERARRAY(2,:),LAMBDAARRAY(2,:)] = invoke(groupObj.MFL,'getlambdascanresult',PWMCHANNEL2,CLIPTOLIMIT,CLIPPINGLIMIT,POWERARRAY(2,:),LAMBDAARRAY(2,:));

%

[temp1,temp2,AVERAGINGTIME,SWEEPSPEED] = invoke(groupObj.MFL,'getmflambdascanparametersq');
% START=START*1e9; % to nm
% STOP=STOP*1e9; % to nm
disp('Sweep finished');
disp(cat(2,'Detector average time: ', num2str(AVERAGINGTIME), 's'));
disp(cat(2,'Lambda sweep speed: ', num2str(SWEEPSPEED*1e9), 'nm/s'));

FIGScan = figure();
plot(LAMBDAARRAY(1,:)*1e9,POWERARRAY(1,:), '-', 'LineWidth', 1, 'MarkerSize', 1);
xlabel('Wavelength [nm]');
ylabel('Power [dBm]');
title(strcat('Avg time = ',num2str(AVERAGINGTIME),'s; Sweepspeed = ',num2str(SWEEPSPEED*1e9),' nm/s'));

disp('Start point by point measurement');
%Set up laser and detector for step by step measurement
invoke(groupObj.PM,'setpwmparameters',...
    PWMSlot, PWMCHANNEL1,...
    1,... %range mode
    0,... %power unit
    1,... %internal trigger
    1550e-9, ... %wavelength
    AVGTIME, ... % averaging time in [s]
    0); %power range
invoke(groupObj.PM,'setpwmparameters',...
    PWMSlot, PWMCHANNEL2,...
    1,... %range mode
    0,... %power unit
    1,... %internal trigger
    1550e-9, ... %wavelength
    AVGTIME, ... % averaging time in [s]
    0); %power range
    

% invoke(groupObj.PM,'setpwmpowerunit',PWMSlot,PWMCHANNEL1,0); %slot, channel, power unit
% invoke(groupObj.PM,'setpwmpowerrange',PWMSlot,PWMCHANNEL1,1,0); % slot, channel, rangemode , powerrange
% 
% invoke(groupObj.PM,'setpwmpowerunit',PWMSlot,PWMCHANNEL2,0);
% invoke(groupObj.PM,'setpwmpowerrange',PWMSlot,PWMCHANNEL2,1,0); % slot, channel, rangemode , powerrange

invoke(groupObj.TLS, 'settlslaserstate', TLSSlot, LASERSTATE);%, 1550e-9);% turn the tunable laser on

WavelengthSelection = 3;
data=zeros(2,DATAPOINTS);
ii = 1;
for wvl=STARTWVL:STEPSIZE:STOPWVL
    
    invoke(groupObj.PM,'setpwmwavelength',PWMSlot,PWMCHANNEL1,wvl);
    %invoke(groupObj.PM,'setpwmwavelength',PWMSlot,PWMCHANNEL2,wvl);
    invoke(groupObj.TLS, 'settlswavelength', TLSSlot, WavelengthSelection, wvl);
    data(2,ii)=invoke(groupObj.PM,'pwmreadvalue',PWMSlot,PWMCHANNEL1);
    data(1,ii)=wvl;
    ii=ii+1;
    pause(AVGTIME);
end
%


FIGPoint = figure();
plot(data(1,:)*1e9,data(2,:), 'x-', 'LineWidth', 1, 'MarkerSize', 1);
xlabel('Wavelength [nm]');
ylabel('Power [dBm]');
title(strcat('Point by Point - step: ',num2str(STEPSIZE*1e12), 'pm; Avg time = ' ,num2str(AVERAGINGTIME),' s'));

invoke(groupObj.MFL,'unregistermainframe');
disconnect(deviceObj);
delete(deviceObj);
clear deviceObj;
%
d=date;
saveas(FIGScan,strcat('Laser_test_scan_plot_',d,'.fig'))
print('-dpdf',strcat('Laser_test_scan_plot_',d,'.pdf'))
saveas(FIGPoint,strcat('Laser_test_point_plot_',d,'.fig'))
print('-dpdf',strcat('Laser_test_point_plot_',d,'.pdf'))
%

end
