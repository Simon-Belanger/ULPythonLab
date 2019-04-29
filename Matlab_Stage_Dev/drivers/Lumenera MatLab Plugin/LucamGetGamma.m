function [gamma] = LucamGetGamma(cameraNum)
% LucamGetGamma - Returns the current gamma value.
try
    gamma = LuDispatcher(41, cameraNum);
catch
    errordlg(lasterr, 'Gamma Error', 'modal');
end