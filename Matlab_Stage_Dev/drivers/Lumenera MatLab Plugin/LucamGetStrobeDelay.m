function [delay] = LucamGetStrobeDelay(cameraNum)
% LucamGetStrobeDelay - Returns the current strobe delay value.
try
    delay = LuDispatcher(25, cameraNum);
catch
    errordlg(lasterr, 'Strobe Delay Error', 'modal');
end