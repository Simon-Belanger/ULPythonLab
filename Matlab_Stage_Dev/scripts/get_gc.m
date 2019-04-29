function get_gc(obj, heatmapHandle)
% Gets mouse coordinates and moves to GC location

opticalStage = obj.instr.opticalStage;
os = obj.instr.opticalStage.getProp('Overshoot');
axes(heatmapHandle); % make active

dataObjs = get(heatmapHandle, 'Children'); % handles to low-level graphics
xdata = get(dataObjs, 'XData'); % data from low-level grahics objects
ydata = get(dataObjs, 'YData'); % data from low-level grahics objects

% get the offset from the graph
[x, y, button] = ginput(1); % get mouse cursor input

msg = strcat('get_gc: mouse x:', num2str(x));
obj.msg(msg);
msg = strcat('get_gc: mouse y:', num2str(y));
obj.msg(msg);


%% Motor backlash compensation
backlash_x = 0 + 10 * (abs(mean(xdata)) < 1e-6);
backlash_y = 0 + 20 * (abs(mean(ydata)) < 1e-6);


%% Moving the opticalStage
if button == 1 % left
    opticalStage.move_x(-x + backlash_x);   % move in x-direction
    opticalStage.move_y(y - backlash_y);    % move in y-direction
    
    % Move the surface plot for next
    set(dataObjs, 'XData', xdata - x);
    set(dataObjs, 'YData', ydata - y);
end


end