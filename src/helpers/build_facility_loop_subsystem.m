function build_facility_loop_subsystem(path)
%BUILD_FACILITY_LOOP_SUBSYSTEM Reduced-order external PG25 loop.
%
% Fluid mixture and aeration derating values are explicit input signals so
% the operating point responds immediately to interactive parameter changes.

    add_in(path, 'HeatFromCDU_kW', 1, [25 45 55 65]);
    add_in(path, 'TowerSupply_C', 2, [25 95 55 115]);
    add_in(path, 'ExternalRhoCp_J_m3K', 3, [25 165 55 185]);
    add_in(path, 'ExternalDensity_kg_m3', 4, [25 215 55 235]);
    add_in(path, 'ExternalViscosity_Pa_s', 5, [25 265 55 285]);
    add_in(path, 'FlowCapacityFactor', 6, [25 315 55 335]);
    add_in(path, 'EfficiencyFactor', 7, [25 365 55 385]);

    add_block('simulink/Signal Routing/Mux', [path '/Flow Inputs'], ...
        'Inputs', '2', 'Position', [105 45 125 115]);
    flow_expr = [ ...
        'u(1)*1000*3600/' ...
        '(((u(2)+abs(u(2)))/2+1e-9)*external_target_deltaT_K)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/Required Delivered Flow m3_h'], ...
        'Expr', flow_expr, 'Position', [175 55 365 105]);

    add_block('simulink/Signal Routing/Mux', [path '/Pump Inputs'], ...
        'Inputs', '6', 'Position', [105 145 125 355]);
    pump_expr = [ ...
        'pump_power_calibration_factor*' ...
        '(external_reference_pressure_drop_Pa*' ...
        '(external_pipe_length_m/external_reference_pipe_length_m)*' ...
        '(((u(1)*1000/(((u(2)+abs(u(2)))/2+1e-9)*external_target_deltaT_K)/' ...
        '((u(5)+abs(u(5)))/2+1e-6))/Vdot_external_reference_m3s)^2)*' ...
        '(u(3)/rho_external_kg_m3)*' ...
        '(((u(4)+abs(u(4)))/2+1e-9)/mu_external_reference_Pas)^mu_pressure_exponent)*' ...
        '(u(1)*1000/(((u(2)+abs(u(2)))/2+1e-9)*external_target_deltaT_K)/' ...
        '((u(5)+abs(u(5)))/2+1e-6))/' ...
        '(external_pump_efficiency*((u(6)+abs(u(6)))/2+1e-6)*1000)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/External Pump Correlation kW'], ...
        'Expr', pump_expr, 'Position', [175 175 460 245]);

    add_block('simulink/Math Operations/Sum', ...
        [path '/Heat to Tower kW'], 'Inputs', '++', ...
        'Position', [515 120 565 185]);

    add_block('simulink/Sources/Constant', [path '/External DeltaT K'], ...
        'Value', 'external_target_deltaT_K', ...
        'Position', [175 350 270 380]);
    add_block('simulink/Math Operations/Sum', ...
        [path '/External Return C'], 'Inputs', '++', ...
        'Position', [330 315 380 380]);

    add_out(path, 'HeatToTower_kW', 1, [885 80 915 100]);
    add_out(path, 'ExternalFlow_m3h', 2, [885 140 915 160]);
    add_out(path, 'ExternalPump_kW', 3, [885 200 915 220]);
    add_out(path, 'ExternalReturn_C', 4, [885 300 915 320]);
    add_out(path, 'LoopDeltaT_K', 5, [885 360 915 380]);

    display_specs = {
        'Heat to Tower Display',  [720 70 825 105];
        'External Flow Display',  [720 130 825 165];
        'External Pump Display',  [720 190 825 225];
        'External Return Display',[720 290 825 325];
        'Loop DeltaT Display',    [720 350 825 385]
    };
    for idx = 1:size(display_specs,1)
        add_block('simulink/Sinks/Display', ...
            [path '/' display_specs{idx,1}], ...
            'Position', display_specs{idx,2});
    end

    add_line(path, 'HeatFromCDU_kW/1', 'Flow Inputs/1');
    add_line(path, 'ExternalRhoCp_J_m3K/1', 'Flow Inputs/2');
    add_line(path, 'Flow Inputs/1', 'Required Delivered Flow m3_h/1');

    add_line(path, 'HeatFromCDU_kW/1', 'Pump Inputs/1');
    add_line(path, 'ExternalRhoCp_J_m3K/1', 'Pump Inputs/2');
    add_line(path, 'ExternalDensity_kg_m3/1', 'Pump Inputs/3');
    add_line(path, 'ExternalViscosity_Pa_s/1', 'Pump Inputs/4');
    add_line(path, 'FlowCapacityFactor/1', 'Pump Inputs/5');
    add_line(path, 'EfficiencyFactor/1', 'Pump Inputs/6');
    add_line(path, 'Pump Inputs/1', 'External Pump Correlation kW/1');

    add_line(path, 'HeatFromCDU_kW/1', 'Heat to Tower kW/1');
    add_line(path, 'External Pump Correlation kW/1', 'Heat to Tower kW/2');

    add_line(path, 'TowerSupply_C/1', 'External Return C/1');
    add_line(path, 'External DeltaT K/1', 'External Return C/2');

    connect_output(path, 'Heat to Tower kW', ...
        'HeatToTower_kW', 'Heat to Tower Display');
    connect_output(path, 'Required Delivered Flow m3_h', ...
        'ExternalFlow_m3h', 'External Flow Display');
    connect_output(path, 'External Pump Correlation kW', ...
        'ExternalPump_kW', 'External Pump Display');
    connect_output(path, 'External Return C', ...
        'ExternalReturn_C', 'External Return Display');
    connect_output(path, 'External DeltaT K', ...
        'LoopDeltaT_K', 'Loop DeltaT Display');
end

function connect_output(path, source_block, output_block, display_block)
    add_line(path, [source_block '/1'], [output_block '/1']);
    add_line(path, [source_block '/1'], [display_block '/1']);
end
