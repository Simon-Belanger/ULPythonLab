function [frames] = LucamTakeVideo(num_frames, cameraNum)
%LucamTakeVideo - Captures multiple video frames.
try
    if num_frames == 1
        frames = LuDispatcher(7, cameraNum);
    else
        for i = 1:num_frames
            frames(:,:,:,i) = LuDispatcher(7, cameraNum);
        end
    end 
catch
    errordlg(lasterr, 'Frame Capture Error', 'modal');
end
