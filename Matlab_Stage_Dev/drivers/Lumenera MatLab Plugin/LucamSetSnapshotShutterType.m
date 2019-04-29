function LucamSetSnapshotShutterType(cameraNum, shutterType)
% LucamSetSnapshotShutterType - sets the shutter type on the camera with ID cameraNum.
try
    LuDispatcher(78, cameraNum, shutterType);
catch
    errordlg(lasterr, 'Error Setting Shutter Type', 'modal');
end