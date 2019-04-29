echo on
%**************************************************************************
%       tdisplay.m 
%      =============================
%
% Descrition:  
%	Show basic windows manipulation
%
% API functions used:
%   - LucamCameraOpen
%   - LucamShowPreview
%   - LucamSetDisplayWindowSize
%   - LUcamAdjustDisplayWindow
%   - LucamHidePreview
%   - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
currentCam=1;
LucamCameraOpen(currentCam);				% Open Session with camera.
LucamShowPreview(currentCam);				% Show camera preview.
LucamSetDisplayWindowSize(currentCam, 640, 480);	% Resize display windows.
pause(2);
LucamAdjustDisplayWindow(5,5,600,400,currentCam);	% Adjust the the viewing video in display windows.
pause(2);
LucamHidePreview(currentCam);				% Hide camera preview.
LucamCameraClose(currentCam);				% Close camera session.
