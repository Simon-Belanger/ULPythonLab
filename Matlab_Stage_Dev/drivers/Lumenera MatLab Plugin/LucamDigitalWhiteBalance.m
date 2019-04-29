function LucamDigitalWhiteBalance(height, width, startY, startX, cameraNum)
% LucamDigitalWhiteBalance - Performs one shot auto-white balance.
try
    LuDispatcher(67, cameraNum, startX, startY, width, height);
catch
    errordlg(lasterr, 'Auto-White Balance Error', 'modal');
end