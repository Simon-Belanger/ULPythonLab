function msg(obj, message)

% Modify debug message
clk = clock; 
clkstr = sprintf('%.2d:%.2d:%.2d', clk(4), clk(5), fix(clk(6)));
msg = sprintf('%s -  %s ', clkstr, message);

% Obtain current string on the debug window
string = get(obj.gui.debugConsole, 'String');
if(isempty(string))
    string = cell(1, 1);
    string{1} = msg;
else 
    % Add new message to debug window
    string(2:end+1) = string;
    string{1} = msg;    
end

set(obj.gui.debugConsole, 'String', string);

end