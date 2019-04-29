function assay(obj)
% Shon Schmidt 2013

% Get testPanel index so that sript can acess the GUI components
testPanel = panel_index('test');

% check to see if a recipe file has been loaded
if ~isstruct(obj.recipe)
    obj.msg('Cannot start test. No recipe file loaded. Aborting.')
    % re-enable start button
    set(obj.gui.panel(testPanel).testControlUI.startButton, 'Enable', 'On');
    % Disable pause button and Stop Button
    set(obj.gui.panel(testPanel).testControlUI.pauseButton, 'Enable', 'Off');
    set(obj.gui.panel(testPanel).testControlUI.stopButton, 'Enable', 'Off');
    return
end

%% n7744x support, if n7744x installed fast IL engine selected, start the client
if obj.AppSettings.AssayParams.UseFastILEngine
    % Connect to Engine Manager
    EngineMgr = actxserver('AgServerFSIL.EngineMgr');
    % Create a new engine
    obj.instr.Engine = EngineMgr.NewEngine;
    % Load configuration file
    filePath = strcat(pwd, '\drivers\AgEngineFSIL_test.agconfig');
    obj.instr.Engine.LoadConfiguration(filePath);
    % Activate engine
    obj.instr.Engine.Activate;
end

%% assay setup
% start the test timer
ticID = tic;
% get number of detectors to loop on figure plots
numDetectors = obj.instr.detector.getProp('NumOfDetectors');
selectedDetectors = obj.instr.detector.getProp('SelectedDetectors');
% get list of all chip's devices
deviceNames = fieldnames(obj.devices);
numOfDevices = length(obj.gui.panel(testPanel).assayUI.deviceTable(:, 1));
% flags for button presses in the middle of sweeps/moves/aligns
pauseReq = 0; % flag 0=no, 1=yes
stopReq = 0; % flag 0=no, 1=yes
% set the initial recipe line index
recipeIndex = 1;
% loop through recipe to figure out which reagent (if any) is in the channel
reagentInChannel = 'n/a';
if obj.instr.fluidicStage.isConnected && obj.instr.pump.Busy % is pumping
    % loop through all wells in the recipe file
    for recipeIndex = 1:length(obj.recipe.well)
        if obj.instr.fluidicStage.CurrentWell == obj.recipe.well(recipeIndex)
            reagentInChannel = obj.recipe.reagent(recipeIndex);
        end
    end
end

totalNumberOfSteps = 0;
for ii = 1:length(deviceNames)
    if obj.devices.(deviceNames{ii}).getProp('Selected')
        totalNumberOfSteps = totalNumberOfSteps + 1;
    end
end
totalNumberOfSteps = length(obj.recipe.reagent) * totalNumberOfSteps * obj.AppSettings.dryTest.Iterations;

