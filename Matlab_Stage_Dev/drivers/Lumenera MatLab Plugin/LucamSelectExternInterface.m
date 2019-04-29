function LucamSelectExternInterface(interface)
% LucamSelectExternInterface - Selects the camera interface to use.
try
    LuDispatcher(100, interface);
catch
    errordlg(lasterr, 'Interface Select Error', 'modal');
end