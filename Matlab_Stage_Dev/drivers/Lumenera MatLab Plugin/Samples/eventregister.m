echo on
%**************************************************************************
%      eventregister.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Show how to call the Even register functions.
%
% API functions used:
%    - LucamCameraOpen
%    - LucamRegisterEventNotification
%    - LucamUnregisterEventNotification
%    - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - event is one of the possible events defined in lucamapi.h
%    Return value is an ID that can be used to unregister the event at a later
%    time using LucamUngegisterEventNotification.
%  - Event support depend on the camera model.
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=100;
LucamCameraOpen(cam);					% Open Camera to work with.
LucamGpioConfigure(0,cam);				% Setup GPIO port as input. 
lEStartofReadout       =LucamRegisterEventNotification(2, cam); % Register an event on start of frame readout.
lEGPI1Changed          =LucamRegisterEventNotification(4, cam);	% Register the GPI1 change event.
lEGPI2Changed          =LucamRegisterEventNotification(5, cam); % Register the GPI2 change event.
lEGPI3Changed          =LucamRegisterEventNotification(6, cam); % Register the GPI3 change event.
lEGPI4Changed          =LucamRegisterEventNotification(7, cam); % Register the GPI4 change event.
lEDeviceSurpriseRemoval=LucamRegisterEventNotification(32,cam); % Register the suprise unplug event.
LucamUnregisterEventNotification(cam,lEStartofReadout); 	% Unregister an event on start of frame readout
LucamUnregisterEventNotification(cam,lEGPI1Changed);		% Unregister the GPI1 change event.
LucamUnregisterEventNotification(cam,lEGPI2Changed);		% Unregister the GPI2 change event.
LucamUnregisterEventNotification(cam,lEGPI3Changed);		% Unregister the GPI3 change event.
LucamUnregisterEventNotification(cam,lEGPI4Changed); 		% Unregister the GPI4 change event.
LucamUnregisterEventNotification(cam,lEDeviceSurpriseRemoval);	% Unregister an event on start of frame readout
LucamCameraClose(cam);					% Close Camera that we worked with.
