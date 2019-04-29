echo on
%**************************************************************************
%       videoinfo.m 
%      ============================
%
% Descrition:  Test different Lumenera API function to acquire video
%     information.
%
% API functions used:
%  - LucamCameraOpen
%  - LucamShowPreview
%  - LucamGetVideoImageFormat
%  - LucamGetFrameRate
%  - LucamGetFrameSize
%  - LucamListFrameRates
%  - LucamSetFrameRate
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
LucamCameraOpen(1);                         % Open camera to test with.
LucamShowPreview(1);                        % Display Video Preview.
viFormat=LucamGetVideoImageFormat(1)        % Read current video Image format.
vfFormat=LucamGetFrameRate(1)               % Read current frame rate per second (FPS).
[vfWidth,vfHeight]=LucamGetFrameSize(1)    % Read current Video frame size.
fl=LucamListFrameRates(1)                   % Read Available Frame rates for open camera.
LucamSetFrameRate(fl(2),1);                 % Set FPS to second available Frame rate.
vff=LucamGetFrameRate(1)                   % Read current FPS.
LucamSetFrameRate(vfFormat,1);
LucamCameraClose(1);
