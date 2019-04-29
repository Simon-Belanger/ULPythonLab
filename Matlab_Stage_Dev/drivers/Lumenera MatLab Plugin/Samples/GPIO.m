echo on
%**************************************************************************
%       gpio.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  Test Lumenera APi Function for GPIO control

% API functions used:
%  - LucamCameraOpen
%  - LucamGpioConfigure
%  - LucamGpoSelect
%  - LucamGPioWrite
%  - LucamGpioRead
%  - LucamCameraClose
%  
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - 2 Camera  an a null modem cable is required for this test
%**************************************************************************
echo off
cam=1;				% Camera NB to work with.
cams=2;
pbreak=1;			% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;			% Delay use in iteration changes.
cint=25;			% Nb of iteration of test.
LucamCameraOpen(cam);           % Open Camera to work with
LucamCameraOpen(cams);		% Open second camera to work with.
LucamGpioConfigure(15,cam);	% Put first camera GPO in extended output mode
LucamGpoSelect(cam,15);		% Put first GPO pin in manual toggle mode
LucamGpioConfigure(15,cams);	% Put Second camera GPO in extended output mode
LucamGpoSelect(cams,15);	% Put second GPO pin in manual toggle mode
LucamGPioWrite(cam,6);		% Write 5 on first cam.
LucamGPioWrite(cams,11);	% write A on second cam.
LucamGpioRead(cams)		% Read second cam.
LucamGpioRead(cam)		% Read first cam
LucamGpioConfigure(0,cam);	% Put first camera GPO in Normaloutput mode
LucamGpioConfigure(0,cams);	% Put Second camera GPO in normal output mode
LucamCameraClose(cam);          % Disconnect the working camera.
LucamCameraClose(cams);		% Disconnect second camera.
	
