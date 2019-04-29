echo on
%**************************************************************************
%       BrigthnessTest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test Brigthness  the set and get property also.
%
% API functions used:
%  - LucamCameraOpen
%  - LucamShowPreview
%  - LucamGetBrightnessRange
%  - LucamGetBrightness
%  - LucamGetPropertyRange
%  - LucamGetProperty
%  - LucamSetProperty
%  - LucamSetBrightness
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;						% Delay use in iteration changes.
cint=25;						% Number of different level of brigthness.
LucamCameraOpen(cam);					% Open Camera to work with.
LucamShowPreview(cam);					% Display preview of camera.
[cmin,cmax]=LucamGetBrightnessRange(cam)        	% Get current BrightnessRange.
brigthnessdefault=LucamGetBrightness(cam)               % Get current Brightness seting.
[minprop, maxprop]=LucamGetPropertyRange(0,cam)		% Get current Brightness Range with GetProperty function
brigthnessPropDefault=LucamGetProperty(0,cam)		% Get current Brightness Setting with Get Property function.
LucamSetProperty(0,100,0,cam);				% Set High Level of Brigthness to see effect on preview.
pause(pbreak);						% Give a chance to see effect on screen.
brightnessNew=LucamGetProperty(0,cam)			% Show current Bigthness settings.
LucamSetProperty(0,brigthnessPropDefault,0,cam);	% Return Brightness to initial value.
pause(pbreak);						% Give a chance to see effect on preview window.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare for up-going brigthness level.
    LucamSetBrightness(c,cam);				% Change Brightness level.
    pause(nbdelay);					% Pause to give a chance to see level.
end
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare for down-going brigthness level.
    LucamSetBrightness(c,cam);				% Change Brigthness level.
    pause(nbdelay);					% Pause to give a chance to see level changes.
end
LucamSetBrightness(brigthnessdefault,cam); 		% Return Brigthness level to Initial state.
LucamCameraClose(cam);					% Close working camera.
