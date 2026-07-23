function build_facility_loop_subsystem(path)
%BUILD_FACILITY_LOOP_SUBSYSTEM Native external-loop hydraulic model.

    add_in(path, 'HeatFromCDU_kW', 1, [25 45 55 65]);
    add_in(path, 'TowerSupply_C', 2, [25 95 55 115]);
    add_in(path, 'ExternalRhoCp_J_m3K', 3, [25 165 55 185]);
    add_in(path, 'ExternalDensity_kg_m3', 4, [25 215 55 235]);
    add_in(path, 'ExternalViscosity_Pa_s', 5, [25 265 55 285]);
    add_in(path, 'FlowCapacityFactor', 6, [25 315 55 335]);
    add_in(path, 'EfficiencyFactor', 7, [25 365 55 385]);
    add_in(path, 'FacilityU', 8, [25 415 55 435]);

    add_block('simulink/Sources/Constant', [path '/Fixed Pipe Length m'], 'Value', ...
        num2str(evalin('base','external_fixed_pipe_length_m'),15), 'Position', [175 430 285 455]);
    add_block('simulink/Sources/Constant', [path '/U per Rack'], 'Value', ...
        num2str(evalin('base','rack_U'),15), 'Position', [175 470 285 495]);
    add_block('simulink/Sources/Constant', [path '/Additional Length per Rack m'], 'Value', ...
        num2str(evalin('base','additional_external_pipe_length_per_rack_m'),15), 'Position', [175 510 285 535]);
    add_block('simulink/Sources/Constant', [path '/Pipe Diameter m'], 'Value', ...
        num2str(evalin('base','external_pipe_diameter_m'),15), 'Position', [175 550 285 575]);
    add_block('simulink/Sources/Constant', [path '/Pipe Roughness m'], 'Value', ...
        num2str(evalin('base','external_pipe_roughness_m'),15), 'Position', [175 590 285 615]);
    add_block('simulink/Sources/Constant', [path '/Fittings K'], 'Value', ...
        num2str(evalin('base','external_fittings_loss_coefficient'),15), 'Position', [175 630 285 655]);
    add_block('simulink/Math Operations/Product', [path '/Equivalent Rack Count'], ...
        'Inputs', '*/', 'Position', [350 435 420 475]);
    add_block('simulink/Math Operations/Product', [path '/Additional Rack Length'], ...
        'Inputs', '**', 'Position', [455 435 525 475]);
    add_block('simulink/Math Operations/Sum', [path '/Total External Pipe Length m'], ...
        'Inputs', '++', 'Position', [560 435 620 475]);

    add_block('simulink/Signal Routing/Mux', [path '/Hydraulic Inputs'], ...
        'Inputs', '9', 'Position', [330 500 350 735]);
    deltaT = num2str(evalin('base','external_target_deltaT_K'),15);
    flow_expr = ['u(1)*1000*3600/(u(2)*' deltaT ')'];
    add_block('simulink/User-Defined Functions/Fcn', [path '/Delivered Flow m3_h'], ...
        'Expr', flow_expr, 'Position', [390 55 580 105]);
    add_block('simulink/Signal Routing/Mux', [path '/Pump Flow Inputs'], ...
        'Inputs', '2', 'Position', [390 125 410 185]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Pump Flow m3_h'], ...
        'Expr', 'u(1)/u(2)', 'Position', [440 135 610 175]);

    q_expr = ['u(1)*1000/(u(2)*' deltaT ')/u(5)'];
    re_expr = ['u(3)*(' q_expr ')/(pi*u(7)^2/4)*u(7)/u(4)'];
    r_safe = ['sqrt((' re_expr ')^2+1e-12)'];
    w_expr = ['0.5*(1+((' r_safe ')-4000)/sqrt(((' r_safe ')-4000)^2+1))'];
    f_expr = ['(1-(' w_expr '))*(64/(' r_safe '))+(' w_expr ')*0.25/(log10(u(8)/(3.7*u(7))+5.74/(' r_safe ')^0.9)^2)'];
    dp_expr = ['((' f_expr ')*u(6)/u(7)+u(9))*u(3)*(((' q_expr ')/(pi*u(7)^2/4))^2)/2'];
    add_block('simulink/User-Defined Functions/Fcn', [path '/External Reynolds Number'], ...
        'Expr', re_expr, 'Position', [650 515 880 555]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/External Friction Factor'], ...
        'Expr', f_expr, 'Position', [650 575 880 615]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/External Pressure Drop Pa'], ...
        'Expr', dp_expr, 'Position', [650 635 880 695]);
    add_block('simulink/Signal Routing/Mux', [path '/Pump Power Inputs'], ...
        'Inputs', '3', 'Position', [650 195 670 275]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/External Pump Power kW'], ...
        'Expr', 'u(1)*u(2)/3600/(u(3)*1000)', ...
        'Position', [700 200 930 250]);

    add_block('simulink/Math Operations/Sum', [path '/Heat to Tower kW'], ...
        'Inputs', '++', 'Position', [960 120 1010 180]);
    add_block('simulink/Sources/Constant', [path '/External DeltaT K'], ...
        'Value', deltaT, 'Position', [440 300 540 330]);
    add_block('simulink/Math Operations/Sum', [path '/External Return C'], ...
        'Inputs', '++', 'Position', [580 300 630 370]);

    add_out(path, 'HeatToTower_kW', 1, [1250 80 1280 100]);
    add_out(path, 'ExternalFlow_m3h', 2, [1250 140 1280 160]);
    add_out(path, 'ExternalPump_kW', 3, [1250 200 1280 220]);
    add_out(path, 'ExternalReturn_C', 4, [1250 300 1280 320]);
    add_out(path, 'LoopDeltaT_K', 5, [1250 360 1280 380]);

    diagnostics = {
        'Delivered Flow Display', [1040 60 1170 95], 'Delivered Flow m3_h';
        'Pump Flow Display',      [1040 120 1170 155], 'Pump Flow m3_h';
        'Pump Power Display',     [1040 180 1170 215], 'External Pump Power kW';
        'Pressure Drop Display',  [900 635 1050 670], 'External Pressure Drop Pa';
        'Reynolds Display',       [900 515 1050 550], 'External Reynolds Number';
        'Friction Display',       [900 575 1050 610], 'External Friction Factor';
        'Rack Count Display',     [350 380 500 415], 'Equivalent Rack Count';
        'Pipe Length Display',    [520 380 700 415], 'Total External Pipe Length m'
    };
    for i = 1:size(diagnostics,1)
        add_block('simulink/Sinks/Display', [path '/' diagnostics{i,1}], 'Position', diagnostics{i,2});
    end

    add_line(path, 'FacilityU/1', 'Equivalent Rack Count/1');
    add_line(path, 'U per Rack/1', 'Equivalent Rack Count/2');
    add_line(path, 'Equivalent Rack Count/1', 'Additional Rack Length/1');
    add_line(path, 'Additional Length per Rack m/1', 'Additional Rack Length/2');
    add_line(path, 'Fixed Pipe Length m/1', 'Total External Pipe Length m/1');
    add_line(path, 'Additional Rack Length/1', 'Total External Pipe Length m/2');

    add_line(path, 'HeatFromCDU_kW/1', 'Hydraulic Inputs/1');
    add_line(path, 'ExternalRhoCp_J_m3K/1', 'Hydraulic Inputs/2');
    add_line(path, 'ExternalDensity_kg_m3/1', 'Hydraulic Inputs/3');
    add_line(path, 'ExternalViscosity_Pa_s/1', 'Hydraulic Inputs/4');
    add_line(path, 'FlowCapacityFactor/1', 'Hydraulic Inputs/5');
    add_line(path, 'Total External Pipe Length m/1', 'Hydraulic Inputs/6');
    add_line(path, 'Pipe Diameter m/1', 'Hydraulic Inputs/7');
    add_line(path, 'Pipe Roughness m/1', 'Hydraulic Inputs/8');
    add_line(path, 'Fittings K/1', 'Hydraulic Inputs/9');
    add_line(path, 'Hydraulic Inputs/1', 'External Reynolds Number/1');
    add_line(path, 'Hydraulic Inputs/1', 'External Friction Factor/1');
    add_line(path, 'Hydraulic Inputs/1', 'External Pressure Drop Pa/1');
    add_line(path, 'External Pressure Drop Pa/1', 'Pump Power Inputs/1');
    add_line(path, 'Pump Flow m3_h/1', 'Pump Power Inputs/2');
    add_line(path, 'EfficiencyFactor/1', 'Pump Power Inputs/3');
    add_line(path, 'HeatFromCDU_kW/1', 'Delivered Flow m3_h/1');
    add_line(path, 'Delivered Flow m3_h/1', 'Pump Flow Inputs/1');
    add_line(path, 'FlowCapacityFactor/1', 'Pump Flow Inputs/2');
    add_line(path, 'Pump Flow Inputs/1', 'Pump Flow m3_h/1');
    add_line(path, 'Pump Power Inputs/1', 'External Pump Power kW/1');
    add_line(path, 'HeatFromCDU_kW/1', 'Heat to Tower kW/1');
    add_line(path, 'External Pump Power kW/1', 'Heat to Tower kW/2');
    add_line(path, 'TowerSupply_C/1', 'External Return C/1');
    add_line(path, 'External DeltaT K/1', 'External Return C/2');

    connect_output(path, 'Heat to Tower kW', 'HeatToTower_kW');
    connect_output(path, 'Delivered Flow m3_h', 'ExternalFlow_m3h');
    connect_output(path, 'External Pump Power kW', 'ExternalPump_kW');
    connect_output(path, 'External Return C', 'ExternalReturn_C');
    connect_output(path, 'External DeltaT K', 'LoopDeltaT_K');
    add_line(path, 'Delivered Flow m3_h/1', 'Delivered Flow Display/1');
    add_line(path, 'Pump Flow m3_h/1', 'Pump Flow Display/1');
    add_line(path, 'External Pump Power kW/1', 'Pump Power Display/1');
    add_line(path, 'External Pressure Drop Pa/1', 'Pressure Drop Display/1');
    add_line(path, 'External Reynolds Number/1', 'Reynolds Display/1');
    add_line(path, 'External Friction Factor/1', 'Friction Display/1');
    add_line(path, 'Equivalent Rack Count/1', 'Rack Count Display/1');
    add_line(path, 'Total External Pipe Length m/1', 'Pipe Length Display/1');
end

function connect_output(path, source_block, output_block)
    add_line(path, [source_block '/1'], [output_block '/1']);
end
