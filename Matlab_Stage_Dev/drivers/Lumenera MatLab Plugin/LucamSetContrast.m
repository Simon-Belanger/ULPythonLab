function LucamSetContrast(contrast, cameraNum)
% LucamSetContrast - Sets the contrast value.
try
    LuDispatcher(44, cameraNum, contrast);
catch
    errordlg(lasterr, 'Contrast Error', 'modal');
end