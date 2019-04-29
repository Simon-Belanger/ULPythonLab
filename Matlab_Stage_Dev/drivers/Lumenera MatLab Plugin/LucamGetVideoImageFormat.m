function [videoFormat] = LucamGetVideoImageFormat(cameraNum)
try
    videoFormat = LuDispatcher(99, cameraNum);
catch
    errordlg(lasterr, 'Video Image Format Error', 'modal');
end