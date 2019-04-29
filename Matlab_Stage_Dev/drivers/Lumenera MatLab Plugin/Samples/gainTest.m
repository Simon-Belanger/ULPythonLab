echo on
%**************************************************************************
%      gainTest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Show how to call gain specific functions.
%
% API functions used:
% - LucamGetGainRange
% - LucamGetGain
% - LucamSetGain
% - LucamCameraOpen
% - LucamCameraClose
% - LucamShowPreview
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=50;
LucamCameraOpen(cam);					% Open camera to work with.
LucamShowPreview(cam);					% Display camera preview.
[cmin,cmax]=LucamGetGainRange(cam)			% Get camera gain range.
defaultGain=LucamGetGain(cam)				% Get current gain for camera.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare for upward count for gain changes.
    LucamSetGain(c,cam);				% Set Gain.
    pause(nbdelay);					% Pause to give chance to see gain change.
end
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare for downward count for gain changes.
    LucamSetGain(c,cam);				% Set Gain.
    pause(nbdelay);					% Pause to give chance to see gain change.
end
LucamSetGain(defaultGain,cam);    			% Return gain value to where is was before test.
LucamCameraClose(cam);					% Close camera that we work with.