% filePath – Fully qualified path to where the file should be saved.
% asGreyScale – ‘true’ to save the image as monochrome, ‘false’ for RGB.
% cameraNum – The camera ID of the camera to operate on.
function LucamCaptureSaveFrame(filePath, asGreyScale, cameraNum)
%LucamCaptureSaveFrame - Captures a video frame, then saves it at the fully qualified filePath.
try
    LuDispatcher (77, cameraNum, filePath, asGreyScale);
catch
    errordlg(lasterr, 'Frame Save Error', 'modal');
end

