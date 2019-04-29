echo on
%**************************************************************************
%      directx.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Show how to call the directx property window functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamDisplayPropertyPage
% - LucamDisplayVideoFormatPage
% - LucamDisplayVideoProperties
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
% 
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.5;						% Delay use in iteration changes.
cint=100;
LucamCameraOpen(cam);					% Open camera to work with.
LucamShowpreview(cam);					% Display Preview.
LucamDisplayPropertyPage(cam);				% Open Display property window 
LucamDisplayVideoFormatPage(cam);			% Open Video format window
LucamDisplayVideoProperties(cam);			% Open video properties window.
LucamCameraClose(cam);					% Close camere.