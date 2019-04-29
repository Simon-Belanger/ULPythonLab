echo on
%**************************************************************************
%       16bit.m 
%      =============================
%
% Descrition:  Test Lumenera API functions specific to 16 bits pictures
%   operation.
%
% API functions used:
%  - LucamCameraOpen
%  - LucamIs16BitCapture
%  - LucamSet16BitCapture
%  - LucamShowPreview
%  - LucamCaptureFrame
%  - LucamHidepreview
%  - LucamTakeSnapshot
%  - LucamSet16BitSnapshot
%  - LucamIs16BitSnapshot
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
LucamCameraOpen(1);                         % Open Camera to work with.
LucamIs16BitCapture(1)                      % Read if in 16 bit video capture
LucamSet16BitCapture(false,1);              % Set Camera in 8 bit mode
LucamshowPreview(1);                        % Display Video Preview.
p=LucamCaptureFrame(1);  	            % Take video frame.
LucamHidePreview(1);                        % Hide video Preview.
figure('Name','8 bit video frame');         % Setup Display window.
image(p);                             	    % Display image.
LucamSet16BitCapture(true,1);               % Set Camera in 16 bit video capture mode.
LucamIs16BitCapture(1)                      % Read, and confirm in 16 bit video capture mode.
LucamshowPreview(1);                        % Display Video Preview.
p=LucamCaptureFrame(1);                     % Take video frame.
LucamHidePreview(1);                        % Hide video Preview.
figure('Name','16 bit video frame');        % Setup an image windows.
image(p);                                   % Display the picture in the windows
LucamSet16BitCapture(false,1);              % Return Camera in 8 bit video capture mode.
LucamIs16BitCapture(1)                      % Display current depth of video capture mode.
sn=LucamIs16BitSnapshot(1)                  % Display current snapshot mode.
LucamSet16BitSnapshot(false,1);             % make sure in 8 bit mode.
p=LucamTakeSnapshot(1);                     % Take 8 bit snapshot.
figure('Name','8 bits Snapshot frame');     % Setup image window.
image(p);                                   % Display image.
LucamSet16BitSnapshot(true,1);              % Set Camera in 16 bits snapshot mode.
sn=LucamIs16BitSnapshot(1)                  % Display current mode.
p=LucamTakeSnapshot(1);                     % Take 16 bit snapshot.
si16=figure('Name','16 bits Snapshot frame'); % Setup image window.
image(p);                                   % Display image.
LucamSet16BitSnapshot(false,1);             % Set Camera in 8 bits snapshot mode.
sn=LucamIs16BitSnapshot(1)                  % Display current mode.
LucamCameraClose(1);                        % Close camera that we work with.
