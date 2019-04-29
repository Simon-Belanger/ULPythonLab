function [camID] = LucamGetCameraId(cameraNum)
% LucamGetCameraId - Returns the camera model number.
try
    dID = LuDispatcher(59, cameraNum);
catch
    errordlg(lasterr, 'Camera ID Error', 'modal');
end
camID = dec2hex(dID, 3);
