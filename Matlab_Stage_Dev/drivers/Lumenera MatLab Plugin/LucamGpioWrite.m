function LucamGpioWrite(cameraNum, gpioWrite)
% LucamGpioWrite - Writes a value to the GPO port.
try
    LuDispatcher(35, cameraNum, gpioWrite);
catch
    errordlg(lasterr, 'GPIO Write Error', 'modal');
end