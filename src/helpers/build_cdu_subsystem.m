function build_cdu_subsystem(path)
%BUILD_CDU_SUBSYSTEM Native CDU and internal-loop hydraulic model.

    add_in(path, 'HeatFromRacks_kW', 1, [25 45 55 65]);
    add_in(path, 'ExternalSupply_C', 2, [25 95 55 115]);
    add_in(path, 'InternalRhoCp_J_m3K', 3, [25 165 55 185]);
    add_in(path, 'InternalDensity_kg_m3', 4, [25 215 55 235]);
    add_in(path, 'InternalViscosity_Pa_s', 5, [25 265 55 285]);
    add_in(path, 'FlowCapacityFactor', 6, [25 315 55 335]);
    add_in(path, 'EfficiencyFactor', 7, [25 365 55 385]);
    add_in(path, 'EffectiveRth_K_W', 8, [25 415 55 435]);
    add_in(path, 'FacilityU', 9, [25 455 55 475]);

    add_block('simulink/Signal Routing/Mux', [path '/Hydraulic Inputs'], ...
        'Inputs', '11', 'Position', [105 430 125 700]);
    add_block('simulink/Sources/Constant', [path '/Fixed Pipe Length m'], 'Value', ...
        num2str(evalin('base','internal_fixed_pipe_length_m'),15), 'Position', [175 430 285 455]);
    add_block('simulink/Sources/Constant', [path '/Pipe Diameter m'], 'Value', ...
        num2str(evalin('base','internal_pipe_diameter_m'),15), 'Position', [175 465 285 490]);
    add_block('simulink/Sources/Constant', [path '/Pipe Roughness m'], 'Value', ...
        num2str(evalin('base','internal_pipe_roughness_m'),15), 'Position', [175 500 285 525]);
    add_block('simulink/Sources/Constant', [path '/Fittings K'], 'Value', ...
        num2str(evalin('base','internal_fittings_loss_coefficient'),15), 'Position', [175 535 285 560]);
    add_block('simulink/Sources/Constant', [path '/Coldplate dP Pa'], 'Value', ...
        num2str(evalin('base','coldplate_pressure_drop_Pa'),15), 'Position', [175 570 285 595]);
    add_block('simulink/Sources/Constant', [path '/Coldplates per U'], 'Value', ...
        num2str(evalin('base','coldplates_per_U'),15), 'Position', [175 605 285 630]);
    add_block('simulink/Math Operations/Product', [path '/Total Coldplate Paths'], ...
        'Inputs', '**', 'Position', [320 605 390 640]);

    deltaT = num2str(evalin('base','internal_target_deltaT_K'),15);
    flow_expr = ['u(1)*1000*3600/(u(2)*' deltaT ')'];
    add_block('simulink/Signal Routing/Mux', [path '/Delivered Flow Inputs'], ...
        'Inputs', '2', 'Position', [270 45 290 105]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Delivered Flow m3_h'], ...
        'Expr', flow_expr, 'Position', [330 55 520 105]);
    add_block('simulink/Signal Routing/Mux', [path '/Pump Flow Inputs'], ...
        'Inputs', '2', 'Position', [300 125 320 185]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Pump Flow m3_h'], ...
        'Expr', 'u(1)/u(2)', 'Position', [350 135 520 175]);

    q_expr = ['u(1)*1000/(u(2)*' deltaT ')/u(5)'];
    re_expr = ['u(3)*(' q_expr ')/(pi*u(7)^2/4)*u(7)/u(4)'];
    r_safe = ['sqrt((' re_expr ')^2+1e-12)'];
    w_expr = ['0.5*(1+((' r_safe ')-4000)/sqrt(((' r_safe ')-4000)^2+1))'];
    f_expr = ['(1-(' w_expr '))*(64/(' r_safe '))+(' w_expr ')*0.25/(log10(u(8)/(3.7*u(7))+5.74/(' r_safe ')^0.9)^2)'];
    dp_expr = ['((' f_expr ')*u(6)/u(7)+u(9))*u(3)*(((' q_expr ')/(pi*u(7)^2/4))^2)/2+u(10)'];
    add_block('simulink/User-Defined Functions/Fcn', [path '/Internal Reynolds Number'], ...
        'Expr', re_expr, 'Position', [560 440 790 480]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Internal Friction Factor'], ...
        'Expr', f_expr, 'Position', [560 500 790 540]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Internal Pressure Drop Pa'], ...
        'Expr', dp_expr, 'Position', [560 560 790 620]);

    add_block('simulink/Signal Routing/Mux', [path '/Pump Power Inputs'], ...
        'Inputs', '3', 'Position', [560 190 580 270]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Internal Pump Power kW'], ...
        'Expr', 'u(1)*u(2)/3600/(u(3)*1000)', ...
        'Position', [620 195 850 245]);
    add_block('simulink/Signal Routing/Mux', [path '/Branch Flow Inputs'], ...
        'Inputs', '2', 'Position', [560 650 580 710]);
    add_block('simulink/User-Defined Functions/Fcn', [path '/Coldplate Branch Flow m3_h'], ...
        'Expr', 'u(1)/u(2)', 'Position', [620 660 850 700]);

    add_block('simulink/Math Operations/Sum', [path '/Heat to External kW'], ...
        'Inputs', '++', 'Position', [870 120 920 180]);
    add_block('simulink/Sources/Constant', [path '/HX Approach K'], ...
        'Value', num2str(evalin('base','HX_approach_K'),15), 'Position', [350 300 450 330]);
    add_block('simulink/Sources/Constant', [path '/Internal DeltaT K'], ...
        'Value', deltaT, 'Position', [350 345 450 375]);
    add_block('simulink/Math Operations/Sum', [path '/Internal Return C'], ...
        'Inputs', '+++', 'Position', [500 300 550 380]);
    add_block('simulink/Signal Routing/Mux', [path '/Chip Inputs'], ...
        'Inputs', '3', 'Position', [870 285 890 385]);
    chip_expr = ['u(1)+HX_approach_K+0.5*internal_target_deltaT_K+' ...
        'u(2)*1000/total_coldplate_paths*u(3)'];
    add_block('simulink/User-Defined Functions/Fcn', [path '/Chip Temperature Correlation C'], ...
        'Expr', chip_expr, 'Position', [925 315 1135 365]);

    add_out(path, 'HeatToExternal_kW', 1, [1250 80 1280 100]);
    add_out(path, 'InternalFlow_m3h', 2, [1250 140 1280 160]);
    add_out(path, 'InternalPump_kW', 3, [1250 200 1280 220]);
    add_out(path, 'InternalReturn_C', 4, [1250 300 1280 320]);
    add_out(path, 'ChipTemperature_C', 5, [1250 365 1280 385]);

    diagnostics = {
        'Delivered Flow Display', [1040 60 1170 95], 'Delivered Flow m3_h';
        'Pump Flow Display',      [1040 120 1170 155], 'Pump Flow m3_h';
        'Pump Power Display',     [1040 180 1170 215], 'Internal Pump Power kW';
        'Pressure Drop Display',  [820 555 970 590], 'Internal Pressure Drop Pa';
        'Reynolds Display',       [820 435 970 470], 'Internal Reynolds Number';
        'Friction Display',       [820 495 970 530], 'Internal Friction Factor'
        ;'Branch Flow Display',   [820 650 970 685], 'Coldplate Branch Flow m3_h'
    };
    for i = 1:size(diagnostics,1)
        add_block('simulink/Sinks/Display', [path '/' diagnostics{i,1}], 'Position', diagnostics{i,2});
    end

    add_line(path, 'HeatFromRacks_kW/1', 'Hydraulic Inputs/1');
    add_line(path, 'InternalRhoCp_J_m3K/1', 'Hydraulic Inputs/2');
    add_line(path, 'InternalDensity_kg_m3/1', 'Hydraulic Inputs/3');
    add_line(path, 'InternalViscosity_Pa_s/1', 'Hydraulic Inputs/4');
    add_line(path, 'FlowCapacityFactor/1', 'Hydraulic Inputs/5');
    add_line(path, 'Fixed Pipe Length m/1', 'Hydraulic Inputs/6');
    add_line(path, 'Pipe Diameter m/1', 'Hydraulic Inputs/7');
    add_line(path, 'Pipe Roughness m/1', 'Hydraulic Inputs/8');
    add_line(path, 'Fittings K/1', 'Hydraulic Inputs/9');
    add_line(path, 'Coldplate dP Pa/1', 'Hydraulic Inputs/10');
    add_line(path, 'FacilityU/1', 'Total Coldplate Paths/1');
    add_line(path, 'Coldplates per U/1', 'Total Coldplate Paths/2');
    add_line(path, 'Total Coldplate Paths/1', 'Hydraulic Inputs/11');
    add_line(path, 'Hydraulic Inputs/1', 'Internal Reynolds Number/1');
    add_line(path, 'Hydraulic Inputs/1', 'Internal Friction Factor/1');
    add_line(path, 'Hydraulic Inputs/1', 'Internal Pressure Drop Pa/1');
    add_line(path, 'Internal Pressure Drop Pa/1', 'Pump Power Inputs/1');
    add_line(path, 'Pump Flow m3_h/1', 'Pump Power Inputs/2');
    add_line(path, 'EfficiencyFactor/1', 'Pump Power Inputs/3');

    add_line(path, 'HeatFromRacks_kW/1', 'Delivered Flow Inputs/1');
    add_line(path, 'InternalRhoCp_J_m3K/1', 'Delivered Flow Inputs/2');
    add_line(path, 'Delivered Flow Inputs/1', 'Delivered Flow m3_h/1');
    add_line(path, 'Delivered Flow m3_h/1', 'Pump Flow Inputs/1');
    add_line(path, 'FlowCapacityFactor/1', 'Pump Flow Inputs/2');
    add_line(path, 'Pump Flow Inputs/1', 'Pump Flow m3_h/1');
    add_line(path, 'Pump Power Inputs/1', 'Internal Pump Power kW/1');
    add_line(path, 'HeatFromRacks_kW/1', 'Heat to External kW/1');
    add_line(path, 'Internal Pump Power kW/1', 'Heat to External kW/2');
    add_line(path, 'Pump Flow m3_h/1', 'Branch Flow Inputs/1');
    add_line(path, 'Total Coldplate Paths/1', 'Branch Flow Inputs/2');
    add_line(path, 'Branch Flow Inputs/1', 'Coldplate Branch Flow m3_h/1');
    add_line(path, 'ExternalSupply_C/1', 'Internal Return C/1');
    add_line(path, 'HX Approach K/1', 'Internal Return C/2');
    add_line(path, 'Internal DeltaT K/1', 'Internal Return C/3');
    add_line(path, 'ExternalSupply_C/1', 'Chip Inputs/1');
    add_line(path, 'HeatFromRacks_kW/1', 'Chip Inputs/2');
    add_line(path, 'EffectiveRth_K_W/1', 'Chip Inputs/3');
    add_line(path, 'Chip Inputs/1', 'Chip Temperature Correlation C/1');

    connect_output(path, 'Heat to External kW', 'HeatToExternal_kW');
    connect_output(path, 'Delivered Flow m3_h', 'InternalFlow_m3h');
    connect_output(path, 'Internal Pump Power kW', 'InternalPump_kW');
    connect_output(path, 'Internal Return C', 'InternalReturn_C');
    connect_output(path, 'Chip Temperature Correlation C', 'ChipTemperature_C');
    add_line(path, 'Delivered Flow m3_h/1', 'Delivered Flow Display/1');
    add_line(path, 'Pump Flow m3_h/1', 'Pump Flow Display/1');
    add_line(path, 'Internal Pump Power kW/1', 'Pump Power Display/1');
    add_line(path, 'Internal Pressure Drop Pa/1', 'Pressure Drop Display/1');
    add_line(path, 'Internal Reynolds Number/1', 'Reynolds Display/1');
    add_line(path, 'Internal Friction Factor/1', 'Friction Display/1');
    add_line(path, 'Coldplate Branch Flow m3_h/1', 'Branch Flow Display/1');
end

function connect_output(path, source_block, output_block)
    add_line(path, [source_block '/1'], [output_block '/1']);
end
