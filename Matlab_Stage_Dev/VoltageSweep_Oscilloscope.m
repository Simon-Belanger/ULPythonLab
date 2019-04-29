function [voltage1, voltage2, Cur1, Cur2, transmitted, reflected, Off] = VoltageSweep_Oscilloscope()
tic
% Power supply settings
startVoltage1 = 0;
stopVoltage1 = 5;
stepVoltage1 = 0.2;
startVoltage2 = 0;
stopVoltage2 = 5;
stepVoltage2 = 0.05;


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

% Find a GPIB object.
Detect = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 7, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(Detect)
    Detect = gpib('AGILENT', 32, 7);
else
    fclose(Detect);
    Detect = Detect(1);
end

% Connect to instrument object, obj1.
fopen(powerSupply);
fopen(laser);
fopen(Detect);

fprintf(laser, '%s\n', 'LOCK 0,1234');
fprintf(laser, '%s\n', 'SOUR:POW 5DBM');
fprintf(laser, '%s\n', 'SOUR:WAV 1550NM');
fprintf(laser, '%s\n', 'SOUR:POW:STAT 1');

fprintf(laser, '%s\n', 'SENS2:POW:REF:STAT 0');
fprintf(laser, '%s\n', 'SENS2:POW:UNIT 0');
fprintf(laser, '%s\n', 'SENS2:POW:WAV 1550NM');
fprintf(laser, '%s\n', 'INIT2:CONT 1');

fprintf(laser, '%s\n', ['SOUR:WAV ' num2str(wavelength) 'NM']);

fprintf(powerSupply, '%s\n', 'INST:SEL OUT1');
fprintf(powerSupply, '%s\n', 'OUTP ON');
fprintf(powerSupply, '%s\n', 'INST:SEL OUT2');
fprintf(powerSupply, '%s\n', 'OUTP ON');


pause(1);
for II=1:10
    pause(0.1);
    fprintf(Detect, ':MEASure:VAVerage?[1]');
    Off(II) = str2num(fscanf(Detect));
end
Off = mean(Off);

voltage1 = startVoltage1:stepVoltage1:stopVoltage1;
voltage2 = startVoltage2:stepVoltage2:stopVoltage2;
transmitted=ones(length(voltage1),length(voltage2));

total = length(voltage1) * length(voltage2);

for j=1:length(voltage1)
    fprintf(powerSupply, '%s\n', 'INST:SEL OUT1');
    fprintf(powerSupply, '%s\n', 'OUTP ON');
    fprintf(powerSupply, '%s\n', ['APPLY ' num2str(voltage1(j)) ',0.01']);
    pause(0.01);
    Cur1(j) = str2num(query(powerSupply, 'MEASure:CURRent?'));
    % to do: sweep here
    for k=1:length(voltage2)
        fprintf(powerSupply, '%s\n', 'INST:SEL OUT2');
        fprintf(powerSupply, '%s\n', 'OUTP ON');
        fprintf(powerSupply, '%s\n', ['APPLY ' num2str(voltage2(k)) ',0.01']);
        pause(0.01);
        Cur2(j,k) = str2num(query(powerSupply, 'MEASure:CURRent?'));
        pause(0.1);
        for II=1:10
            pause(0.02);
            trans(II) = str2num(query(Detect, ':MEASure:VAVerage?[1]'));
            refl(II) = str2num(query(laser, 'FETC2:POW?'));
        end
        transmitted(j,k) = mean(trans);
        reflected(j,k) = mean(refl);
        
        fprintf(powerSupply, '%s\n', 'OUTP OFF');
        pause(0.05);
        
    end
    progress = ((j-1)*length(voltage2))/total;
end

%transmitted = transmitted - Off;

fprintf(laser, '%s\n', 'SOUR:POW:STAT 0');
%fprintf(laser, '%s\n', 'LOCK 1,1234');
fprintf(powerSupply, '%s\n', 'APPLY 0,0.01');
fprintf(powerSupply, '%s\n', 'OUTP OFF');

% Disconnect all objects.
fclose(powerSupply);
fclose(laser);
fclose(Detect);

% Clean up all objects.
delete(powerSupply);
delete(laser);
delete(Detect);
toc
