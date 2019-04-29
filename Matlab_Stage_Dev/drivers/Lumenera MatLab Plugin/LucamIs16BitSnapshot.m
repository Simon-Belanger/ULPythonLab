function [flag] = LucamIs16BitSnapshot(cameraNum)
% LucamIs16BitSnapshot - Queries if the camera is running in 16 bit snapshot mode.
try
    flag = LuDispatcher(19, cameraNum);
catch
    errordlg(lasterr, 'Snapshot Mode Error', 'modal');
end