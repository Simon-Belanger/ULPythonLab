function LucamSetSnapshotExposure(exposure, cameraNum)
% LucamSetSnapshotExposure - Sets the exposure time for snapshot mode.
try
    LuDispatcher(15, cameraNum, exposure);
catch
    errordlg(lasterr, 'Snapshot Exposure Error', 'modal');
end