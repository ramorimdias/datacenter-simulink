function add_subsystem(model_name, subsystem_name, position, color)
%ADD_SUBSYSTEM Add a top-level subsystem.
%
% Some Simulink releases reject friendly aliases such as "lightGreen".
% Map requested display colors to the standard color names accepted by the
% block BackgroundColor parameter. If a release rejects styling entirely,
% create the subsystem first and fall back to a white background.

    path = [model_name '/' subsystem_name];

    requested = lower(char(string(color)));
    switch requested
        case {'lightgreen', 'green'}
            safe_color = 'green';
        case {'lightblue', 'blue'}
            safe_color = 'lightBlue';
        case {'yellow'}
            safe_color = 'yellow';
        case {'orange'}
            safe_color = 'orange';
        case {'cyan'}
            safe_color = 'cyan';
        case {'magenta'}
            safe_color = 'magenta';
        case {'gray', 'grey'}
            safe_color = 'gray';
        otherwise
            safe_color = 'white';
    end

    % Create the subsystem using only universally supported parameters.
    add_block('simulink/Ports & Subsystems/Subsystem', path, ...
        'Position', position);

    try
        set_param(path, 'BackgroundColor', safe_color, ...
            'ForegroundColor', 'black', 'FontWeight', 'bold', ...
            'FontSize', '12');
    catch
        % Styling is optional; model construction can continue.
    end

    % ShowPortLabels is not available for every subsystem implementation.
    try
        set_param(path, 'ShowPortLabels', 'FromPortIcon');
    catch
        % Port labels remain at the release default.
    end

    clear_subsystem(path);
end
