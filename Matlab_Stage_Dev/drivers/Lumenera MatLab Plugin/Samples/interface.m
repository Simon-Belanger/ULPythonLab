echo on
%**************************************************************************
%      interface.m
%      =====================
%
% Descrition:  
%   Show how to call interface functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamQueryExternInterface
% - LucamSelectExternInterface
% - LucamCameraClose
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
LucamCameraOpen(cam);					% Select camera to work with.
sInt=LucamQueryExternInterface(cam)			% Display camera interface.
LucamSelectExternInterface(1);				% try to select interface USB 1.
LucamQueryExternInterface(cam)				% Display camera interface.
LucamSelectExternInterface(2);			% return to first interface.
LucamCameraClose(cam);					% Close working camera.


