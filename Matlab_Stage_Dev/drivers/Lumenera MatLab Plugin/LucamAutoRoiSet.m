function LucamAutoRoiSet(startX, startY, width, height, cameraNum)
%LucamAutoRoiSet - Sets the parameters for the camera's region of interest.
try
    LuDispatcher(85, cameraNum, startX, startY, width, height);
catch
    errordlg(lasterr, 'Error setting the region of interest parameters.', 'modal');
end