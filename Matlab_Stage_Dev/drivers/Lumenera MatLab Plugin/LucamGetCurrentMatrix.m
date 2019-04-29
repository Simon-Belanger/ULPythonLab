function [matrix] = LucamGetCurrentMatrix (cameraNum)
% LucamGetCurrentMatrix - Gets the current color correction matrix being
% applied to video preview.
try
    matrix = LuDispatcher(86, cameraNum);
catch
    errordlg(lasterr, 'Get Current Matrix Error', 'modal');
end