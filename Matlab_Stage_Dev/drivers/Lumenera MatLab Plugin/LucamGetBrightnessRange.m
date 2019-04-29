% Call as such: [min,max] = LucamGetBrightnessRange(<cameraNum>);
function [min, max] = LucamGetBrightnessRange(cameraNum)
% - LucamGetBrightnessRange - Returns the valid range of brighness values.
try
    range = LuDispatcher(54, cameraNum);
catch
    errordlg(lasterr, 'Brightness Error', 'modal');
end
min = range(1);
max = range(2);