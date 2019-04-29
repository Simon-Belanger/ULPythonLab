function coarse_align(obj)

waitbar_handle = waitbar(0,'Coarse Align');

running_timers = timerfindall('Running', 'on');
[numOfTimers n] = size(running_timers);
for ii=1:numOfTimers
   stop(running_timers(ii)); 
end

gc=0; % no grating coupler found

%Save the intial value : revert back at the end. 
initial_vel = obj.instr.opticalStage.getParam('Velocity'); % for resetting to initial value
initial_accel = obj.instr.opticalStage.getParam('Acceleration'); % for resetting to initial value

%DEBUG: Settings function to set those values
width_x = obj.AppSettings.CAParams.width_x;
width_y = obj.AppSettings.CAParams.width_y;
delta_x = obj.AppSettings.CAParams.step_x;
delta_y = obj.AppSettings.CAParams.step_y;


obj.instr.opticalStage.setParam('Velocity', obj.AppSettings.CAParams.Velocity);
obj.instr.opticalStage.setParam('Acceleration', obj.AppSettings.CAParams.Acceleration);
% but for now:
%obj.instr.opticalStage.setVelocity(obj.AppSettings.CAParams.Velocity);
%obj.instr.opticalStage.setAcceleration(obj.AppSettings.CAParams.Acceleration);

%Prepare detector
%obj.instr.detector.setPWMPowerUnit(0,obj.AppSettings.CAParams.PWMSlot, obj.AppSettings.CAParams.PWMChannel);
obj.instr.detector.switchDetector(obj.AppSettings.CAParams.Detector);
if ~(obj.instr.detector.getParam('PowerUnit'))
    obj.instr.detector.setParam('PowerUnit',0);
end
obj.instr.detector.setParam('RangeMode',0);
obj.instr.detector.setParam('AveragingTime',obj.AppSettings.CAParams.AvgTime);
obj.instr.detector.setParam('PowerRange',obj.AppSettings.CAParams.PowerRange);
obj.instr.detector.setParam('PWMWvl',obj.AppSettings.CAParams.Wvl);
%obj.instr.detector.setPWMPowerRange(obj.AppSettings.CAParams.Detector, 0, obj.AppSettings.CAParams.PowerRange);
%obj.instr.detector.setPWMWvl(obj.AppSettings.CAParams.Wvl,obj.AppSettings.CAParams.Detector);
obj.instr.detector.setup_trigger(2,0, obj.AppSettings.CAParams.Detector); 



%Prepare laser
obj.instr.laser.setParam('Wavelength',obj.AppSettings.CAParams.Wvl);
obj.instr.laser.setParam('PowerUnit',0);  %this won't probably work yet.
obj.instr.laser.setParam('PowerLevel',obj.AppSettings.CAParams.Power);
obj.instr.laser.setParam('LowSSE',obj.AppSettings.CAParams.LowSSE);
% for n7744 detectors
if strcmp(obj.instr.detector.Name, 'Agilent Detector N7744A')
    % set the laser trigger to pass-thru
    obj.instr.laser.setTriggerPassThru(); % will print debug to console
end
%Switch laser on
obj.instr.laser.on();

%Define scan window:
scan_line_length = width_y - 2*obj.instr.opticalStage.getProp('Overshoot');
%this calculation is for debug purposes
obj.AppSettings.CAParams.DataPoints = ...
    ceil(scan_line_length/1000/obj.AppSettings.CAParams.Velocity/obj.AppSettings.CAParams.AvgTime);
obj.instr.detector.setProp('DataPoints', obj.AppSettings.CAParams.DataPoints);
num_scans = ceil(width_x/delta_x);
%Init output vector
pwr = zeros(1,obj.AppSettings.CAParams.DataPoints);

%Get init position
[init_x, init_y, init_z] = obj.instr.opticalStage.getPosition();
%position_str = strcat(['Init motor pos: ',num2str(init_x),' y= ',num2str(init_y),' z= ',num2str(init_z)]);
%disp(position_str);
%DEBUG: make the offset a variable (instead of width_x/2)
obj.instr.opticalStage.move_x(1*width_x/2);
obj.instr.opticalStage.move_y(-1*width_y/2);



