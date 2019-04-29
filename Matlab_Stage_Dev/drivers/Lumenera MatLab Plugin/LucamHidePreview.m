function LucamHidePreview(cameraNum)
% LucamHidePreview - Hides/closes the currently open video preview.
try
    LuDispatcher(1, cameraNum);
catch
    errordlg(lasterr, 'Preview Error', 'modal');
end