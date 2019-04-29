function LucamSetStrobeDelay(delay, cameraNum)
% LucamSetStrobeDelay - Sets the length of time to delay the strobe output from the snapshot trigger input.
try
    LuDispatcher(24, cameraNum, delay);
catch
    errordlg(lasterr, 'Strobe Delay Error', 'modal');
end