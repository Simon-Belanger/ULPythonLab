function LucamOneShotAutoWhiteBalance(height, width, startY, startX, cameraNum)
% LucamOneShotAutoWhiteBalance - Performs one shot auto-white balance.
try
    LuDispatcher(65, cameraNum, startX, startY, width, height);
catch
    errordlg(lasterr, 'Auto-White Balance Error', 'modal');
end