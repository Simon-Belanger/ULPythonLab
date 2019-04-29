function [buffer] =  LucamPermanentBufferRead(length, offset, cameraNum)
%LucamPermanentBufferRead - Reads <length> bytes from the buffer.
try
    buffer = LuDispatcher(96, cameraNum, offset, length);
catch
    errordlg(lasterr, 'Buffer Error', 'modal');
end