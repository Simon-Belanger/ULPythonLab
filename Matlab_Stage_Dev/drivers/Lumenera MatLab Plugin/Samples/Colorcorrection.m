echo on
%**************************************************************************
%       Colorcorrection.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  
%   Test the custom color correction Matrix and also the Lookup table 
%   functions.
%
% API functions used:
% - LucamCameraOpen
% - LucamShowPreview
% - LucamGetCurrentMatrix
% - LucamCaptureFrame
% - LucamSetProperty
% - LucamSetupCustomMatrix
% - LucamSetup8bitsLUT
% - LucamSetup8bitsColorLUT
% - LucamHidePreview
% - LucamCameraReset
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - the LucamSetup8bitsColorLUT is not supported by all camera and might
%    generate an error on execution.  If it is the case put all 4 channels
%    tests in comments.	
%
%**************************************************************************
echo off
cam=1;							% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;						% Delay use in iteration changes.
cint=25;						% Nb of iteration of test.
LucamCameraOpen(cam);					% Open Camera to work with.
LucamShowPreview(cam);					% Display preview of working camera.
pause(1);
currentColorMatrix=LucamGetCurrentMatrix(cam) 		% Get Current Matrix use for coler correction.
testMatrix=currentColorMatrix;				% copy Matrix for later use.
pic=LucamCaptureFrame(cam);				% Capture video frame.
figure('Name','Current correction Matrix');     	% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamSetProperty(0,15,65,cam);				% Tell the Camera to use custom color correction Matrix.
testMatrix(1)=2;					% Setup custom Matrix todo a gain like function.
testMatrix(5)=2;
testMatrix(9)=2;
LucamSetupCustomMatrix(testMatrix,cam);			% Give custom Matrix to camera.
LucamGetCurrentMatrix(cam)				% Read Matrix from camera to make sure write have been successful.
pause(1);
pic=LucamCaptureFrame(cam);				% Capture a frame.
figure('Name','Gain like correction Matrix');   	% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamSetupCustomMatrix(currentColorMatrix,cam);		% Return Matrix to its default format.
LucamSetProperty(0,1,65,cam);				% Tell Camera to use dayligth color correction matrix.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.

			% Initialise a lookup table.
myLut= [255, 254, 253, 252,251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240, 239, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 228, 227, 226, 225, 224, 223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208, 207, 206, 205, 204, 203, 202, 201, 200, 199, 198, 197, 196, 195, 194, 193, 192, 191, 190, 189, 188, 187, 186, 185, 184, 183, 182, 181, 180, 179, 178, 177, 176, 175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162, 161, 160, 159, 158, 157, 156, 155, 154, 153, 152, 151, 150, 149, 148, 147, 146, 145, 144, 143, 142, 141,140, 139, 138, 137, 136, 135, 134, 133, 132, 131, 130, 129, 128, 127, 126, 125, 124, 123, 122, 121, 120,119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45,44, 43, 42, 41,40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0];

LucamSetup8bitsLUT(256,myLut,cam);			% Give LUT to camera and enable it.
LucamShowPreview(cam);					%Display Preview.
pause(3);
pic=LucamCaptureFrame(cam);				% Capture video frame
figure('Name','SINgle LUT');     			% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamSetup8bitsLUT(0,myLut,cam);			% Give LUT to camera and disable it usage.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.
							% Give LUT to work on color channel.


LucamSetup8bitsColorLUT(false,false,false,true,256,myLut,cam);
LucamShowPreview(cam);					%Display Preview.
pause(3);
pic=LucamCaptureFrame(cam);				% Capture video frame.
figure('Name','Color LUT blue channel');     			% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.

LucamSetup8bitsColorLUT(true,false,false,false,256,myLut,cam);
LucamShowPreview(cam);					% Display Preview.
pause(3);
pic=LucamCaptureFrame(cam);				% Capture video frame.
figure('Name','Color LUT Red channel');     			% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.

LucamSetup8bitsColorLUT(false,true,false,false,256,myLut,cam);
LucamShowPreview(cam);					% Display Preview.
pause(3);
pic=LucamCaptureFrame(cam);				% Capture video frame.
figure('Name','Color LUT Green1 channel');     			% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.

LucamSetup8bitsColorLUT(false,false,true,false,256,myLut,cam);
LucamShowPreview(cam);					% Display Preview.
pause(3);
pic=LucamCaptureFrame(cam);				% Capture video frame.
figure('Name','Color LUT Green2 channel');     			% Setup an Image window.
image(pic);                                             % Display snapshot picture in Image window.
LucamHidePreview(cam);					% Stop showing preview.
LucamCameraReset(cam);					% Make sure camera return to default state before LUT operation.

LucamSetup8bitsColorLUT(false,false,false,false,0,myLut,cam);

LucamCameraClose(cam);

