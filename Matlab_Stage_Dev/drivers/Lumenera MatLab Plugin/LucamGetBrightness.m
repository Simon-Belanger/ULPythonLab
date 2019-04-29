function [brightness] = LucamGetBrightness(cameraNum)
% LucamGetBrightness - Returns the current brightness value.
try
    brightness = LuDispatcher(45, cameraNum);
catch
    errordlg(lasterr, 'Brightness Error', 'modal');
end