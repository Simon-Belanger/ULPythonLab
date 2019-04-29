function LucamSetGamma(gamma, cameraNum)
% LucamSetGamma - Sets the gamma value.
try
    LuDispatcher(42, cameraNum, gamma);
catch
    errordlg(lasterr, 'Gamma Error', 'modal');
end