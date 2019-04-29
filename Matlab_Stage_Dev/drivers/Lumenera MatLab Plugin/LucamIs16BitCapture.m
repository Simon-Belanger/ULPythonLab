function [flag] = LucamIs16BitCapture(cameraNum)
% LucamIs16BitCapture - Queries if the camera is running in 16 preview mode.
try
    flag = LuDispatcher(11, cameraNum);
catch
    errordlg(lasterr, 'Flag Error', 'modal');
end