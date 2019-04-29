function LucamAdjustDisplayWindow(x, y, width, height, cameraNum)
%LucamAdjustDisplayWindow - Sets the scale and viewing area of the preview
%window
try
    LuDispatcher(80, cameraNum, x, y, width, height);
catch
    errordlg(lasterr, 'Error Adjusting Display Window', 'modal');
end