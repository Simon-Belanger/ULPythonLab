function [frames] = LucamCaptureMultipleFrames(num_frames, cameraNum)
%LucamCaptureMultipleFrames - Captures multiple video frames.
try
    for i = 1:num_frames
        frames(:,:,:,i) = LuDispatcher(7, cameraNum);
    end
catch
    errordlg(lasterr, 'Frame Capture Error', 'modal');
end
