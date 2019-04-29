function LucamSetUseStrobe(flag, cameraNum)
% LucamSetUseStrobe - Enables or disables the strobe pulse output when taking snapshots.
try
    LuDispatcher(22, cameraNum, flag);
catch
    errordlg(lasterr, 'Strobe Error', 'modal');
end