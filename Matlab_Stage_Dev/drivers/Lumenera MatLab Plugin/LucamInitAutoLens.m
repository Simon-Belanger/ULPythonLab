function LucamInitAutoLens(force, cameraNum)
% LucamInitAutoLens - Initializes the lens controler on large format cameras.
try
    LuDispatcher(69, cameraNum, force);
catch
    errordlg(lasterr, 'Initialize Auto-Lens Error', 'modal');
end