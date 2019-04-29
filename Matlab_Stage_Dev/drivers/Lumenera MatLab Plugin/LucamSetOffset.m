% xOffset - Ensure that xOffset + frame width is less than the width of the
% camera's sensor, and yOffset + frame height is less than the height of
% the camera's sensor. Otherwise the properties will not be set correctly.
function LucamSetOffset(xOffset, yOffset, cameraNum)
% LucamSetOffset - Sets the X and Y offsets for the ROI.
try
    LuDispatcher(9, cameraNum, xOffset, yOffset);
catch
    errordlg(lasterr, 'Offset Error', 'modal');
end