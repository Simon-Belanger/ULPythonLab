echo on
%**************************************************************************
%       Basic.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Display basic information about camera. 
%
% API functions used:
%  - LucamNumCameras
%* - LucamConnect
%* - LucamIsConnected
%* - LucamQueryVersion
%* - LucamGetTruePixel
%* - LucamEnumAvailablreFrameRates
%* - LucamListFrameRates
%* - LucamGetCameraId
%* - LucamGetHardwareRevision
%* - LucamDisconnect
%* - LucamNumCameras
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - LucamGetHardwareRevision is not supported by all camera.
%
%**************************************************************************
echo off
cam=1;				% Working Camera number.
nbCam=LucamNumCameras() 	% Number of camera found.
LucamConnect(cam);              % Connecting to camera.
con=LucamIsConnected(cam)	% is camera connected.
lver=LucamQueryVersion(cam);    % Return Camera revision.
ldepth=LucamGetTruePixelDepth(cam) % True Pixel Depth of camera.
avFRates=LucamEnumAvailableFrameRates(cam) % Availablre Frame rates.
avFList=LucamListFrameRates(cam)  % List Frame Rates
camid=LucamGetCameraId(cam)	% Camera identification number.
%hardwareRev=LucamGetHardwareRevision(cam)
LucamDisconnect(cam);
