function added = add_dashboard_slider(parent_path, slider_name, target_block_name, target_parameter, limits, position)
%ADD_DASHBOARD_SLIDER Add and bind an interactive Dashboard Slider.
%
% The helper is deliberately release tolerant. If the installed Simulink
% release does not expose the Dashboard library or programmatic HMI binding,
% model generation continues without the slider. The target Constant or Gain
% block remains editable through its normal block dialog.

    added = false;
    slider_path = [parent_path '/' slider_name];
    target_path = [parent_path '/' target_block_name];

    try
        add_block('simulink/Dashboard/Slider', slider_path, ...
            'Position', position);

        try
            set_param(slider_path, ...
                'Limits', limits, ...
                'LabelPosition', 'Bottom');
        catch
            % Older releases may use a different dashboard styling schema.
        end

        source = Simulink.HMI.ParamSourceInfo;
        source.BlockPath = Simulink.BlockPath(target_path);
        source.ParamName = target_parameter;
        set_param(slider_path, 'Binding', source);
        added = true;
    catch exception
        warning('datacenter:dashboardSliderUnavailable', ...
            ['Dashboard slider "%s" could not be created or bound. ' ...
             'The underlying parameter block remains directly editable. %s'], ...
            slider_name, exception.message);

        try
            if getSimulinkBlockHandle(slider_path) > 0
                delete_block(slider_path);
            end
        catch
            % Optional UI element. Do not stop physical-model construction.
        end
    end
end
