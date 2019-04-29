function [wvlData, pwrData] = sweep(obj)
% Stiching functionality need to be added --- Vince 2013
waitbar_handle = waitbar(0.1,'Wavelength Sweep');

active_timers = obj.manageTimer('pause');

stitchNum = obj.AppSettings.SweepParams.StitchNum; % get # of stitches specified by user through GUI
startWvl_init = obj.AppSettings.SweepParams.StartWvl;
stopWvl_init = obj.AppSettings.SweepParams.StopWvl;
stepWvl = obj.AppSettings.SweepParams.StepWvl;
% set sweep properties valid for all segments
%Laser
obj.instr.laser.setProp('NumberOfScans', obj.AppSettings.SweepParams.NumberOfScans);
obj.instr.laser.setProp('SweepSpeed', obj.AppSettings.SweepParams.SweepSpeed);
obj.instr.laser.setProp('StepWvl', obj.AppSettings.SweepParams.StepWvl);
obj.instr.laser.setParam('LowSSE', obj.AppSettings.SweepParams.LowSSE);
obj.instr.laser.setParam('PowerUnit', 0 ); %set this to dB without being an option
obj.instr.laser.setParam('PowerLevel', obj.AppSettings.SweepParams.PowerLevel);
%Switch laser on
obj.instr.laser.on();
waitbar(0.2, waitbar_handle);
%Detectors
%obj.instr.detector.setParam('PWMWvl', 1550); %not sure if this is necessary,
obj.instr.detector.setParam('RangeMode', 0); %not sure if necessary; make it auto.
obj.instr.detector.setParam('PowerRange',obj.AppSettings.SweepParams.InitRange);
obj.instr.detector.setProp('Clipping', obj.AppSettings.SweepParams.Clipping);
obj.instr.detector.setProp('ClipLimit', obj.AppSettings.SweepParams.ClipLimit);
obj.instr.detector.setProp('RangeDecrement', obj.AppSettings.SweepParams.RangeDecrement);
waitbar(0.3, waitbar_handle);


% pre allocate memory for data arrays
pwrData = [];
wvlData = [];

% determine sweep range based on total wvl range and number of sweeps
if stitchNum == 0
    points = (stopWvl_init-startWvl_init)/stepWvl;
    if points > obj.instr.detector.getProp('MaxDataPoints')
        ex = MException('Sweep:TooManyPoint','Max points allowd exceeded');
        throw(ex);
    end
    startWvl = startWvl_init;
    stopWvl = stopWvl_init;
    wvlRange = 0;
elseif stitchNum > 0
    wvlRange = (stopWvl_init - startWvl_init)/(stitchNum+1);
    startWvl = startWvl_init;
    stopWvl = startWvl + wvlRange;
    if points > obj.instr.detector.getProp('MaxDataPoints')
        ex = MException('Sweep:TooManyPoint','Max points allowd exceeded');
        throw(ex);
    end
end
% use for loop to set each section of the sweep range sequentially
for kk = 1:(stitchNum+1)
    waitbar(0.2+kk/(stitchNum+1)/10*0.6, waitbar_handle);
    % set the wvl range of the section in the laser object
    obj.instr.laser.setProp('StartWvl',startWvl);
    obj.instr.laser.setProp('StopWvl',stopWvl);
    % setupSweep uses the wvl range stored in the laser object
    obj.msg('Setup Sweep.');
    [dataPoints, ~] = obj.instr.laser.setupSweep();
    obj.instr.detector.setupSweep(dataPoints);
    obj.msg('Start Sweep.');
    obj.instr.laser.sweep();
    obj.msg('Finish Sweep.');
    current_length=length(pwrData);
    %read data from detectors.
    [pwr, wvl] = obj.instr.detector.getSweepData();
    pwrData(current_length+1:current_length+length(pwr), :) = pwr;
    wvlData(current_length+1:current_length+length(wvl), :) = wvl;
    
    % increment the wvl range
    startWvl = startWvl + wvlRange + stepWvl; % the +1 is to avoid overlap with endpoint of previous sweep
    stopWvl = startWvl + wvlRange;
end
if stitchNum == 0
    waitbar(0.5, waitbar_handle);
    waitbar(0.7, waitbar_handle);
    waitbar(0.9, waitbar_handle);
end

wvlData = wvlData * 1e9; % Convert into nm and output
obj.instr.laser.off();
obj.instr.detector.setPWMPowerUnit(0);

obj.manageTimer('resume', active_timers);

waitbar(1, waitbar_handle);
delete(waitbar_handle);
save('results/lastSweep.mat','wvlData','pwrData');
end