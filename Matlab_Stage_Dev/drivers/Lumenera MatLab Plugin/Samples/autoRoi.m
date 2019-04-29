echo on
%**************************************************************************
%       autoRoi.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Perform auto Roi operation on LW23X camera. 
%
% API functions used:
%  - LucamCameraOpen
%  - LucamShowPreview
%  - LucamGetFrameSize
%  - LucamAutoRoiGet
%  - LucamAutoRoiSet
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
cam=1;					% Camera to work with.
pbreak=1;				% Delay in tests.
LucamCameraOpen(cam);			% Open Camera to work with.
LucamShowPreview(cam);			% Display Camera Preview.
[lw,lh]=LucamGetFrameSize(cam);		% Read current Frame size.
[dx,dt,dw,dh]=LucamAutoRoiGet(cam)	% Get current auto Roi on camera.	
LucamAutoRoiSet(100,200,320,240,cam);	% Set auto ROI on camere.
[ax,at,aw,ah]=LucamAutoRoiGet(cam)	% Get Current Auto Roi on Camera.
LucamAutoRoiSet(dx,dt,dw,dh,cam);	% Return auto ROI on default value.
[ax,at,aw,ah]=LucamAutoRoiGet(cam)	% Get Current Auto Roi on Camera.
LucamCameraClose(cam);
 