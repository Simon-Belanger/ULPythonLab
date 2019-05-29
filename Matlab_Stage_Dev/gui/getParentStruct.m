%   getParentStruct function is used to determine the parent struct (string) 
% under which the instrument UIs should be built.
%   It takes the parent panel name (string) as input and return the parent
% structure name (string).
% Vince Wu - Nov 2013
function parentStruct = getParentStruct(parentName)
% New popup should be added here in a elseif statement
% adding new main panels are not required here because it is obtain the
% panel_index function.
if strcmpi(parentName, 'manual')
    parentStruct = 'manualCoordPopup';
elseif strcmpi(parentName, 'selectPeaks')
    parentStruct = 'selectPeaksPopup';
else % Should belong to one of the panels
    thisPanel = num2str(panel_index(parentName));
    parentStruct = strcat('panel(', thisPanel, ')');
end
end