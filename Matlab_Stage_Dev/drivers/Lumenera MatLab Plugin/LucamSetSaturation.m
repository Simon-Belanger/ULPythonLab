function LucamSetSaturation(saturation, cameraNum)
% LucamSetSaturation - Sets the saturation value.
try
    LuDispatcher(50, cameraNum, saturation);
catch
    errordlg(lasterr, 'Saturation Error', 'modal');
end