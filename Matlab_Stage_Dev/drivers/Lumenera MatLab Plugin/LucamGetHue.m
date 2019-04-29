function [hue] = LucamGetHue(cameraNum)
% LucamGetHue - Returns the current hue value.
try
    hue = LuDispatcher(47, cameraNum);
catch
    errordlg(lasterr, 'Hue Error', 'modal');
end