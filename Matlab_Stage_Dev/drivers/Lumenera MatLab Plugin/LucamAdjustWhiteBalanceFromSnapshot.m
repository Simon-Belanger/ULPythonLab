%redOverGreen: red value of desired color divided by green value.
%blueOverGreen: blue value of desired color divided by green value.
%startX: X-coord of top left corner of window to auto white balance.
%startY: Y-coord of top left corner of window to auto white%balance.
%width:  width of window to color balance.
%height: height of window to color balance.
function LucamAdjustWhiteBalanceFromSnapshot(redOverGreen, blueOverGreen, startX, startY, width, height, cameraNum)
%LucamAdjustWhiteBalanceFromSnapshot - Takes a snapshot using current
%snapshot settings for the given camera, and adjusts it to white balance
%accordingly.
try
    LuDispatcher(82, cameraNum, redOverGreen, blueOverGreen, startX, startY, width, height);
catch
    errordlg(lasterr, 'Error Adjusting White Balance', 'modal');
end