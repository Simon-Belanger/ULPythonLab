function params = scanParams(benchObj)
    laserParam = benchObj.instr.laser.getAllParams();
    detectorParam = benchObj.instr.detector.getAllParams();
    opticalStageParam = benchObj.instr.opticalStage.getAllParams();
    TECParam = benchObj.instr.thermalControl.getAllParams();
    
    params = struct(...
        'laserParams', laserParam, ...
        'detectorParams', detectorParam, ...
        'opticalStageParams', opticalStageParam, ...
        'TECParams', TECParam);
end