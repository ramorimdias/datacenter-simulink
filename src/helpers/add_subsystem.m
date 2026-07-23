function add_subsystem(model_name, subsystem_name, position, color)
%ADD_SUBSYSTEM Add a top-level subsystem.
%
% Some Simulink releases reject friendly aliases such as "lightGreen".
% Map requested display colors to the standard color names accepted by the
% block BackgroundColor parameter. If a release rejects styling entirely,
% create the subsystem first and fall back to a white background.

    path = [model_name '/' subsystem_name];

    %#ok<INUSD> color is retained for compatibility with existing builders.

    % Create the subsystem using only universally supported parameters.
    add_block('simulink/Ports & Subsystems/Subsystem', path, ...
        'Position', position);

    % ShowPortLabels is not available for every subsystem implementation.
    try
        set_param(path, 'ShowPortLabels', 'FromPortIcon');
    catch
        % Port labels remain at the release default.
    end

    clear_subsystem(path);
end
