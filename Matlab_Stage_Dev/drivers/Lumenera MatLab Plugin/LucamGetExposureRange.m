% Call as such: [min,max] = LucamGetExposureRange(<cameraNum>);
function [min, max] = LucamGetExposureRange(cameraNum)
% - LucamGetExposureRange - Returns the valid range of exposure values.
try
    range = LuDispatcher(14, cameraNum);
catch
    errordlg(lasterr, 'Exposure Error', 'modal');
end
min = range(1);
max = range(2);