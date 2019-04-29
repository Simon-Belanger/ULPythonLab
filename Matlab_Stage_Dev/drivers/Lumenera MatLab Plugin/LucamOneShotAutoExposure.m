function LucamOneShotAutoExposure(height, width, startY, startX, target, cameraNum)
% LucamOneShotAutoExposure - Performs one shot auto-exposure.
try
    LuDispatcher(64, cameraNum, target, startX, startY, width, height);
catch
    errordlg(lasterr, 'Auto-Exposure Error', 'modal');
end