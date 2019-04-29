echo on
%**************************************************************************
%       VideoFlipping
%      =============================
% Created: November 8, 2010
% Modified:
%
% Descrition:  
%   Demonstrate how to flip camera video.
%
% API functions used:
%  - LucamCameraOpen
%  - LucamShowPreview
%  - LucamGetProperty
%  - LucamSetProperty
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - 66 is the flipping property #
%              value of 0 than no video flip.
%              value of 1 than flip video horizontally.
%              value of 2 than flip video vertically.
%              value of 3 than flip video horizontally and vertically.
%
%**************************************************************************
echo off
cam=1;                                                  % Camera NB to work with.
pbreak=5;                                               % Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;                                           % Delay use in iteration changes.
LucamCameraOpen(cam);                                   % Open Camera to work with.
LucamShowPreview(cam);                                  % Display preview of camera.
flipCurrent=LucamGetProperty(66,cam)                    % Read current flip property.

echo on
% Flipping XY
echo off
LucamSetProperty(0,3,66,cam);                           % Set the flip property to flipping XY;
pause(pbreak);                                          % Give time to see flipping.

echo on
% Flipping NONE
echo off
LucamSetProperty(0,0,66,cam);                           % Set the flip property to flipping None;
pause(pbreak);                                          % Give time to see flipping.

echo on
% Flipping X
echo off
LucamSetProperty(0,1,66,cam);                           % Horizontal flip;
pause(pbreak);                                          % Give time to see flipping.

echo on
% Flipping Y
echo off
LucamSetProperty(0,0,66,cam);                           % Flip video vertically.
pause(pbreak);                                          % Give time to see flipping.


LucamSetProperty(0,flipCurrent,66,cam);                 % Return flip property to original state.
LucamCameraClose(cam);                                  % Close working camera.
