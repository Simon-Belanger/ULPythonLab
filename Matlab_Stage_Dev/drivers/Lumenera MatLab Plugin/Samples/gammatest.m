echo on
%**************************************************************************
%      gammatest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Show how to call gamma specific functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamGetGammaRange
% - LucamGetGamma
% - LucamSetGamma
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
currentCam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=50;
LucamCameraOpen(currentCam);				% Open camera to work with.
LucamShowPreview(currentCam);				% Display camera preview.
[cmin,cmax]=LucamGetGammaRange(currentCam)		% Get Gamma Range from camera.
defaultGamma=LucamGetGamma(currentCam)			% Get current Gamma Setting.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare for upward count for gamma change.
   LucamSetGamma(c,currentCam);				% Set gamma.
    pause(nbdelay);					% Give chance to see gamma change.
end
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare for downward count gamme change.
    LucamSetGamma(c,currentCam);			% Set gamma.
    pause(nbdelay);					% Give chance to see gamma change.
end
LucamSetGamma(defaultGamma,currentCam);			% Return gamma setting to initial state.
LucamCameraClose(currentCam);				% Close Camera that we worked with.
