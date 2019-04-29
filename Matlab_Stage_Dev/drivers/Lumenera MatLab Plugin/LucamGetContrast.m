function [contrast] = LucamGetContrast(cameraNum)
% LucamGetContrast - Returns the current contrast value.
try
    contrast = LuDispatcher(43, cameraNum);
catch
    errordlg(lasterr, 'Contrast Error', 'modal');
end