function [frames] = LucamTakeFastFrames (numFrames, cameraNum)
%LucamTakeFastFrames - Take multiple fast frames.
try
    frames = LuDispatcher(87, cameraNum, numFrames);
catch
    errordlg(lasterr, 'Fast Frames Error', 'modal');
end