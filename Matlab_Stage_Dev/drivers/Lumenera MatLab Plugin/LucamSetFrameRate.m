function LucamSetFrameRate(fps, cameraNum)
% LucamSetFrameRate - Sets the video frame rate.
try
    LuDispatcher(3, cameraNum, fps);
catch
    errordlg(lasterr, 'Frame Rate Error', 'modal');
end