%% Shon's assay orchestration
obj.msg('<<<<<<<<<<  Start test  >>>>>>>>>>')
% loop through iterations
for iteration = 1:obj.AppSettings.dryTest.Iterations
    % data store path
    generalFilePath = createTempDataPath(obj);
    % create <dateTag> for device directories
    %   format = c:\TestBench\TempData\<chipArch>\<dieNum>\<device>\<testType>\<dateTag>\*
    dateTag = datestr(now,'yyyy.mm.dd@HH.MM'); % time stamp
    % loop through all steps/reagents in the recipe file
    for recipeIndex=1:length(obj.recipe.reagent)
        %% load new reagent
        if obj.AppSettings.AssayParams.SequenceReagentsManually
            message = sprintf('Manually load reagent into channel.\nClick done to continue');
            uiwait(msgbox(message));
            % automated reagent sequencing (requires connected stage and pump)
        elseif obj.instr.pump.isConnected && obj.instr.fluidicStage.isConnected
            % stop the pump if running
            if obj.instr.pump.Busy
                obj.instr.pump.stop;
            end
            % soft stop and relax pressure to avoid air bubbles in line
            if obj.AppSettings.AssayParams.RelaxPressureTime_sec > 0
                msg = strcat('Soft stop to relax tube pressure.',...
                    '\n\tPausing (sec) = ', num2str(obj.AppSettings.AssayParams.RelaxPressureTime_sec));
                obj.msg(msg);
                pause (obj.AppSettings.AssayParams.RelaxPressureTime_sec); % arbitrary
            end
            
            % move to well for new reagent
            obj.instr.fluidicStage.move_to_well(obj.recipe.well(recipeIndex));
            % set pump velocity
            obj.instr.pump.setParam('Velocity',obj.recipe.velocity(recipeIndex));
            
            % prime channel prior to scanning (ie: no real time binding kinetics)
            if obj.AppSettings.AssayParams.PrimeFluidicChannel && obj.instr.pump.isConnected
                % start pump
                obj.instr.pump.start();
                % determine reagent transit time to sensor (1 um^3 = 1e-9 uL)
                inTubeVolume_uL = obj.AppSettings.PumpParams.TubeInLength_mm * 1000 *...
                    3.14 * (obj.AppSettings.PumpParams.TubeInID_um/2)^2 * 1e9;
                reagentTransitTimeToSensor_sec = inTubeVolume_uL/obj.recipe.velocity(recipeIndex);
                % start timer for countdown
                ticInTubeStart = tic;
                elapsedInTubeTempTime = toc(ticInTubeStart);
                while elapsedInTubeTempTime < reagentTransitTimeToSensor_sec
                    msg = strcat('Waiting for reagent to reach sensor.',...
                        '\n\tTravelTime (sec) = ', num2str(reagentTransitTimeToSensor_sec),...
                        '\n\tElapsedTime (sec) = ', num2str(elapsedInTubeTempTime));
                    obj.msg(msg);
                    elapsedInTubeTempTime = toc(ticInTubeStart);
                    pause (5); % arbitrary
                end
            end
        else % assume this is a temperature variation test
            obj.msg('Pump or fluidic stage not connected. Skipping reagent sequencing.');
        end % new reagent
        
        %% thermally tune the chip stage
        if obj.AppSettings.AssayParams.WaitForTempStabilization && obj.instr.thermalControl.isConnected
            % start timer for timeout
            ticTempStart = tic;
            % add 2 digits (for xx) to precision parameter since we read xx.yyy
            precision = obj.AppSettings.AssayParams.TempComparisonPrecision + 2;
            elapsedTempTime = toc(ticTempStart);
            % read temp and apply precision
            targetTemp = double(vpa(obj.recipe.temp(recipeIndex), precision));
            TECTemp = obj.instr.thermalControl.CurrentTemp;
            currentTemp = double(vpa(TECTemp, precision));
            
            % wait until temp is reached or timeout occurs
            while (elapsedTempTime/60 < obj.AppSettings.AssayParams.WaitForTempTimeout_min) && ...
                    (currentTemp ~= targetTemp)
                pause(5); % this is arbitrary
                % read temp and apply precision
                TECTemp = obj.instr.thermalControl.CurrentTemp;
                currentTemp = double(vpa(TECTemp, precision));
                msg = strcat('Waiting for temperature to stabilize.',...
                    sprintf('\n\tCurrentTemp (C) = %s', num2str(currentTemp)),...
                    sprintf('\n\tTargetTemp (C) = %s', num2str(targetTemp)),...
                    sprintf('\n\tElapsedTime (min) = %s', num2str(elapsedTempTime/60)));
                obj.msg(msg);
                elapsedTempTime = toc(ticTempStart);
            end
            
            % error handling and user message
            if (elapsedTempTime/60 >= obj.AppSettings.AssayParams.WaitForTempTimeout_min) || ...
                    (currentTemp ~= targetTemp)
                % pop-up window for user
                % shons note: need to add stop functionality to this
                message = sprintf('Target temperature not reached.\nDo you want to continue?');
                response = questdlg(...
                    message, ...
                    'ERROR', ...
                    'Yes', 'No', 'Yes');
                if clstrcmp(response, 'No')
                    return;
                end
            else
                msg = strcat(...
                    sprintf('Temperature reached.\n\tCurrentTemp = %s', num2str(currentTemp)),...
                    sprintf('\n\tTargetTemp = %s', num2str(targetTemp)),...
                    sprintf('\n\tElapsedTime = %s', num2str(elapsedTempTime/60)));
                obj.msg(msg);
            end
        else
            obj.msg('TEC not connected. Skipping thermal tuning.');
        end % thermal tuning and temp stabilization
        
        %% loop through selected devices
        % create index for selected devices
        selectedDeviceIndex = 0;
        for k = 1:length(deviceNames)
            if obj.devices.(deviceNames{k}).getProp('Selected')
                
                %% update status
                selectedDeviceIndex = selectedDeviceIndex + 1; % index to status table
                msg = strcat(num2str((recipeIndex-1)*numOfDevices + selectedDeviceIndex), ...
                    '/', ...
                    num2str(totalNumberOfSteps));
                set(obj.gui.panel(testPanel).testControlUI.progressDisplay, 'String', msg)
                
                %% move to next device
                targetDevice = obj.devices.(deviceNames{k});
                set(obj.gui.panel(testPanel).testControlUI.currentDeviceDisplay, 'String', obj.devices.(deviceNames{k}).Name);
                if obj.instr.opticalStage.coordSysIsValid
                    obj.instr.opticalStage.moveTo(targetDevice.X,targetDevice.Y);
                else % no coordinate system, do relative move
                    currentDevice = obj.devices.(obj.chip.CurrentLocation);
                    moveToDevice(obj, currentDevice, targetDevice);  %scripted move function
                end
                
                %% fine align
                fine_align(obj);
                
                %% sweep (loop based on recipe time or number of iterations)
                if obj.AppSettings.AssayParams.TranslateRecipeTimeToSweeps
                    reagentTimeLeft = -inf; % disable
                    numberOfSweeps = round(obj.recipe.time(recipeIndex)); % put in # of sweeps
                else % use timer
                    numberOfSweeps = -inf; % disable
                    reagentTimeTotal = obj.recipe.time(recipeIndex)*60; % put in sec
                    reagentTimeTic = tic;
                    reagentTimeLeft = 1E-10; % sec
                end
                
                %                 set(obj.gui.panel(testPanel).assayUI.timeValue, 'Value', reagentTimeLeft);
                %                 % update reagent
                %                 if reagentTimeLeft >= reagentTransitTimeToSensor
                %                     reagentInChannel = obj.recipe.reagent(recipeIndex);
                %                     set(obj.gui.panel(testPanel).assayUI.reagentValue, 'String', reagentInChannel);
                %                 end
                
                % take data until time expires
                while (reagentTimeLeft > 0) || (numberOfSweeps > 0)
                    
                    %% check for stop. If true, abort
                    if  stopReq
                        stopTest(obj, generalFilePath, dateTag);
                        return
                    end
                    
                    %% check for pause. If true, pause the test
                    if pauseReq
                        pauseTest(obj);
                    end
                    
                    if obj.AppSettings.AssayParams.UseFastILEngine
                        % Set the start/stop wavelength
                        obj.instr.Engine.WavelengthStart = targetDevice.getProp('StartWvl');
                        obj.instr.Engine.WavelengthStop = targetDevice.getProp('StopWvl');
                        % Start
                        obj.instr.Engine.StartMeasurement;
                        % Wait for measurement to be finished
                        while obj.instr.Engine.Busy; pause(.1); end;
                        % Get result object
                        MeasurementResult = obj.instr.Engine.MeasurementResult;
                        % need to convert MeasurementResult into [wvlData,pwrData]
                        % Save as OMR file
                        % MeasurementResult.Write('c:\Users\Public\test.omr');
                    else
                        [wvlData, pwrData] = sweep(obj);
                    end
                    
                    % plot sweep data in subplot window
                    %   wvlData and pwrData are returned as n x m arrays
                    %   n=datapoints and m=number of detectors
                    plotIndex = 0;
                    for ii=1:numDetectors
                        if (selectedDetectors(ii))
                            plotIndex = plotIndex + 1;
                            plot(obj.gui.panel(testPanel).sweepScanPlots(plotIndex), wvlData(:,ii), pwrData(:,ii));
                        end
                    end
                    
                    %% save data to object and disk
                    % params to save with each scan
                    params = scanParams(obj); % testbench equipment params to save with data
                    % Check to see if temp data dir exists. If not, create
                    targetDevice.checkDirectory(generalFilePath,...
                        obj.AppSettings.infoParams.Task,...
                        dateTag);
                    % save data
                    targetDevice.saveData(wvlData, pwrData, params);
                    % save plots
                    if obj.AppSettings.dryTest.SavePlots
                        targetDevice.savePlot(wvlData, pwrData);
                    end                    
                    
