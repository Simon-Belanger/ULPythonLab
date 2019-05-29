function fld_pump_popup(gui, instr)

gui.mainWindow = figure(...
    'Position', [360, 200, 700, 400],...
    'Menu', 'None',...
    'Name', 'Fliudic Pump Startup',...
    'WindowStyle', 'normal',...  %normal , modal, docked.
    'Visible', 'on',...
    'NumberTitle', 'off',...
    'CloseRequestFcn', {@closeWindow});

%set up main
gui.fld_Panel = uipanel(...
    'parent', gui.mainWindow,...
    'Title','',...
    'Unit','Pixels',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Visible','on',...
    'Units', 'normalized', 'Position', [.005, .005, .990, .990]);

%Description String
gui.stringTitle = uicontrol(...
    'parent', gui.fld_Panel,...
    'Style','text',...
    'HorizontalAlignment','center',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'FontWeight','bold',...
    'Units', 'normalized', 'Position', [.1, .9, .8, .1],...
    'String','Expunge Fluidic Pump');

%Syringe
gui.dSyringeString = uicontrol('Parent', gui.fld_Panel,...
                               'Style', 'text',...
                               'BackgroundColor',[0.9 0.9 0.9],...
                               'HorizontalAlignment','left',...
                               'Units', 'normalized', ...
                               'Position', [.1, .7, .06, .04],...
                               'String', 'Syringe:',...
                               'FontSize', 9);
                           
syringe_list = {'Select','5mL', '25mL'};
% default_user_syringe = find(strcmp(user.fluidicPumpParams.PumpSyringe, syringe_list));
% if(isempty(default_user_syringe))
%     default_user_syringe = 1;
% end

gui.dPDSyringe = uicontrol('Parent', gui.fld_Panel,...
                           'Style','popupmenu', ...
                           'Enable','on', ...
                           'Units', 'normalized', ...
                           'Position', [.5, .7, .10, .04],...
                           'String', syringe_list,...
                           'Callback',{@Syringe_Callback});
                       
%Velocity
gui.dVelocity = uicontrol('Parent', gui.fld_Panel,...
                          'Style','text',...
                          'BackgroundColor',[0.9 0.9 0.9 ],...
                          'HorizontalAlignment','left',...
                          'Units', 'normalized', ...
                          'Position', [.1, .6, .16, .04],...
                          'String','Velocity (ul/min):',...
                          'FontSize', 9);

gui.dSyringeVelocity = uicontrol('Parent', gui.fld_Panel,...
                                 'Style','edit', ...
                                 'Enable','on', ...
                                 'Units', 'normalized', ...
                                 'Position', [.5, .6, .10, .04],...
                                 'String', '5000mL',...
                                 'Callback',{@dSyringeVelocity_Callback});
    
gui.instructions_str = uicontrol(...
    'parent', gui.fld_Panel,...
    'Style', 'text',...
    'HorizontalAlignment','center',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Units', 'normalized', 'Position', [.1, .2, .8, .3],...
    'FontSize', 16,...
    'String','WARNING: Pressing expunge will remove all liquid from the selected syringe!');
    
gui.expunge_button = uicontrol(...
    'parent', gui.fld_Panel,...
    'Style', 'pushbutton',...
    'BackgroundColor',[0.9 0.9 0.9 ],...
    'Units', 'normalized', 'Position', [.4, .2, .2, .1],...
    'String','Expunge',...
    'Enable', 'off',...
    'Callback', @expunge);


function expunge(hObject, eventdata)
    instr.fluidicPump.pump(instr.fluidicPump.SyringVolume - instr.fluidicPump.PumpedVolume);
    debug_msg(gui, 'Emptying fluidic pump');
    instr.fluidicPump.PumpedVolume = 0;
    close(gui.mainWindow);
end

function Syringe_Callback(hObject, eventdata)
    valSyringe = get(gui.dPDSyringe, 'Value');
    if valSyringe ~= 1
        set(gui.expunge_button, 'Enable', 'on');
        if (valSyringe == 2) 
            instr.fluidicPump.SyringeVolume = -5000;
        else 
            instr.fluidicPump.SyringeVolume = -25000;
        end
    end
end

function exit_Callback(hObject,eventdata)
         close(gui.mainWindow);    
end

function closeWindow(hObject,eventdata)   
         delete(gcbf);
end

function warning_cb(hObject, eventdata)
end


end

