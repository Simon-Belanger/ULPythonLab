function [gain] = LucamGetGain(cameraNum)
% LucamGetGain - Returns the current gain value.
try
    gain = LuDispatcher(29, cameraNum);
catch
    errordlg(lasterr, 'Gain Error', 'modal');
end