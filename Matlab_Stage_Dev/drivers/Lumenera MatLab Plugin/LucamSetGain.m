function LucamSetGain(gain, cameraNum)
% LucamSetGain - Sets the gain value for video mode.
try
    LuDispatcher(28, cameraNum, gain);
catch
    errordlg(lasterr, 'Gain Error', 'modal');
end