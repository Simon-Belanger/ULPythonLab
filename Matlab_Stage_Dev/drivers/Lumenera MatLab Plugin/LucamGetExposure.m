function [exposure] = LucamGetExposure(cameraNum)
% LucamGetExposure - Returns the current exposure value.
try
    exposure = LuDispatcher(31, cameraNum);
catch
    errordlg(lasterr, 'Exposure Error', 'modal');
end