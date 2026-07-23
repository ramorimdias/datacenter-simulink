function build_fluid_properties_subsystem(path)
%BUILD_FLUID_PROPERTIES_SUBSYSTEM Fluid-property source and live controls.
%
% The subsystem outputs clean-liquid properties as explicit Simulink signals.
% Dashboard sliders tune the Constant block values during a normal-mode
% simulation. Rebuilding the model restores the defaults from
% config/default_parameters.m.

    cp_i = evalin('base', 'cp_internal_J_kgK');
    rho_i = evalin('base', 'rho_internal_kg_m3');
    mu_i_cP = evalin('base', 'dynamic_viscosity_internal_cP');
    k_i = evalin('base', 'k_internal_W_mK');

    cp_e = evalin('base', 'cp_external_J_kgK');
    rho_e = evalin('base', 'rho_external_kg_m3');
    mu_e_cP = evalin('base', 'dynamic_viscosity_external_cP');
    k_e = evalin('base', 'k_external_W_mK');

    % Internal-loop property sources.
    add_block('simulink/Sources/Constant', [path '/Internal Cp J_kgK'], ...
        'Value', num2str(cp_i, 15), 'Position', [35 45 125 75]);
    add_block('simulink/Sources/Constant', [path '/Internal Density kg_m3'], ...
        'Value', num2str(rho_i, 15), 'Position', [35 105 125 135]);
    add_block('simulink/Sources/Constant', [path '/Internal Viscosity cP'], ...
        'Value', num2str(mu_i_cP, 15), 'Position', [35 165 125 195]);
    add_block('simulink/Math Operations/Gain', ...
        [path '/Internal cP to Pa_s'], 'Gain', '1e-3', ...
        'Position', [165 160 245 200]);
    add_block('simulink/Sources/Constant', ...
        [path '/Internal Conductivity W_mK'], ...
        'Value', num2str(k_i, 15), 'Position', [35 225 125 255]);

    % External-loop property sources.
    add_block('simulink/Sources/Constant', [path '/External Cp J_kgK'], ...
        'Value', num2str(cp_e, 15), 'Position', [35 355 125 385]);
    add_block('simulink/Sources/Constant', [path '/External Density kg_m3'], ...
        'Value', num2str(rho_e, 15), 'Position', [35 415 125 445]);
    add_block('simulink/Sources/Constant', [path '/External Viscosity cP'], ...
        'Value', num2str(mu_e_cP, 15), 'Position', [35 475 125 505]);
    add_block('simulink/Math Operations/Gain', ...
        [path '/External cP to Pa_s'], 'Gain', '1e-3', ...
        'Position', [165 470 245 510]);
    add_block('simulink/Sources/Constant', ...
        [path '/External Conductivity W_mK'], ...
        'Value', num2str(k_e, 15), 'Position', [35 535 125 565]);

    % Explicit interface ports.
    add_out(path, 'InternalCp_J_kgK', 1, [720 50 750 70]);
    add_out(path, 'InternalDensity_kg_m3', 2, [720 105 750 125]);
    add_out(path, 'InternalViscosity_Pa_s', 3, [720 160 750 180]);
    add_out(path, 'InternalConductivity_W_mK', 4, [720 215 750 235]);
    add_out(path, 'ExternalCp_J_kgK', 5, [720 360 750 380]);
    add_out(path, 'ExternalDensity_kg_m3', 6, [720 415 750 435]);
    add_out(path, 'ExternalViscosity_Pa_s', 7, [720 470 750 490]);
    add_out(path, 'ExternalConductivity_W_mK', 8, [720 525 750 545]);

    % Numeric displays remain visible after the simulation stops.
    display_specs = {
        'Internal Cp Display',             [500 40 640 75];
        'Internal Density Display',        [500 95 640 130];
        'Internal Viscosity Display',      [500 150 640 185];
        'Internal Conductivity Display',   [500 205 640 240];
        'External Cp Display',             [500 350 640 385];
        'External Density Display',        [500 405 640 440];
        'External Viscosity Display',      [500 460 640 495];
        'External Conductivity Display',   [500 515 640 550]
    };
    for idx = 1:size(display_specs,1)
        add_block('simulink/Sinks/Display', ...
            [path '/' display_specs{idx,1}], ...
            'Position', display_specs{idx,2});
    end

    % Signal routing.
    add_line(path, 'Internal Cp J_kgK/1', 'InternalCp_J_kgK/1');
    add_line(path, 'Internal Cp J_kgK/1', 'Internal Cp Display/1');
    add_line(path, 'Internal Density kg_m3/1', 'InternalDensity_kg_m3/1');
    add_line(path, 'Internal Density kg_m3/1', 'Internal Density Display/1');
    add_line(path, 'Internal Viscosity cP/1', 'Internal cP to Pa_s/1');
    add_line(path, 'Internal cP to Pa_s/1', 'InternalViscosity_Pa_s/1');
    add_line(path, 'Internal cP to Pa_s/1', 'Internal Viscosity Display/1');
    add_line(path, 'Internal Conductivity W_mK/1', ...
        'InternalConductivity_W_mK/1');
    add_line(path, 'Internal Conductivity W_mK/1', ...
        'Internal Conductivity Display/1');

    add_line(path, 'External Cp J_kgK/1', 'ExternalCp_J_kgK/1');
    add_line(path, 'External Cp J_kgK/1', 'External Cp Display/1');
    add_line(path, 'External Density kg_m3/1', 'ExternalDensity_kg_m3/1');
    add_line(path, 'External Density kg_m3/1', 'External Density Display/1');
    add_line(path, 'External Viscosity cP/1', 'External cP to Pa_s/1');
    add_line(path, 'External cP to Pa_s/1', 'ExternalViscosity_Pa_s/1');
    add_line(path, 'External cP to Pa_s/1', 'External Viscosity Display/1');
    add_line(path, 'External Conductivity W_mK/1', ...
        'ExternalConductivity_W_mK/1');
    add_line(path, 'External Conductivity W_mK/1', ...
        'External Conductivity Display/1');

    % Interactive controls. Limits are deliberately broad engineering ranges.
    add_dashboard_slider(path, 'Tune Internal Cp', ...
        'Internal Cp J_kgK', 'Value', [2500 250 4500], [285 35 445 80]);
    add_dashboard_slider(path, 'Tune Internal Density', ...
        'Internal Density kg_m3', 'Value', [750 50 1250], [285 90 445 135]);
    add_dashboard_slider(path, 'Tune Internal Viscosity', ...
        'Internal Viscosity cP', 'Value', [0.5 0.5 20], [285 145 445 190]);
    add_dashboard_slider(path, 'Tune Internal Conductivity', ...
        'Internal Conductivity W_mK', 'Value', [0.1 0.05 0.7], [285 200 445 245]);

    add_dashboard_slider(path, 'Tune External Cp', ...
        'External Cp J_kgK', 'Value', [2500 250 4500], [285 345 445 390]);
    add_dashboard_slider(path, 'Tune External Density', ...
        'External Density kg_m3', 'Value', [750 50 1250], [285 400 445 445]);
    add_dashboard_slider(path, 'Tune External Viscosity', ...
        'External Viscosity cP', 'Value', [0.5 0.5 20], [285 455 445 500]);
    add_dashboard_slider(path, 'Tune External Conductivity', ...
        'External Conductivity W_mK', 'Value', [0.1 0.05 0.7], [285 510 445 555]);

    Simulink.Annotation(path, sprintf([ ...
        'FLUID PROPERTIES\n' ...
        'Dashboard sliders are tunable during normal-mode simulation.\n' ...
        'Viscosity input is cP; the output signal is Pa.s.']));
end
