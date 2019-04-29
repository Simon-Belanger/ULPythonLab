function [startX, startY, width, height] = LucamAutoRoiGet(cameraNum)
%LucamAutoRoiGet - Gets the region of interest parameters from the auto
%functions.
try
    roi = LuDispatcher(84, cameraNum);
    startX = roi(1);
    startY = roi(2);
    width = roi(3);
    height = roi(4);
catch
    errordlg(lasterr, 'Region of Interest Error', 'modal');
end