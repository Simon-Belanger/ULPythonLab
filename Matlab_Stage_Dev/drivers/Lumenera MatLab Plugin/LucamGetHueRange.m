function [min, max] = LucamGetHueRange(cameraNum)
% - LucamGetHueRange - Returns the valid range of hue values.
try
    range = LuDispatcher(55, cameraNum);
catch
    errordlg(lasterr, 'Hue Error', 'modal');
end
min = range(1);
max = range(2);