deviceObj_laser = icdevice('hp816x_v4p2.mdd', 'GPIB0::20::INSTR')
connect(deviceObj_laser)
groupObj_laser = get(deviceObj_laser, 'Applicationswavelengthscanfunctionsmultiframelambdascan')
invoke(groupObj_laser,'registermainframe')
%%
deviceObj_pm = icdevice('hp816x_v4p2.mdd', 'USB0::0x0957::0x3718::my48101048::0::INSTR')
connect(deviceObj_pm)
groupObj_pm = get(deviceObj_pm, 'Applicationswavelengthscanfunctionsmultiframelambdascan')
invoke(groupObj_pm,'registermainframe')

%%
POWERUNIT = 0 %% 0 = dBm, 1 = W
POWER = 0 %% 0 dBm
OPTICALOUTPUT = 0 %% 0 = HighPower, 1 = LowSSE
NUMBEROFSCANS = 0 %% 0 = 1 Scan, 1 = 2 Scan, 2 = 3 Scan
PWMCHANNELS = 7 %% 1 = Power Meter Channel Count
STARTWAVELENGTH = 1510e-9 %% Start wavelength in meters
STOPWAVELENGTH = 1560e-9 %% Stop wavelength in meters
STEPSIZE = 1e-10 %% Step wavelength in meters

[DATAPOINTS,CHANNELS] = invoke(groupObj_laser,'preparemflambdascan',POWERUNIT,POWER,OPTICALOUTPUT,NUMBEROFSCANS,PWMCHANNELS,STARTWAVELENGTH,STOPWAVELENGTH,STEPSIZE)
%%
 WAVELENGTHARRAY = zeros(1,DATAPOINTS);
[WAVELENGTHARRAY] = invoke(groupObj_laser,'executemflambdascan', WAVELENGTHARRAY);
%%
PWMCHANNEL = 0 %% 1st PM Channel - zero based index - PM channel 1 = 0
CLIPTOLIMIT = 0 %% 0 = False, 1 = True
CLIPPINGLIMIT = -100 %% Clipping Limit
POWERARRAY = zeros(1, DATAPOINTS);
LAMBDAARRAY = zeros(1, DATAPOINTS);
[POWERARRAY,LAMBDAARRAY] = invoke(groupObj_pm,'getlambdascanresult',PWMCHANNEL,CLIPTOLIMIT,CLIPPINGLIMIT,POWERARRAY,LAMBDAARRAY)

plot(LAMBDAARRAY,POWERARRAY)

invoke(groupObj_laser,'unregistermainframe')
invoke(groupObj_pm,'unregistermainframe')
disconnect(deviceObj_laser)
disconnect(deviceObj_pm)
delete(deviceObj_laser)
delete(deviceObj_pm)
clear deviceObj_laser
clear deviceObj_pm




