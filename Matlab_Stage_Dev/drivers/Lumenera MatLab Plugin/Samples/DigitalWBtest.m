echo on
%**************************************************************************
%      DigitalWBtest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test digital White Balance functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamDigitalWhiteBalance
% - LucamDigitalWhiteBalanceEx
% - LucamHidePreview
% - LucamCameraReset
% - LucamcameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - Usually when error it is because the frame is too bright.
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=100;						% Number of different level of contrast.
LucamCameraOpen(cam);					% Open working camera.
LucamCameraReset(cam);					% Put camera to hardware default.
[sx,sy]=LucamGetFrameSize(cam);				% Get frame size.
LucamShowPreview(cam);					% Display preview.
pause(pbreak);						% give some time to see preview.
for c=0:1:3						% Prepare for first WB
    LucamDigitalWhiteBalance(sy, sx, 0, 0, cam);  	% Perform WB
    pause(nbdelay);					% Wait.
end
pause(pbreak);						% Wait to see change.
LucamHidePreview(cam);					% Hide Preview.
LucamCameraReset(cam);    				% Return Camera to default value.
[sx,sy]=LucamGetFrameSize(cam);				% Read working frame.
LucamShowPreview(cam);					% Show Preview.
pause(pbreak);						% Give time to see display.
		
for c=0:1:3						% Prepare for target WB.
    LucamDigitalWhiteBalanceEx(sy, sx, 0, 0, (217/229),(249/229), cam);
    pause(nbdelay);					% Wait to see effect.
end
pause(pbreak);						% Give time to see display.
LucamHidePreview(cam);					% Hide preview
LucamCameraReset(cam);					% Return Camera to harware default.
LucamCameraClose(cam);					% Close working camera.

