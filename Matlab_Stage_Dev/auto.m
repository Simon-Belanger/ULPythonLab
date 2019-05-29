path = 'C:\Users\Lab\Desktop\Gap20_8April\';

% Power supply settings
startVoltage = 0;
stopVoltage = 8;
stepVoltage = 1;
reverseBias = 1; % true or false

% VNA settings
startFreq = 500000000;
stopFreq = 20000000000;
points = 201; %NOT MORE THAN 300

% Laser settings
startWavelength = 1546;
stopWavelength = 1546.7;
stepWavelength = 0.02;

% =========== DON'T MODIFY PAST HERE ===========

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
vna = instrfind('Type', 'gpib', 'BoardIndex', 32, 'PrimaryAddress', 16, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(vna)
    vna = gpib('AGILENT', 32, 16);
else
    fclose(vna);
    vna = vna(1);
end

% Configure instrument object, obj1
set(vna, 'InputBufferSize', 20000);
set(vna, 'OutputBufferSize', 512);

% Connect to instrument object, obj1.
fopen(vna);
fopen(powerSupply);
fopen(laser);

% Init
fprintf(vna, '%s\n', 'SENS:AVER:COUN 10');
fprintf(vna, '%s\n', 'SENS:AVER ON');
fprintf(vna, '%s\n', ['SENS:SWE:POIN ' num2str(points)]);
fprintf(vna, '%s\n', ['SENS:FREQ:STAR ' num2str(startFreq)]);
fprintf(vna, '%s\n', ['SENS:FREQ:STOP ' num2str(stopFreq)]);
fprintf(vna, '%s\n', ['CALC:PAR ' char(39) 'My_S21' char(39) ',S21']);
fprintf(vna, '%s\n', 'FORM ASCII');

fprintf(powerSupply, '%s\n', 'OUTP ON');

fprintf(laser, '%s\n', 'LOCK 0,1234');
fprintf(laser, '%s\n', 'SOUR:POW 10DBM');
fprintf(laser, '%s\n', 'SOUR:WAV 1547.3NM');
fprintf(laser, '%s\n', 'SOUR:POW:STAT 1');

fprintf(laser, '%s\n', 'SENS2:POW:REF:STAT 0');
fprintf(laser, '%s\n', 'SENS2:POW:UNIT 0');
fprintf(laser, '%s\n', 'SENS2:POW:WAV 1547NM');
fprintf(laser, '%s\n', 'INIT2:CONT 1');

freq = linspace(startFreq, stopFreq, points);
voltage = startVoltage:stepVoltage:stopVoltage;
wavelength = startWavelength:stepWavelength:stopWavelength;
if reverseBias
    polarity = '-';
else
    polarity = '+';
end
total = length(voltage) * length(wavelength);

for j=1:length(voltage)
    mkdir(fullfile(path, [polarity num2str(voltage(j)) 'V\']));
    fprintf(powerSupply, '%s\n', ['APPLY ' num2str(voltage(j)) ',0.01']);
    % to do: sweep here
    for k=1:length(wavelength)
        fprintf(laser, '%s\n', ['SOUR:WAV ' num2str(wavelength(k)) 'NM']);
        pause(5);
        fprintf(vna, '%s\n', ['CALC:PAR:SEL ' char(39) 'My_S21' char(39)]);
        fprintf(vna, '%s\n', 'CALC:DATA? FDATA');
        res = cellfun(@str2double, strsplit(fscanf(vna, '%s'), ','));
        fprintf(laser, '%s\n', 'FETC2:POW?');
        sensor = fscanf(laser, '%s');
        csvwrite(fullfile(path, [polarity num2str(voltage(j)) 'V\' num2str(wavelength(k),'%4.2f') 'nm_' num2str(str2double(sensor)) 'dBm.csv']), ...
            horzcat(freq', res'));
        progress = ((j-1)*length(wavelength)+k)/total
    end
end

fprintf(laser, '%s\n', 'SOUR:POW:STAT 0');
fprintf(laser, '%s\n', 'LOCK 1,1234');
fprintf(powerSupply, '%s\n', 'APPLY 0,0.01');
fprintf(powerSupply, '%s\n', 'OUTP OFF');

% Disconnect all objects.
fclose(vna);
fclose(powerSupply);
fclose(laser);

% Clean up all objects.
delete(vna);
delete(powerSupply);
delete(laser);
