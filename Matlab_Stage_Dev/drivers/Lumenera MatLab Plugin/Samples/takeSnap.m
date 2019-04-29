echo on
%**************************************************************************
%       tdisplay.m 
%      =============================
%
% Descrition:  
%	test different snapshot functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamTakeSnapshot
% - LucamTakequickSnapshot
% - LucamTakeFastFrames
% - LucamTakeMultipleSnapshots
% - LucamGetFormat
% - LucamSetFrameSize
% - LucamTakeSynchronousSnapshot
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - 2 cameras is required.
%
%**************************************************************************
echo off
currentCam=1;
secondCam=2;
LucamCameraOpen(currentCam);                                    % Open camera for test.
LucamCameraOpen(secondCam);                                     % Open second camera for the LucamTakeSynchronousSnapshots API Function tests.
sf=LucamTakeSnapshot(currentCam);                            	% Take the first snap shot.
figure('Name','LucamTakeSnapshot test');			% Setup an Image window.
image(sf);		                                        % Display snapshot picture in Image window.
sf=LucamTakeQuickSnapshot(320,240,300,300,40,1,currentCam);  	% Take a Quick snapshot picture
figure('Name','LucamtakeQuickSnapshot test');             	% Seup and Image window.
image(sf);                                                   	% Display the QuickSnapshot picture in Image window.
sf=LucamTakeFastFrames(3,currentCam);                          	% Take fast frames snapshot pictures.
figure('Name','LucamTakeFastFrames test');               	% Setup and Image window.
imaqmontage(sf);                                               	% Display all snapshot taken.
sf=LucamTakeMultipleSnapshots(2,currentCam);                 	% Take Multiple snapshots
figure('Name','LucamTakeMultipleSnapshot test');          	% Setup and Image window.
imaqmontage(sf);                                             	% Display multiple snapshots.
ff2=LucamGetFormat(secondCam);					% Get second camera image format.	
LucamSetFrameSize(ff2.width, ff2.height,currentCam);            % set Image format of working camera and make sure is identical to second camera.
sf=LucamTakeSynchronousSnapshots();                          	% Take synchronous Snapshot from cameras
figure('Name','LucamTakeSynchronousSnapShot test');      	% Prepare an image windows.
imaqmontage(sf);                                             	% Display synch snapshot pictures in image windows.
LucamCameraClose(secondCam);                                    % Close second camera.
LucamCameraClose(currentCam);                                   % Close working camera.





