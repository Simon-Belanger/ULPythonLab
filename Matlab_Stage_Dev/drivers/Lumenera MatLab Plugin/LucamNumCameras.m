function [numCams] = LucamNumCameras()
% LucamNumCameras - Reads the current number of cameras connected to the computer.
try
    numCams = LuDispatcher(37);
    numCameras = numCams(1);
catch
    errordlg(lasterr, 'Error acquiring number of cameras connected', 'modal');
end