%DEBUG:
%disp(['Data points: ' num2str(obj.instr.detector.getProp('DataPoints'))]);
[cur_x, cur_y, cur_z] = obj.instr.opticalStage.getPosition();
%disp(['start motor pos: x=' num2str(cur_x) ' y= ' num2str(cur_y) ' z= ' num2str(cur_z)]);
left_trigger = cur_y + obj.instr.opticalStage.getProp('Overshoot');
%disp(['left trigger: ' num2str(left_trigger)]);
right_trigger = cur_y + obj.instr.opticalStage.getProp('Overshoot') + scan_line_length;
%disp(['right trigger: ' num2str(right_trigger)]);


current_pos_x = 0;
while current_pos_x <= width_x
    %check Abort button
    if (get(obj.gui.map_gc_abort_button, 'UserData'))
        obj.msg('Abort mapping...');
    end
    %Arm the detector trigger
    EstimatedTimeout = obj.instr.detector.start_pwm_logging(obj.AppSettings.CAParams.Detector);
    try
        obj.instr.opticalStage.triggered_move_y('right', width_y,left_trigger);
    catch ME
        rethrow(ME)
    end
    
    try
        [LoggingStatus, pwr(end+1,:)]=obj.instr.detector.get_pwm_logging(obj.AppSettings.CAParams.Detector);
    catch ME
        error_message=cellstr(ME.message);
        error_val=length(error_message);
        if error_val
            for kk=1:error_val
                obj.msg(['     ' error_message{kk}]);
            end
        end
    end
    
%     %Plot for debug reasons
%     cla(axes_y, 'reset');
%     axes(axes_y)
%     plot(pwr(end,:));
    
    current_pos_x = current_pos_x + delta_x;
    percent_finished = current_pos_x/width_x;
    waitbar(percent_finished, waitbar_handle);
    [pmax, pind] = max(pwr(end,:));
    if pmax>obj.AppSettings.CAParams.Threshold
        obj.instr.opticalStage.move_y(-width_y);
        obj.instr.opticalStage.move_x(-delta_x);
        gc=1; %set flag
        break;
    end
        
    %move back and down
    obj.instr.opticalStage.move_y(-width_y);
    obj.instr.opticalStage.move_x(-delta_x);
end

%stop trigger and disable trigger.
try
    obj.instr.detector.pwm_func_stop(obj.AppSettings.CAParams.Detector);
catch ME
    rethrow(ME);
end
obj.instr.detector.setup_trigger(0,0, obj.AppSettings.CAParams.Detector); %Disable trigger

if gc==1
    obj.msg('Found grating coupler');
    Ny=ceil(obj.AppSettings.CAParams.line/delta_y);
    yy = obj.AppSettings.CAParams.AvgTime*1e3*obj.AppSettings.CAParams.Velocity*pind(1) + obj.instr.opticalStage.getProp('Overshoot') - obj.AppSettings.CAParams.line/2 %move into proximity of
    obj.instr.opticalStage.move_y(yy);
    pwr = [];
    for ii=1:1:Ny
        try
            pwr(ii) = obj.instr.detector.readPower(obj.AppSettings.CAParams.Detector);
        catch ME
            rethrow(ME);
        end
        obj.instr.opticalStage.move_y(delta_y);
        pause(0.05);
        
    end
    [pmax, pind] = max(pwr);
    obj.instr.opticalStage.move_y(-(Ny-pind(1)+1)*delta_y);
else
   obj.msg('No grating coupler found'); 
   %move back to init position;
    obj.instr.opticalStage.move_x(1*width_x/2); %this needs to be changed as well to paramters. 
    obj.instr.opticalStage.move_y(1*width_y/2);
end

    delete(waitbar_handle);
  
    
    %obj.instr.laser.off();
    %need to chagne params back to init values.
    [numOfTimers n] = size(running_timers);
    for ii=1:numOfTimers
        start(running_timers(ii));
    end
end

