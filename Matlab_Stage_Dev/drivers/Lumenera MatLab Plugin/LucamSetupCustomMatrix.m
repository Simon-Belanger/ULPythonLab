function LucamSetupCustomMatrix(matrix, cameraNum)
% LucamSetupCustomMatrix - Sets up a custom correction matrix.
% Note that to use this function, the property LUCAM_PROP_CORRECTION_MATRIX
% must be set to LUCAM_CM_CUSTOM (LucamSetProperty(0,15,65,cameraNum)).
try
    LuDispatcher(90, cameraNum, matrix);
catch
    errordlg(lasterr, 'Custom Matrix Error', 'modal');
end