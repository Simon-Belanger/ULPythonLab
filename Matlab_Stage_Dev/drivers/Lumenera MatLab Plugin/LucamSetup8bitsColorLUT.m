function LucamSetup8bitsColorLUT (applyOnRed, applyOnGreen1, applyOnGreen2, applyOnBlue, length, lut, cameraNum)
% LucamSetup8bitsLUT - Sets up an 8-bit lookup table, where lut is an array
% of 256 numbers (each one from 0-255). Length of 0 disables it, 256
% enables it. applyOnRed(Green1/Green2/Blue) are all boolean values.
try
    LuDispatcher(89, cameraNum, lut, length, applyOnRed, applyOnGreen1, applyOnGreen2, applyOnBlue);
catch
    errordlg(lasterr, 'LUT error.', 'modal');
end