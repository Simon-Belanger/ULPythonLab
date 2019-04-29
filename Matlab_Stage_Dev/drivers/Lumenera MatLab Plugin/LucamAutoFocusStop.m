function LucamAutoFocusStop(cameraNum)
% LucamAutoFocusStop - Stops an auto-focus request.
try
    LuDispatcher(73, cameraNum);
catch
    errordlg(lasterr, 'Auto-Focus Stop Error', 'modal');
end