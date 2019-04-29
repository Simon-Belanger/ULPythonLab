function LucamSetFrameSize(width, height, cameraNum)
% LucamSetFrameSize - Sets the frame width and heigh values for the ROI.
try
    LuDispatcher(2, cameraNum, width, height);
catch
    errordlg(lasterr, 'Frame Size Error', 'modal');
end