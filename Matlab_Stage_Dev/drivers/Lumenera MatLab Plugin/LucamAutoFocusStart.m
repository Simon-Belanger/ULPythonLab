function LucamAutoFocusStart(height, width, startY, startX, cameraNum)
% LucamAutoFocusStart - Performs one shot auto-focus calculation.
try
    LuDispatcher(71, cameraNum, startX, startY, width, height, 0, 0, 0, 0, 0);
catch
    errordlg(lasterr, 'Auto-Focus Start Error', 'modal');
end