%                     %% rate test result
%                     val = 'Unknown'; % initialize
%                     if obj.AppSettings.AssayParams.RateRealtime
%                         msg = 'Rate device';
%                         %        list = obj.AppSettings.Device.RatingOptions;
%                         list = {'Unknown', 'Unusable', 'Poor', 'Good'};
%                         [~, val] = popup_dialog(msg,list);
%                     else % do automated threshold rating
%                         rtn = obj.devices.(deviceNames{k}).passFailCheck(obj.AppSettings.AssayParams.Threshold);
%                         if rtn(1) > 0 % pass
%                             val = 'Pass';
%                         else % fail
%                             val = 'Fail';
%                         end
%                     end
%                     
%                     obj.devices.(deviceNames{k}).setProp('TestStatus', val);
%                     %        msg=obj.devices.(deviceNames{k}).getProp('Rating'); msg
%                     % color code the test result for the table
%                     % gray 69 - http://www.color-hex.com/color-names.html
%                     %        ratingColor = '<html><table border=0 width=400 bgcolor=#b0b0b0><TR height=100><TD>&nbsp;</TD></TR> </table></html>';
%                     if strcmp(val, 'Good') || strcmp(val, 'Pass') % pass=auto
%                         ratingColor = '<html><table border=0 width=400 bgcolor=#7CFC00><TR height=100><TD>&nbsp;</TD></TR> </table></html>';
%                     elseif strcmp(val, 'Poor')
%                         ratingColor = '<html><table border=0 width=400 bgcolor=#FF6600><TR height=100><TD>&nbsp;</TD></TR> </table></html>'; % orange
%                     else % strcmp(val, 'Unusable') || strcmp(val, 'Fail')
%                         ratingColor = '<html><table border=0 width=400 bgcolor=#FF0000><TR height=100><TD>&nbsp;</TD></TR> </table></html>'; %red
%                     end
                    
                    %% update status table in test panel
