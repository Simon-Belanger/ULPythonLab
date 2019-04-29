function LucamSetFormat(frameFormat, cameraNum)
%LucamSetFormat - Sets the video frame format and frame rate used by the camera.
try
    LuDispatcher(63, cameraNum, frameFormat);
catch
    errordlg(lasterr, 'Frame Format Error', 'modal');
end