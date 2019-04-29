echo on
%**************************************************************************
%       auto.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test Moto Lens on supported camera. 
%
% API functions used:
%  - LucamCameraOpen
%  - LucamShowPreview
%  - LucamInitAutoLens
%  - LucamGetFrameSize
%  - LucamAutoFocusStart
%  - LucamAutoFocusQueryProgress
%  - LucamAutoFocusStop
%  - LucamAutoFocusWait
%  - LucamOneShotAutoExposure
%  - LucamOneshotAutoIris
%  - LucamOnshotAutoWhiteBalance
%  - LucamOnshotAutoWhiteBalanceEx
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%
%**************************************************************************
echo off
cam=1;					% Camera to work with.
pbreak=1;				% Delay in tests.
LucamCameraOpen(cam);			% Open Camera to work with.
LucamShowPreview(cam);			% Display Camera Preview.
LucamInitAutoLens(true, cam);		% Initialise camera lens.
pause(pbreak);				% Give time to lens todo first initialisation.
[lw,lh]=LucamGetFrameSize(cam);		% Read current Frame size.
LucamAutoFocusStart(lh,lw,0,0,cam);	% Start focus.
for i=0:1:3				% Wait before asking again
    pause(10);
    pDone=LucamAutoFocusQueryProgress(cam)	% return percent completed.
   			
end
LucamAutoFocusStop(cam);		% Make sure Auto Focusing is stopped.
LucamAutoFocusStart(lh,lw,0,0,cam);	% Start focus.
LucamAutoFocusWait(5,cam);		% wait for for AutoFocus to complete of timeout.
pwait=LucamAutoFocusQueryProgress(cam)  % Read percent completed.
LucamAutoFocusStop(cam);		% Make sure Auto Focusing is stopped.
LucamAutoFocusStart(lh,lw,0,0,cam);	% Start focus.
%LucamAutoFocusWait(1000000,cam);		% wait for for AutoFocus to complete of timeout.
%pwait=LucamAutoFocusQueryProgress(cam)  % Read percent completed.
LucamAutoFocusStop(cam);		% Make sure Auto Focusing is stopped.
LucamCameraReset(cam);
LucamOneShotAutoExposure(lh,lw,0,0,100,cam); % Try to do an auto exposure with a target brigthness[0:255]=100.
pause(pbreak);
LucamCameraReset(cam);
LucamOneShotAutoIris(lh,lw,0,0,100,cam); % Perform Auto Iris calculation with a target brigthness = 100.
pause(pbreak);
LucamCameraReset(cam);
LucamOneShotAutoWhiteBalance(lh,lw,0,0,cam); % Perform WB calculation.
pause(pbreak);
LucamOneshotAutoWhiteBalanceEx(lh,lw,0,0,(219/229),(249/229),cam); % Perform a Target WB calculation.
LucamCameraClose(cam);
 