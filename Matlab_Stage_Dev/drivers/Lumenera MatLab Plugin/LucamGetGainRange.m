% Call as such: [min,max] = LucamGetGainRange(<cameraNum>);
function [min, max] = LucamGetGainRange(cameraNum)
% - LucamGetGainRange - Returns the valid range for gain values.
try
    range = LuDispatcher(16, cameraNum);
catch
    errordlg(lasterr, 'Gain Error', 'modal');
end
min = range(1);
max = range(2);