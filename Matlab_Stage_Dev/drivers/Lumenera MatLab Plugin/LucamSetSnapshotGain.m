function LucamSetSnapshotGain(gain, cameraNum)
% LucamSetSnapshotGain - Sets the gain value for snapshot mode.
try
    LuDispatcher(17, cameraNum, gain);
catch
    errordlg(lasterr, 'Snapshot Gain Error', 'modal');
end