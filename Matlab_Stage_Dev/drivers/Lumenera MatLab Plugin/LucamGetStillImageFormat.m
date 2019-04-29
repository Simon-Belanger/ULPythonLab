function [stillFormat] = LucamGetStillImageFormat(cameraNum)
try
    stillFormat = LuDispatcher(98, cameraNum);
catch
    errordlg(lasterr, 'Still Image Format Error', 'modal');
end