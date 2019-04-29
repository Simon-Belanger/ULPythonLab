echo on
%**************************************************************************
%      snapinit.m
%      =====================
%
% Descrition:  
%   Show how to change setting for taking a snapshot.
%
% API functions used:
% - LucamCameraOpen
% - lucamGetSnapshotColorGain
% - LucamSetSnapshotColorGain
% - LucamTakeSnapshot
% - LucamSetSnapshotExposure
% - LucamGetProperty
% - LucamSetSnapshotGain
% - LucamAdjustWhiteBalanceFromSnapshot
% - LucamGetStillImageFormat
% - LucamIsUsingHwTrigger
% - LucamSetUseHwTrigger
% - LucamIsUsingStrobe
% - LucamSetUseStrobe
% - LucamSetsTrobeDelay
% - LucamGetStrobeDelay
% - LucamSetTimeouts
% - LucamSetSnapshotShutterType
% - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%  - This script should be use before using takeSnap.m script.
%
%**************************************************************************
echo off
currentCam=1;						% Camera NB to work with.
pbreak=1;						% Delay use in between test or give a chance to see result on preview.
nbdelay=0.05;						% Delay use in iteration changes.
cint=50;

LucamCameraOpen(currentCam);				% Open session with camera.
							% Get current color gain setting from camera.
[red, green1, green2, blue]=LucamGetSnapshotColorGain(currentCam)
LucamSetSnapshotColorGain(2,2,2,2,currentCam);		% Set new color gain to apply on camera.
							% Get color gain from camera to make sure gain change.
[red, green1, green2, blue]=LucamGetSnapshotColorGain(currentCam)
LucamSetSnapshotColorGain(1,1,1,1,currentCam);		% Set new color gain to apply on camera.
							% Get color gain from camera to make sure gain change.
[red, green1, green2, blue]=LucamGetSnapshotColorGain(currentCam)
sn=LucamTakeSnapshot(currentCam);			% Take a snapshot for comparaison.
figure('Name','LucamSetSnapshotExposure =current ');	% Prepare an image window.
image(sn);						% Display picture in image window
LucamSetSnapshotExposure(10,currentCam);		% Set Exposure to 10ms.
figure('Name','LucamSetSnapshotExposure =10 ');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% take current snapshop.
image(sn);						% Display picture in image window.
LucamSetSnapshotExposure(20,currentCam);		% Set exposure to 20ms.
figure('Name','LucamSetSnapshotExposure =20 ');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% take current snapshot.
image(sn);						% display snapshot picture in window.
LucamSetSnapshotExposure(30,currentCam);		% Set exposure to 30ms.
figure('Name','LucamSetSnapshotExposure =30 ');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% Take current snapshot.
image(sn);						% Display snapshot picutre in window.
LucamSetSnapshotExposure(40,currentCam);		% Set exporure to 40 ms.
figure('Name','LucamSetSnapshotExposure =40 ');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% Take current snapshot.
image(sn);						% Display snapshot picture in window.
LucamSetSnapshotExposure(50,currentCam);		% Set exposure to 50 ms.
figure('Name','LucamSetSnapshotExposure =50 ');		% Prepare an image window. 
sn=LucamTakeSnapshot(currentCam);			% Take current snapshop.
image(sn);						% Display snapshot picture in window
							% Return exposure to acceptable value.
LucamSetSnapshotExposure((LucamGetProperty(20,currentCam)),currentCam);

LucamSetSnapshotGain(1,currentCam);			% Set gain to normal.
figure('Name','LucamSetSnapshotGain=1');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% take snapshot.
image(sn)						% Display snapshot picutre in image window.
LucamSetSnapshotGain(2,currentCam);			% Increase gain to 2.
figure('Name','LucamSetSnapshotGain=2');		% Prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% Take snapshot.
image(sn)						% Display snapshot picture in image window.
LucamSetSnapshotGain(3,currentCam);			% Increase gain to 3
figure('Name','LucamSetSnapshotGain=3');		% prepare an image window.
sn=LucamTakeSnapshot(currentCam);			% Take snapshot.
image(sn)						% Display snapshot picture in image window.
LucamSetSnapshotGain(1,currentCam);			% Return gain to normal.
LucamCameraReset(currentCam);				% Return camera to hardware default value.
ff=LucamGetFormat(currentCam) 				% Get current image format.
							% Do a full frame white balance.
LucamAdjustWhiteBalanceFromSnapshot(1, 1, 0, 0, ff.width,ff.height,currentCam);
figure('Name','LucamAdjustWhiteBalanceFromSnapshot');	% Prepare an Image window.
sn=LucamTakeSnapshot(currentCam);			% Take a snapshot.
image(sn)						% Display snapshot picture in image window.
stillImageFormat=LucamGetStillImageFormat(currentCam)   %get current Still Image Format.
triggerCurrent=LucamIsUsingHwTrigger(currentCam) 	% Read current state of the HW trigger.
LucamSetUseHwTrigger(true, currentCam);			% Set HW Trigger
trigger=LucamIsUsingHwTrigger(currentCam)		% read HW Trigger
LucamSetUseHwTrigger(false, currentCam);		% Set Hw Trigger
trigger=LucamIsUsingHwTrigger(currentCam)		% Read HW Trigger
LucamSetUseHwTrigger(triggerCurrent, currentCam);	% Return Trigger to original state.
strobeCurrent=LucamIsUsingStrobe(currentCam)		% Read if Strobe use flag is active.
LucamSetUseStrobe(true,currentCam);			% Activate strobe flag.
strobe=LucamIsUsingStrobe(currentCam)			% Read strobe to make sure activation worked.
LucamSetUseStrobe(false,currentCam);			% Deactivate strobe flag.
strobe=LucamIsUsingStrobe(currentCam)			% Read strobe to make sure deactivation worked.
LucamSetUseStrobe(strobeCurrent,currentCam);		% Return Stobe to inital value.
sDelayOld=LucamGetStrobeDelay(currentCam)		% Read Strobe delay setting.
LucamSetStrobeDelay(sDelayOld+10,currentCam);		% Set new Strobe delay.
sDelayNew=LucamGetStrobeDelay(currentCam)		% Read new Strobe delay setting 
LucamSetStrobeDelay(sDelayOld,currentCam);		% Return strobe dealy to initial value.
LucamSetTimeout(3000, true, currentCam)			% Set a snapshot timeout value.
LucamSetSnapshotShuttertype(currentCam,0); 		% set camera in Global shuttertype.
LucamSetSnapshotShuttertype(currentCam,1); 		% set camera in Rolling shuttertype mode.
LucamSetSnapshotShuttertype(currentCam,0);		% Return camera in Global shuttetype mode.
LucamCameraClose(currentCam);				% Close camera session.

