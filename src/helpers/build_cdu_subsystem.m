function build_cdu_subsystem(path)
%BUILD_CDU_SUBSYSTEM Reduced-order CDU and internal cold-plate loop.
%
% Fluid and aeration quantities are explicit input signals so they can be
% tuned during a normal-mode simulation from the dedicated upstream blocks.

    add_in(path, 'HeatFromRacks_kW', 1, [25 45 55 65]);
    add_in(path, 'ExternalSupply_C', 2, [25 95 55 115]);
    add_in(path, 'InternalRhoCp_J_m3K', 3, [25 165 55 185]);
    add_in(path, 'InternalDensity_kg_m3', 4, [25 215 55 235]);
    add_in(path, 'InternalViscosity_Pa_s', 5, [25 265 55 285]);
    add_in(path, 'FlowCapacityFactor', 6, [25 315 55 335]);
    add_in(path, 'EfficiencyFactor', 7, [25 365 55 385]);
    add_in(path, 'EffectiveRth_K_W', 8, [25 415 55 435]);

    % Required delivered flow from heat load and effective volumetric Cp.
    add_block('simulink/Signal Routing/Mux', [path '/Flow Inputs'], ...
        'Inputs', '2', 'Position', [105 45 125 115]);
    flow_expr = [ ...
        'u(1)*1000*3600/' ...
        '(((u(2)+abs(u(2)))/2+1e-9)*internal_target_deltaT_K)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/Required Delivered Flow m3_h'], ...
        'Expr', flow_expr, 'Position', [175 55 365 105]);

    % Pump model includes fluid density, viscosity, aeration capacity loss,
    % aeration efficiency loss, and the Excel baseline calibration factor.
    add_block('simulink/Signal Routing/Mux', [path '/Pump Inputs'], ...
        'Inputs', '6', 'Position', [105 145 125 355]);
    pump_expr = [ ...
        'pump_power_calibration_factor*' ...
        '(internal_reference_pressure_drop_Pa*' ...
        '(internal_pipe_length_m/internal_reference_pipe_length_m)*' ...
        '(((u(1)*1000/(((u(2)+abs(u(2)))/2+1e-9)*internal_target_deltaT_K)/' ...
        '((u(5)+abs(u(5)))/2+1e-6))/Vdot_internal_reference_m3s)^2)*' ...
        '(u(3)/rho_internal_kg_m3)*' ...
        '(((u(4)+abs(u(4)))/2+1e-9)/mu_internal_reference_Pas)^mu_pressure_exponent)*' ...
        '(u(1)*1000/(((u(2)+abs(u(2)))/2+1e-9)*internal_target_deltaT_K)/' ...
        '((u(5)+abs(u(5)))/2+1e-6))/' ...
        '(internal_pump_efficiency*((u(6)+abs(u(6)))/2+1e-6)*1000)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/Internal Pump Correlation kW'], ...
        'Expr', pump_expr, 'Position', [175 175 460 245]);

    add_block('simulink/Math Operations/Sum', ...
        [path '/Heat to External kW'], 'Inputs', '++', ...
        'Position', [515 120 565 185]);

    % Internal supply and return temperatures.
    add_block('simulink/Sources/Constant', [path '/HX Approach K'], ...
        'Value', 'HX_approach_K', 'Position', [175 300 255 330]);
    add_block('simulink/Sources/Constant', [path '/Internal DeltaT K'], ...
        'Value', 'internal_target_deltaT_K', ...
        'Position', [175 350 270 380]);
    add_block('simulink/Math Operations/Sum', ...
        [path '/Internal Return C'], 'Inputs', '+++', ...
        'Position', [330 295 380 380]);

    % Chip-temperature proxy uses the live effective thermal resistance.
    add_block('simulink/Signal Routing/Mux', [path '/Chip Inputs'], ...
        'Inputs', '3', 'Position', [515 275 535 385]);
    chip_expr = [ ...
        'u(1)+HX_approach_K+0.5*internal_target_deltaT_K+' ...
        'u(2)*1000/total_coldplate_paths*((u(3)+abs(u(3)))/2)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/Chip Temperature Correlation C'], ...
        'Expr', chip_expr, 'Position', [590 300 790 360]);

    add_out(path, 'HeatToExternal_kW', 1, [940 80 970 100]);
    add_out(path, 'InternalFlow_m3h', 2, [940 140 970 160]);
    add_out(path, 'InternalPump_kW', 3, [940 200 970 220]);
    add_out(path, 'InternalReturn_C', 4, [940 300 970 320]);
    add_out(path, 'ChipTemperature_C', 5, [940 365 970 385]);

    % Displays show actual numeric values during and after simulation.
    display_specs = {
        'Heat to External Display', [805 70 900 105];
        'Internal Flow Display',    [805 130 900 165];
        'Internal Pump Display',    [805 190 900 225];
        'Internal Return Display',  [805 290 900 325];
        'Chip Temperature Display', [805 355 900 390]
    };
    for idx = 1:size(display_specs,1)
        add_block('simulink/Sinks/Display', ...
            [path '/' display_specs{idx,1}], ...
            'Position', display_specs{idx,2});
    end

    % Flow inputs.
    add_line(path, 'HeatFromRacks_kW/1', 'Flow Inputs/1');
    add_line(path, 'InternalRhoCp_J_m3K/1', 'Flow Inputs/2');
    add_line(path, 'Flow Inputs/1', 'Required Delivered Flow m3_h/1');

    % Pump inputs: heat, rhoCp, density, viscosity, capacity, efficiency.
    add_line(path, 'HeatFromRacks_kW/1', 'Pump Inputs/1');
    add_line(path, 'InternalRhoCp_J_m3K/1', 'Pump Inputs/2');
    add_line(path, 'InternalDensity_kg_m3/1', 'Pump Inputs/3');
    add_line(path, 'InternalViscosity_Pa_s/1', 'Pump Inputs/4');
    add_line(path, 'FlowCapacityFactor/1', 'Pump Inputs/5');
    add_line(path, 'EfficiencyFactor/1', 'Pump Inputs/6');
    add_line(path, 'Pump Inputs/1', 'Internal Pump Correlation kW/1');

    add_line(path, 'HeatFromRacks_kW/1', 'Heat to External kW/1');
    add_line(path, 'Internal Pump Correlation kW/1', 'Heat to External kW/2');

    add_line(path, 'ExternalSupply_C/1', 'Internal Return C/1');
    add_line(path, 'HX Approach K/1', 'Internal Return C/2');
    add_line(path, 'Internal DeltaT K/1', 'Internal Return C/3');

    add_line(path, 'ExternalSupply_C/1', 'Chip Inputs/1');
    add_line(path, 'HeatFromRacks_kW/1', 'Chip Inputs/2');
    add_line(path, 'EffectiveRth_K_W/1', 'Chip Inputs/3');
    add_line(path, 'Chip Inputs/1', 'Chip Temperature Correlation C/1');

    connect_output(path, 'Heat to External kW', ...
        'HeatToExternal_kW', 'Heat to External Display');
    connect_output(path, 'Required Delivered Flow m3_h', ...
        'InternalFlow_m3h', 'Internal Flow Display');
    connect_output(path, 'Internal Pump Correlation kW', ...
        'InternalPump_kW', 'Internal Pump Display');
    connect_output(path, 'Internal Return C', ...
        'InternalReturn_C', 'Internal Return Display');
    connect_output(path, 'Chip Temperature Correlation C', ...
        'ChipTemperature_C', 'Chip Temperature Display');
end

function connect_output(path, source_block, output_block, display_block)
    add_line(path, [source_block '/1'], [output_block '/1']);
    add_line(path, [source_block '/1'], [display_block '/1']);
end
