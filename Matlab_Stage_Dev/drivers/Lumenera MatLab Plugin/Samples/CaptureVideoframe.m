echo on
%**************************************************************************
%       CaptureVideoframe.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test all different methode to capture Video frame.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamCaptureFrame
% - LucamCaptureMonoChromeFrame
% - LucamCaptureMultipleFrame
% - LucamCaptureRawFrame
% - LucamCaptureSaveFrame
% - LucamCameraClose
% - LucamTakeVideo
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;						% Delay use in iteration changes.
cint=25;						% Nb of iteration of test.
LucamCameraOpen(cam);					% Open Camera to work with.
LucamShowPreview(cam);					% Display preview of camera.
fr=LucamCaptureFrame(cam);				% capture video frame.
figure('Name','LucamCaptureFrame test');		% Prepare a display window.
image(fr);						% Display captured frame in window.
fr=LucamCaptureMonochromeFrame(cam);			% Capture monochrome Frame.
figure('Name','LucamCaptureMonochromeFrame test');	% Prepare display window
imagesc(fr, [0,255]); colormap(gray); 			% display 8 bit monochrome image.
fr = LucamCaptureMultipleFrames(4, cam);		% Capture multiple video frame.
figure('Name','LucamCaptureMultipleFrame Test');	% Prepare display windows
imaqmontage(fr);					% Display Captured frames in window	
%or indivframe = frameMultiple(:,:,1); than image(indivframe);
fr = LucamCaptureRawFrame(cam);				% Capture RAW video frame.
figure('Name','LucamCaptureRawFrame test');		% Prepare Display window.
imagesc(fr,[0,255]);					% Display Capture RAW frames in window.	
LucamCaptureSaveFrame('rawfr1.bmp',false,cam);
fr=LucamTakeVideo(6,cam);				% Capture multiple video frame.
figure('Name','LucamTakeVideo test');			% Prepare Display window.
imaqmontage(fr);					% Display captured videoframe in window.
LucamCameraClose(cam);					% Close camera.

