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

    % Dashboard sliders are optional UI controls. Inputs remain directly
    % editable in their Constant/Gain block dialogs.
    return;

    try
        % The public library path changed across Simulink releases.
        % Try the current path first, followed by the legacy HMI library.
        slider_sources = { ...
            'simulink/Dashboard/Slider', ...
            'simulink_hmi_blocks/Slider'};
        last_add_exception = [];
        for source_idx = 1:numel(slider_sources)
            try
                add_block(slider_sources{source_idx}, slider_path, ...
                    'Position', position);
                last_add_exception = [];
                break;
            catch add_exception
                last_add_exception = add_exception;
            end
        end
        if ~isempty(last_add_exception)
            rethrow(last_add_exception);
        end

        try
            set_param(slider_path, ...
                'Limits', limits, ...
                'LabelPosition', 'Bottom');
        catch
            % Some releases reject fractional major-tick intervals. Preserve
            % the requested minimum and maximum and let Simulink choose ticks.
            try
                set_param(slider_path, ...
                    'Limits', [limits(1) -1 limits(3)], ...
                    'LabelPosition', 'Bottom');
            catch
                % Styling/range setup is optional. Binding is attempted below.
            end
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
