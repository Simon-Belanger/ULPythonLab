echo on
%**************************************************************************
%      ROItest.m
%      =====================
%
% Descrition:  
%   Show how set Region Of Interest.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamGetOffset
% - LucamSetOffset
% - LucamGetFormat
% - LucamCameraClose
% - LucamHidePreview
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
LucamCameraOpen(currentCam);				% Select camera to work with.
LucamShowPreview(currentCam);				% Display Preview
frameFormat=LucamGetFormat(currentCam)                  % Get Frame Format
pause(pbreak);						% Give time to see preview.
pause(pbreak);
lucamHidePreview(currentCam);				% clear preview.
frameFormat.width=320;					% Prepare for new ROI window
frameFormat.height=240;
LucamSetFormat(frameFormat,currentCam);			% Set new ROI window
LucamShowPreview(currentCam);				% Display camera preview.
[ooffsetX,ooffsetY]=LucamGetOffset(currentCam)		% display Camera offset.
LucamSetOffset(600,640,currentCam);			% Change offset.
[offsetX,offsetY]=LucamGetOffset(currentCam)		% Read offset to make sure it change
pause(pbreak);						% Give time to see offset change.
pause(pbreak);
LucamSetOffset(240,128,currentCam);			% Set to a new offset.
[offsetX,offsetY]=LucamGetOffset(currentCam)		% Change offset again
pause(3);						% Give time to see offset changes.
frameFormat=LucamGetFormat(currentCam)                  % Get Frame Format
LucamHidePreview(currentCam);				% Clear camera preview.
LucamCameraReset(currentCam);				% Bring camera to it's hardware default value.
LucamCameraClose(currentCam);				% End session with working camera.