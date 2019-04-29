echo on
%**************************************************************************
%       testCapturesaveframe.m 
%      =============================
%
% Descrition:  Test the LucamCaptureSaveFrame API function.  The API
%              function take a Pictures than save it to a file.
%
% API functions used:
%   - LucamConnect.
%   - LucamSetGain.
%   - LucamShowPreview.
%   - LucamCaptureSaveFrame.
%   - LucamHidePreview.
%   - LucamDisconnect.
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
LucamConnect(2);                                                    % Connect to camera #2.
LucamConnect(1);                                                    % Connect to camera #1.
LucamSetGain(5,2);                                                  % Adjust level of gain 
LucamShowPreview(1);                                                % Show the video preview of first Camera.
LucamShowPreview(2);                                                % Show the video preview of second Camera. 
LucamCaptureSaveFrame('rawfr1.bmp',false,1);      		    % Take and save Image of first camera in BMP.
LucamCaptureSaveFrame('rawfr2.bmp',false,2); 			    % Take and save Image of second camera in BMP.
LucamHidePreview(1);                                                % Hide the video preview of first camera.
LucamHidePreview(2);                                                % Hide the video preview of second camera.
LucamDisconnect(1);                                                 % Disconnect from first camera.
LucamDisconnect(2);                                                 % Disconnect from second camera.

