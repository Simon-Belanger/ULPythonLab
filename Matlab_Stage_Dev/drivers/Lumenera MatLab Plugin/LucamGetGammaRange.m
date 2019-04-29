% Call as such: [min,max] = LucamGetGammaRange(<cameraNum>);
function [min, max] = LucamGetGammaRange(cameraNum)
% - LucamGetGammaRange - Returns the valid range for gamma values.
try
    range = LuDispatcher(52, cameraNum);
catch
    errordlg(lasterr, 'Gamma Error', 'modal');
end
min = range(1);
max = range(2);