%                     obj.gui.panel(testPanel).assayUI.deviceTable{selectedDeviceIndex, 2} = ratingColor;
%                     obj.gui.panel(testPanel).assayUI.deviceTable{selectedDeviceIndex, 3} = (obj.devices.(deviceNames{k}).getProp('Rating'));
                    obj.gui.panel(testPanel).assayUI.deviceTable{selectedDeviceIndex, 2} = 'Tested';
                    set(obj.gui.panel(testPanel).assayUI.resultTable, 'Data', obj.gui.panel(testPanel).assayUI.deviceTable);
                    
                    %% prep for next
                    % update scan #
                    currentScanNumber = targetDevice.getScanNumber();
                    set(obj.gui.panel(testPanel).testControlUI.scanNumberDisplay, 'String', num2str(currentScanNumber));
                    % update elapsed time
                    elapsedTimeSec = toc(ticID); % sec
                    set(obj.gui.panel(testPanel).testControlUI.elapsedTimeDisplay, 'String', num2str(round(elapsedTimeSec/60)));
                    
                    if obj.AppSettings.AssayParams.TranslateRecipeTimeToSweeps
                        numberOfSweeps = numberOfSweeps - 1;
                        % update recipe table in assay panel for sweeps
                        remaining = num2str(numberOfSweeps);
                    else % use timer
                        reagentTimeLeft = reagentTimeTotal - toc(reagentTimeTic); % sec
                        if reagentTimeLeft < 0
                            reagentTimeLeft = 0;
                        end
                        % update recipe table in assay panel for time
                        remaining = strcat(num2str(round(reagentTimeLeft*10)/10), 's');
                    end
                    assayUpdateTable(obj, recipeIndex, selectedDeviceIndex, remaining);
                    % update pumped volume
                    set(obj.gui.panel(testPanel).assayUI.pumpedVolumeDisp, 'String', num2str(obj.instr.pump.getPumpedVolume));
                    
                    % check for 'pause' or 'stop' by user
                    pauseReq = get(obj.gui.panel(testPanel).testControlUI.pauseButton, 'UserData'); % pause
                    stopReq = get(obj.gui.panel(testPanel).testControlUI.stopButton, 'UserData'); % stop
                end % while loop for scanning
            end % loop through SELECTED devices
        end % loop through ALL devices
    end % recipeIndex (looping through recipe)
end % iterations

if obj.AppSettings.AssayParams.UseFastILEngine % also should check if engine is active
    % Deactivate engine
    obj.instr.Engine.DeActivate;
    % Release measurement object
    % Release the engine and the engine manager
    obj.instr.Engine.release;
    EngineMgr.release;
end
end