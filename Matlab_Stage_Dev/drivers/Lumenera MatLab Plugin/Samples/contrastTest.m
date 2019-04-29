echo on
%**************************************************************************
%      contrastTest.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test contrast specific functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamGetContrastRange
% - LucamPropertyRange
% - LucamGetContrast
% - LucamSetContrast
% - LucamcameraClose
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
cint=100;						% Number of different level of contrast.
LucamCameraOpen(cam);					% Open Camera to work with
LucamShowPreview(cam);					% Display camera preview.
[cmin,cmax]=LucamGetContrastRange(cam)			% Get contrast range for current camera.
[pmin,pmax]=LucamPropertyRange(1,cam)			% Get cotnrast range for current camera with getproperty function.
defaultContrast=LucamGetContrast(cam)			% Get current contrast.
for c=cmin:((cmax-cmin)/cint):cmax			% Prepare for upward contrast level changes.
    LucamSetContrast(c,cam);				% set contrast level.
    pause(nbdelay);					% give camera time to refresh.
end
for c=cmax:((cmin-cmax)/cint):cmin			% Prepare for downward contrast elvel changes.
    LucamSetContrast(c,cam);				% Set contrast level.
    pause(nbdelay);					% Give camera time to refresh.
end

LucamSetContrast(defaultContrast,cam);  		% Return contrast value to where is was before test.
LucamCameraClose(cam);					% Close working camera.
