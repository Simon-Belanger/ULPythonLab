function [] = get_vna(bias, power, lambda)
[x, y] = queryData();
h = figure;
plot(x, y);
xlabel('Freq. [GHz]');
ylabel('Power [dBm]');
bias = strrep(num2str(bias), '.' , ',');
power = strrep(num2str(power), '.' , ',');
lambda = strrep(num2str(lambda), '.' , ',');
pt = strcat('Pow=', power, '_Wav=', lambda);
title(pt);
saveas(h, strcat('.\VNA\', bias,'V\', pt), 'fig');
