function [depth] = LucamGetTruePixelDepth(cameraNum)
% LucamGetTruePixelDepth - Returns the true pixel depth that is used in 16-bit images.
try
    depth = LuDispatcher(60, cameraNum);
catch
    errordlg(lasterr, 'Pixel Depth Error', 'modal');
end