echo on
%**************************************************************************
%      huetest.m
%      =====================
%
% Descrition:  
%   Show how to call hue specific functions.
%
% API functions used:
% - LucamGetHueRange
% - LucamGetHue
% - LucamSetHue
% - LucamCameraOpen
% - LucamShowPreview
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

LucamCameraOpen(currentCam);				% Open Camera to work with.
LucamShowPreview(currentCam);				% Display preview of working camera.
[cmin,cmax]=LucamGetHueRange(currentCam)		% Get Hue range from camera.
hueDefault=LucamGetHue(currentCam)			% Get camera current hue setting.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare for upward hue value change.
    LucamSetHue(c,currentCam);				% Set Hue setting.
    pause(nbdelay);					% pause to let it visible to human eye.
end			
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare for downward hue value change.
    LucamSetHue(c,currentCam);				% Set Hue setting.
    pause(nbdelay);					% Pause to let it visible to human eye.
end
LucamSetHue(hueDefault,currentCam);			% Return to Initial Hue setting.
LucamCameraClose(currentCam);				% Pause Camera.

