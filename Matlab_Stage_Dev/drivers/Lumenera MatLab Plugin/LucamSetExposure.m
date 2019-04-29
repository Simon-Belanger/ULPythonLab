function LucamSetExposure(exposure, cameraNum)
% LucamSetExposure - Sets the exposure value in video mode.
try
    LuDispatcher(30, cameraNum, exposure);
catch
    errordlg(lasterr, 'Exposure Error', 'modal');
end