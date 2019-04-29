function [eventID] = LucamRegisterEventNotification(event, cameraNum)
% LucamRegisterEventNotification - Registers an event for the camera.
% - event is one of the possible events defined in lucamapi.h
% Return value is an ID that can be used to unregister the event at a later
% time using LucamUngegisterEventNotification.
try
    eventID = LuDispatcher(92, cameraNum, event);
catch
    errordlg(lasterr, 'Register Event Error', 'modal');
end