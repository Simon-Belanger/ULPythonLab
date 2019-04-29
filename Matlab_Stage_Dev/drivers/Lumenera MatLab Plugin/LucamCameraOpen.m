function [handle] = LucamCameraOpen(cameraNum)
% LucamCameraOpen - Connect to the Lumenera camera specified.
try
    LuDispatcher(-1, cameraNum);
    handle = cameraNum;
catch
    errordlg(lasterr, 'Connect Error', 'modal');
end