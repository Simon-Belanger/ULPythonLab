function LucamSetSnapshotColorGain(red, green1, green2, blue, cameraNum)
% LucamSetSnapshotColorGain - Sets the color gain values in snapshot mode.
try
    LuDispatcher(20, cameraNum, red, green1, green2, blue);
catch
    errordlg(lasterr, 'Color Gain Error', 'modal');
end