% Call as such: [xOffset,yOffset] = LucamGetOffset(<cameraNum>);
function [xOffset, yOffset] = LucamGetOffset(cameraNum)
%LucamGetOffset - Returns the current X and Y offset values for the ROI.
try
    offsets = LuDispatcher(8, cameraNum);
catch
    errordlg(lasterr, 'Offset Error', 'modal');
end
xOffset = offsets(1);
yOffset = offsets(2);