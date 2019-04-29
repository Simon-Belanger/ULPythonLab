function [lvVersion] = LucamQueryVersion(cameraNum)
% LucamQueryVersion - Returns the camera software version information and serial number.
try
    lvVersion = LuDispatcher(57, cameraNum);
catch
    errordlg(lasterr, 'Query Version Error', 'modal');
end