echo on
%**************************************************************************
%      SaturationTest.m
%      =====================
%
% Descrition:  
%   Show how read and change Saturation setting with Lumenera Camera..
%
% API functions used:
%* -LucamGetSaturationRange
%* -LucamGetSaturation
%* -LucamSetSaturation
%* -LucamCameraOpen
%* -LucamShowPreview
%* -LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
currentCam=1;						% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;						% Delay use in iteration changes.
cint=50;
LucamCameraOpen(currentCam);				% Open session with working camera.
LucamShowPreview(currentCam);				% Display selected camera preview.
[cmin,cmax]=LucamGetSaturationRange(currentCam)		% Get Saturation range from camera.
saturationDefault=LucamGetSaturation(currentCam)	% Get current saturation camera setting.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare to change saturation in upward mode.
    LucamSetSaturation(c,currentCam);			% Change saturation.
    pause(nbdelay);					% Give time to eye to see change effect.
end			
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare to change saturation in downward mode.
    LucamSetSaturation(c,currentCam);			% change Saturation.
    pause(nbdelay);					% Give time to eye to see change effect.
end
pause(pbreak);						
LucamSetSaturation(saturationDefault,currentCam);	% Return Saturation setting to initial mode.
LucamCameraClose(currentCam);				% Close session with camera.

