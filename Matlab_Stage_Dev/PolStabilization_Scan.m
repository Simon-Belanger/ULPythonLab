function [Results] = PolStabilization_Scan(phi1,phi2)
tic
% Power supply settings
startVoltage1 = 1;
stopVoltage1 = 10;
stepVoltage1 = 0.2;

VRange2 = 1;
VStep2 = 0.1;
VRange3 = 0.2;
VStep3 = 0.01;
% VRange4 = 0.1;
% VStep4 = 0.01;


% Laser settings
wavelength = 1550;

% Find a GPIB object.
laser = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 20, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(laser)
    laser = gpib('AGILENT', 32, 20);
else
    fclose(laser);
    laser = laser(1);
end

% Find a GPIB object.
powerSupply = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 5, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(powerSupply)
    powerSupply = gpib('AGILENT', 32, 5);
else
    fclose(powerSupply);
    powerSupply = powerSupply(1);
end

% Connect to instrument object, obj1.
fopen(powerSupply);
fopen(laser);

fprintf(laser, '%s\n', 'LOCK 0,1234');
fprintf(laser, '%s\n', 'SOUR:POW 6.5DBM');
fprintf(laser, '%s\n', 'SOUR:WAV 1550NM');
fprintf(laser, '%s\n', 'SOUR:POW:STAT 1');

fprintf(laser, '%s\n', 'SENS2:POW:REF:STAT 0');
fprintf(laser, '%s\n', 'SENS2:POW:UNIT 0');
fprintf(laser, '%s\n', 'SENS2:POW:WAV 1550NM');
fprintf(laser, '%s\n', 'INIT2:CONT 1');
fprintf(laser, '%s\n', 'SENS2:PWO:RANG:AUTO 0');
fprintf(laser, '%s\n', 'SENS2:POW:ATIM 1ms');
fprintf(laser, '%s\n', 'SENS2:POW:RANG:MON -20DBM');

fprintf(laser, '%s\n', 'SENS2:CHAN2:POW:REF:STAT 0');
fprintf(laser, '%s\n', 'SENS2:CHAN2:POW:UNIT 0');
fprintf(laser, '%s\n', 'SENS2:CHAN2:POW:WAV 1550NM');
%fprintf(laser, '%s\n', 'INIT3:CONT 1');
fprintf(laser, '%s\n', 'SENS2:CHAN2:PWO:RANG:AUTO 0');
fprintf(laser, '%s\n', 'SENS2:CHAN2:POW:ATIM 1ms');
fprintf(laser, '%s\n', 'SENS2:CHAN2:POW:RANG:MON -20DBM');

fprintf(laser, '%s\n', ['SOUR:WAV ' num2str(wavelength) 'NM']);

fprintf(powerSupply, '%s\n', 'INST:SEL OUT1');
fprintf(powerSupply, '%s\n', 'OUTP ON');
fprintf(powerSupply, '%s\n', 'APPLY 0 0.01');
fprintf(powerSupply, '%s\n', 'INST:SEL OUT2');
fprintf(powerSupply, '%s\n', 'OUTP ON');
fprintf(powerSupply, '%s\n', 'APPLY 0 0.01');

voltage1 = startVoltage1:stepVoltage1:stopVoltage1;
Chan1 = VoltageScan(voltage1, 1,powerSupply,laser);
[Min1,Ind] = min(Chan1); Vmin1 = voltage1(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin1) ',0.01']);

voltage2 = startVoltage1:stepVoltage1:stopVoltage1;
Chan1 = VoltageScan(voltage2, 2,powerSupply,laser);
[Min2,Ind] = min(Chan1); Vmin2 = voltage2(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin2) ',0.01']);

Low = max(0.5,Vmin1-VRange2); High = min(stopVoltage1+0.5,Vmin1+VRange2);
voltage1 = Low:VStep2:High;
Chan1 = VoltageScan(voltage1, 1,powerSupply,laser);
[Min1,Ind] = min(Chan1); Vmin1 = voltage1(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin1) ',0.01']);

Low = max(0.5,Vmin2-VRange2); High = min(stopVoltage1+0.5,Vmin2+VRange2);
voltage2 = Low:VStep2:High;
Chan1 = VoltageScan(voltage2, 2,powerSupply,laser);
[Min2,Ind] = min(Chan1); Vmin2 = voltage2(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin2) ',0.01']);

Low = max(0.2,Vmin1-VRange3); High = min(stopVoltage1+1,Vmin1+VRange3);
voltage1 = Low:VStep3:High;
Chan1 = VoltageScan(voltage1, 1,powerSupply,laser);
[Min1,Ind] = min(Chan1); Vmin1 = voltage1(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin1) ',0.01']);

Low = max(0.2,Vmin2-VRange3); High = min(stopVoltage1+1,Vmin2+VRange3);
voltage2 = Low:VStep3:High;
Chan1 = VoltageScan(voltage2, 2,powerSupply,laser);
[Min2,Ind] = min(Chan1); Vmin2 = voltage2(Ind);
fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Vmin2) ',0.01']);

% Low = max(0,Min1-VRange4); High = min(7,Min1+VRange4);
% voltage1 = Low:VStep4:High;
% Chan1 = VoltageScan(voltage1, 1,powerSupply,laser);
% [Min1,Ind] = min(Chan1);
% fprintf(powerSupply, '%s\n', ['APPLY ' num2str(voltage1(Ind)) ',0.01']);
% 
% Low = max(0,Min2-VRange4); High = min(7,Min2+VRange4);
% voltage2 = Low:VStep4:High;
% Chan1 = VoltageScan(voltage2, 2,powerSupply,laser);
% [Min2,Ind] = min(Chan1);
% fprintf(powerSupply, '%s\n', ['APPLY ' num2str(voltage2(Ind)) ',0.01']);


for II=1:10
    pause(0.02);
    trans1(II) = str2num(query(laser, 'FETC2:POW?'));
    trans2(II) = str2num(query(laser, 'FETC2:CHAN2:POW?'));
end
T1 = mean(trans1);
T2 = mean(trans2);


fprintf(powerSupply, '%s\n', 'INST:SEL OUT1');
V1 = str2num(query(powerSupply, 'MEASure:Voltage?'));
I1 = str2num(query(powerSupply, 'MEASure:CURRent?'));

fprintf(powerSupply, '%s\n', 'INST:SEL OUT2');
I2 = str2num(query(powerSupply, 'MEASure:CURRent?'));
V2 = str2num(query(powerSupply, 'MEASure:Voltage?'));

Results = [phi1, phi2, T1, T2, V1, I1, V2, I2];



fprintf(laser, '%s\n', 'SOUR:POW:STAT 0');
%fprintf(laser, '%s\n', 'LOCK 1,1234');
fprintf(powerSupply, '%s\n', 'APPLY 0,0.01');
fprintf(powerSupply, '%s\n', 'OUTP OFF');

% Disconnect all objects.
fclose(powerSupply);
fclose(laser);

% Clean up all objects.
delete(powerSupply);
delete(laser);
% toc


end

function Chan1 = VoltageScan(Voltage, Output,powerSupply,laser)

for JJ=1:length(Voltage)
    fprintf(powerSupply, '%s\n', ['INST:SEL OUT',num2str(Output)]);
    fprintf(powerSupply, '%s\n', ['APPLY ' num2str(Voltage(JJ)) ',0.01']);
    pause(0.025);
    for II=1:3
        pause(0.005);
        trans1(II) = str2num(query(laser, 'FETC2:POW?'));
    end
    Chan1(JJ) = mean(trans1);
end

disp(['Current Minimum is ',num2str(min(Chan1)),' dBm']);
end