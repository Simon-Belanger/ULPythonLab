function [pPercentageCompleted] = LucamAutoFocusQueryProgress(cameraNum)
% LucamAutoFocusQueryProgress - Queries the progress of an auto-focus request.
try
    pPercentageCompleted = LuDispatcher(74, cameraNum);
catch
    errordlg(lasterr, 'Auto-Focus Query Progress Error', 'modal');
end