function [lvVersions] = LucamEnumCameras()
% LucamEnumCameras - Returns the camera software version information and serial number.
try
    lvVersions = LuDispatcher(38);
catch
    errordlg(lasterr, 'Enumerate Camera Error', 'modal');
end