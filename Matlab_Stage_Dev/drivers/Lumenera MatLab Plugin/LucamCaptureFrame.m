function [frame] = LucamCaptureFrame(cameraNum)
% LucamCaptureFrame - Captures a single video frame.
try
    frame = LuDispatcher(7, cameraNum);
catch
    errordlg(lasterr, 'Frame Capture Error', 'modal');
end