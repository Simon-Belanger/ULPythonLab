function [flag] = LucamIsUsingHwTrigger(cameraNum)
% LucamIsUsingHwTrigger - Queries if the camera is using an external HW trigger as its snapshot trigger source.
% trigger.
try
    flag = LuDispatcher(27, cameraNum);
catch
    errordlg(lasterr, 'Hw Trigger Error', 'modal');
end