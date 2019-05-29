function [data] = figdata()

hxy = get(gca,'Children');
data.xdata = get(hxy,'XData');
data.ydata = get(hxy,'YData');