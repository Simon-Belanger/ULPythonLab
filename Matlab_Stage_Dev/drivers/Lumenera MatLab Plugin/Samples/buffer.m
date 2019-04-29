echo on
%**************************************************************************
%       buffer.m 1.00
%      =============================
% Created: October 5, 2010
% Modified:
%
% Descrition:  Test Lumenera APi Function for the read and write buffer.

% API functions used:
%  - LucamCameraOpen
%  - LucamPermanentBufferRead
%  - LucamPermanentBufferWrite
%  - LucamCameraClose
%
% NOTES:
%  - For more information on a camera command "type commandname".  
%  - Parameter definition can also be found in Lumenera API Manual.
%
%**************************************************************************
echo off
LucamCameraOpen(1);                    % Open Camera to work with.
buf=LucamPermanentBufferRead(512,0,1); % Read 512 byte on the camera buffer
buf=char(buf)			       % Display buffer in Character format.
str='Matlab test  2010';               % Initialise string to write .
LucamPermanentBufferWrite(0,str,1);    % write string to memory.
buf=LucamPermanentBufferRead(512,0,1); % Read 512 byte on the camera memory.
buf=char(buf)			       % Display read buffer in character format.
numa=[10,10, 45, 90]		       % Number to write to camera.
LucamPermanentBufferWrite(0,numa,1);   % write array of number to camera memory.
buf=LucamPermanentBufferRead(512,0,1)  % Read 512 byte on the camera buffer
LucamCameraClose(1);                    % Close Camera that we work with.

