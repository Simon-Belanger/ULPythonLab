function [frames] = LucamTakeMultipleSnapshots(num_frames, cameraNum)
%LucamTakeMultipleSnapshots - Take multiple snapshots in a sequence using the same camera settings.
try
    for i = 1:num_frames
        frames(:,:,:,i) = LuDispatcher(13, cameraNum);
    end
catch
    errordlg(lasterr, 'Snapshot Error', 'modal');
end
