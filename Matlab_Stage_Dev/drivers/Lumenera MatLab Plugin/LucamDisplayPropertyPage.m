function LucamDisplayPropertyPage(cameraNum)
% LucamDisplayPropertyPage - Displays the camera's DirectX video properties dialog.
try
    LuDispatcher(5, cameraNum);
catch
    errordlg(lasterr, 'Video Display Error', 'modal');
end