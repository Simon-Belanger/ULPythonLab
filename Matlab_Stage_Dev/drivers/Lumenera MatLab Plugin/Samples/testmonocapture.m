echo on
%**************************************************************************
%       testmanocapture.m 
%      =============================
%
% Descrition:  Test the LucamCaptureMonochromeFrame.  The API
%              function take a Video frame in monochrome.
%
% API functions used:
%   - LucamConnect.
%   - LucamShowPreview.
%   - LucamCaptureMonochromeFrame.
%   - LucamHidePreview.
%   - LucamDisconnect.
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - 2 camera id needed.
%
%**************************************************************************
echo off

LucamConnect(2);                            % Connect to Second Camera.
LucamConnect(1);                            % Connect to first Camera.
LucamShowPreview(1);                        % Show video preview of first Camera.
LucamShowPreview(2);                        % Show video preview of second camera.
pause(2);
imagefr1 = LucamCaptureMonochromeFrame(1);  % Capture monochrome frame from first camera.
imagefr2 = LucamCaptureMonochromeFrame(2);  % Capture monochrome frame from second camera.
LucamHidePreview(1);                        % Hide video previe of first Camera.
LucamHidePreview(2);                        % Hide video preview of second camera.
LucamDisconnect(1);                         % Disconnect first camera.
LucamDisconnect(2);                         % Disconnect second camera.
figure('Name','First camera monochrome frame');
imagesc(imagefr1,[0,255]); colormap(gray);  % display first image in monochrome.
figure('Name','Second camera monochrome frame');
imagesc(imagefr2,[0,255]); colormap(gray);  % Display second image in monochrome.
%imagefrCombined (1) = imagefr1;             % Combine first image to big image.
%imagefrCombined (2) = imagefr2;             % Combine second image to big image.
%imaqmontage(imagefrCombined);               % Display Big image.