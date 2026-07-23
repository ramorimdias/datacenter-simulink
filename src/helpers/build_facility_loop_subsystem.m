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
    add_in(path, 'FacilityU', 8, [25 415 55 435]);

    add_block('simulink/Signal Routing/Mux', [path '/Flow Inputs'], ...
        'Inputs', '2', 'Position', [105 45 125 115]);
    flow_expr = [ ...
        'u(1)*1000*3600/' ...
        '(((u(2)+abs(u(2)))/2+1e-9)*external_target_deltaT_K)'];
    add_block('simulink/User-Defined Functions/Fcn', ...
        [path '/Required Delivered Flow m3_h'], ...
        'Expr', flow_expr, 'Position', [175 55 365 105]);

    add_block('simulink/Signal Routing/Mux', [path '/Pump Inputs'], ...
        'Inputs', '7', 'Position', [105 145 125 385]);
    add_block('simulink/Signal Routing/Mux', [path '/Pressure Drop Inputs'], ...
        'Inputs', '9', 'Position', [105 410 125 650]);
    add_block('simulink/Sources/Constant', [path '/Fixed Pipe Length m'], 'Value', num2str(evalin('base','external_fixed_pipe_length_m'),15), 'Position', [175 410 275 435]);
    add_block('simulink/Sources/Constant', [path '/U per Rack'], 'Value', num2str(evalin('base','rack_U'),15), 'Position', [175 445 275 470]);
    add_block('simulink/Sources/Constant', [path '/Additional Length per Rack m'], 'Value', num2str(evalin('base','additional_external_pipe_length_per_rack_m'),15), 'Position', [175 480 275 505]);
    add_block('simulink/Math Operations/Product', [path '/Equivalent Rack Count'], 'Inputs', '*/', 'Position', [320 410 375 450]);
    add_block('simulink/Math Operations/Product', [path '/Additional Rack Length'], 'Inputs', '**', 'Position', [410 410 480 450]);
    add_block('simulink/Math Operations/Sum', [path '/Total External Pipe Length m'], 'Inputs', '++', 'Position', [515 410 570 455]);
    add_block('simulink/Sources/Constant', [path '/Pipe Diameter m'], 'Value', num2str(evalin('base','external_pipe_diameter_m'),15), 'Position', [175 445 275 470]);
    add_block('simulink/Sources/Constant', [path '/Pipe Roughness m'], 'Value', num2str(evalin('base','external_pipe_roughness_m'),15), 'Position', [175 480 275 505]);
    add_block('simulink/Sources/Constant', [path '/Fittings K'], 'Value', num2str(evalin('base','external_fittings_loss_coefficient'),15), 'Position', [175 515 275 540]);
    add_block('simulink/Sources/Constant', [path '/Hot Viscosity Pa s'], 'Value', num2str(evalin('base','dynamic_viscosity_external_hot_cP')/1000,15), 'Position', [175 550 275 575]);
    add_block('simulink/Sources/Constant', [path '/Cold Viscosity Pa s'], 'Value', num2str(evalin('base','dynamic_viscosity_external_cold_cP')/1000,15), 'Position', [175 585 275 610]);
    add_block('simulink/Math Operations/Sum', [path '/Hot Cold Viscosity Sum'], 'Inputs', '++', 'Position', [320 620 370 670]);
    add_block('simulink/Math Operations/Gain', [path '/Average Viscosity Pa s'], 'Gain', '0.5', 'Position', [400 625 500 665]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/External Pressure Drop Pa'], ...
        'Expr', ['((0.25/(log10(u(8)/(3.7*u(7))+5.74/((u(3)*(4*(u(1)*1000/' ...
        '((u(2)+1e-9)*external_target_deltaT_K)/(u(5)+1e-6))/(3.14159265*u(7)^2))*' ...
        'u(7)/(u(4)+1e-9))^0.9))^2))*u(6)/u(7)+u(9))*u(3)*' ...
        '(4*(u(1)*1000/((u(2)+1e-9)*external_target_deltaT_K)/(u(5)+1e-6))/(3.14159265*u(7)^2))^2/2'], ...
        'Position', [320 485 560 570]);
    pump_expr = [ ...
        'pump_power_calibration_factor*u(7)*' ...
        '(u(1)*1000/(((u(2)+abs(u(2)))/2+1e-9)*external_target_deltaT_K)/' ...
        '((u(5)+abs(u(5)))/2+1e-6))/(external_pump_efficiency*' ...
        '((u(6)+abs(u(6)))/2+1e-6)*1000)'];
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
    add_line(path, 'Average Viscosity Pa s/1', 'Pump Inputs/4');
    add_line(path, 'FlowCapacityFactor/1', 'Pump Inputs/5');
    add_line(path, 'EfficiencyFactor/1', 'Pump Inputs/6');
    add_line(path, 'External Pressure Drop Pa/1', 'Pump Inputs/7');
    add_line(path, 'Pump Inputs/1', 'External Pump Correlation kW/1');
    add_line(path, 'HeatFromCDU_kW/1', 'Pressure Drop Inputs/1');
    add_line(path, 'ExternalRhoCp_J_m3K/1', 'Pressure Drop Inputs/2');
    add_line(path, 'ExternalDensity_kg_m3/1', 'Pressure Drop Inputs/3');
    add_line(path, 'Average Viscosity Pa s/1', 'Pressure Drop Inputs/4');
    add_line(path, 'Hot Viscosity Pa s/1', 'Hot Cold Viscosity Sum/1');
    add_line(path, 'Cold Viscosity Pa s/1', 'Hot Cold Viscosity Sum/2');
    add_line(path, 'Hot Cold Viscosity Sum/1', 'Average Viscosity Pa s/1');
    add_line(path, 'FlowCapacityFactor/1', 'Pressure Drop Inputs/5');
    add_line(path, 'Fixed Pipe Length m/1', 'Total External Pipe Length m/1');
    add_line(path, 'FacilityU/1', 'Equivalent Rack Count/1');
    add_line(path, 'U per Rack/1', 'Equivalent Rack Count/2');
    add_line(path, 'Equivalent Rack Count/1', 'Additional Rack Length/1');
    add_line(path, 'Additional Length per Rack m/1', 'Additional Rack Length/2');
    add_line(path, 'Additional Rack Length/1', 'Total External Pipe Length m/2');
    add_line(path, 'Total External Pipe Length m/1', 'Pressure Drop Inputs/6');
    add_line(path, 'Pipe Diameter m/1', 'Pressure Drop Inputs/7');
    add_line(path, 'Pipe Roughness m/1', 'Pressure Drop Inputs/8');
    add_line(path, 'Fittings K/1', 'Pressure Drop Inputs/9');
    add_line(path, 'Pressure Drop Inputs/1', 'External Pressure Drop Pa/1');

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
