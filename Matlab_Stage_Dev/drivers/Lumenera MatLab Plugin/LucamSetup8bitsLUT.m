function LucamSetup8bitsLUT (length, lut, cameraNum)
% LucamSetup8bitsLUT - Sets up an 8-bit lookup table, where lut is an array
% of 256 numbers (each one from 0-255). Length of 0 disables it, 256
% enables it.
try
    LuDispatcher(88, cameraNum, lut, length);
catch
    errordlg(lasterr, 'LUT error.', 'modal');
end