function LucamSetBrightness(brightness, cameraNum)
% LucamSetBrightness - Sets the brightness value.
try
    LuDispatcher(46, cameraNum, brightness);
catch
    errordlg(lasterr, 'Brightness Error', 'modal');
end