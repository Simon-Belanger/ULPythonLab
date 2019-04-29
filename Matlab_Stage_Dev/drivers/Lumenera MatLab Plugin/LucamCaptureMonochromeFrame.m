function [frame] = LucamCaptureMonochromeFrame(cameraNum)
% LucamCaptureFrame - Captures a single monochrome video frame.
% To display monochrome image in matlab:
% 8-bit:  imagesc(frame, [0,255]); colormap(gray);
% 16-bit: imagesc(frame, [0,65536]); colormap(gray);
try
    frame = LuDispatcher(75, cameraNum);
catch
    errordlg(lasterr, 'Monochrome Frame Capture Error', 'modal');
end