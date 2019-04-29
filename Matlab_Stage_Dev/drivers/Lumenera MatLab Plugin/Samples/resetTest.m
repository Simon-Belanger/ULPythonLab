echo on
%**************************************************************************
%      resetTest.m
%      =====================
%
% Descrition:  
%   Show how to reset camera.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamHidePreview
% - LucamCameraReset
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
currentCam=1;						% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=50;
LucamCameraOpen(currentCam);			% Connect to camera.
LucamShowPreview(currentCam);   		% Display preview.
Lucamsetbrightness(100,currentCam);		% Set Brightness to an unacceptable level.
pause(1); % pause for a sec. to guive time to see that it reset the camera parameter to default.
LucamHidePreview(currentCam);			% To reset camera the preview have to be close.
LucamCameraReset(currentCam);			% Make sure we are at camera hardware reset.
LucamShowPreview(currentCam);			% Display preview.
pause(1);					% Give time to see reset effect.
LucamCameraClose(currentCam);			% disconnect from camera.

	