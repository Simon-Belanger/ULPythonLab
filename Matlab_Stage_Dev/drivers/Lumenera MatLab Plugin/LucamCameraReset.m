function LucamCameraReset(cameraNum)
% LucamCameraReset - Resets the specified camera to power-on settings.
try
    LuDispatcher(83, cameraNum);
catch
    errordlg(lasterr, 'Reset Error', 'modal');
end