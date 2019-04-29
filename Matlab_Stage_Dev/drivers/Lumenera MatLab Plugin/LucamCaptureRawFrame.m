function [frame] = LucamCaptureRawFrame(cameraNum)
% LucamCaptureFrame - Captures a single video frame.
try
    frame = LuDispatcher(76, cameraNum);
catch
    errordlg(lasterr, 'Raw Frame Capture Error', 'modal');
end