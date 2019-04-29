echo on
%**************************************************************************
%      exposureTest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Show how to call exposure specific function.
%
% API functions used:
% - LucamGetExposureRange
% - LucamGetExposure
% - LucamSetExporure
% - LucamCameraOpen
% - LucamShowPreview
% - LucamCameraClose
% - LucamHidePreview
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
cint=100;
LucamCameraOpen(cam);				% Open Camera to work with.
LucamShowPreview(cam);				% Display preview
cmin=0;							
cmax=100;
[cmin,cmax]=LucamGetExposureRange(cam)		% Get Exposure range from camera.
defaultExposure=LucamGetExposure(cam)		% Get current exposure.
for c=cmin:((cmax-cmin)/cint):cmax		% Prepare for upward count exposure change.
    LucamSetExposure(c,cam);			% Set exposure
    pause(nbdelay);				% Give time to see exposure change.
end
for c=cmax:((cmin-cmax)/cint):cmin		% Prepare for downward count exposure change.
    LucamSetExposure(c,cam);			% Set exposure.
    pause(nbdelay);				% Give time to see exposure change.
end
LucamSetExposure(defaultExposure,cam);       	% Return Exposure value to where is was before test.
LucamHidePreview(cam);				% Hide preview.
LucamCameraClose(cam);				% Close camera that we work with.

