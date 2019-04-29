% Note - This will only succeed with the latest version of the driver.
function [revision] = LucamGetHardwareRevision(cameraNum)
try
    revision = LuDispatcher(94, cameraNum);
catch
    errordlg(lasterr, 'Hardware Revision Aquisition Error', 'modal');
end