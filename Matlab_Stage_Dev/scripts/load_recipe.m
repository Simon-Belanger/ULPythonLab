function recipe = load_recipe(FileName)
    file_id = fopen(FileName);
    textlines = textscan(file_id,...
        '%f %f %s %f %f %f %s',... % signed int, float, string, float, float, float, string
        'Delimiter',',',... % move to new cell upon reading this character
        'ReturnOnError',0,... % stops function and returns error if problem reading file
        'HeaderLines',1); % lines to skip at beginning of file
    recipe.well = textlines{1,1};
    recipe.time = textlines{1,2};
    recipe.reagent = textlines{1,3};
    recipe.ri = textlines{1,4};
    recipe.velocity = textlines{1,5};
    recipe.temp = textlines{1,6};
    recipe.comment = textlines{1,7};
    % recipe = {well, time, reagent, refractive index, velocity, temp, comment}
    
%     recipe.velocity = textlines{1,3}(2:end);
%     recipe.reagent = textlines{1,4}(2:end);
%     recipe.comment = textlines{1,5}(2:end);
%    recipe = {well, time, velocity, reagent, comment};
end