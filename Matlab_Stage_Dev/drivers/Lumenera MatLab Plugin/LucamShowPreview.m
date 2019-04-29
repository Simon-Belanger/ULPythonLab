function LucamShowPreview(cameraNum)
% LucamShowPreview - Opens a window for video preview.
try
    LuDispatcher(0, cameraNum);
catch
    errordlg(lasterr, 'Preview Error', 'modal');
end