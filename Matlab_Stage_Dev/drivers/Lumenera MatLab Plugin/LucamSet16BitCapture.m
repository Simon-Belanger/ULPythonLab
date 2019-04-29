function LucamSet16BitCapture(flag, cameraNum)
% LucamSet16BitCapture - Enables or disables 16 bit video frame capture.
try
    LuDispatcher(10, cameraNum, flag);
catch
    errordlg(lasterr, 'Flag Error', 'modal');
end