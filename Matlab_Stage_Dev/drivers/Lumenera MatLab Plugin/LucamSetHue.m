function LucamSetHue(hue, cameraNum)
% LucamSetHue - Sets the hue value.
try
    LuDispatcher(48, cameraNum, hue);
catch
    errordlg(lasterr, 'Hue Error', 'modal');
end