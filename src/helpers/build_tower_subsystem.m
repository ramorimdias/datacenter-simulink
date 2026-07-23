function build_tower_subsystem(path)
% Reduced-order closed-circuit cooling-tower black box.
    add_in(path, 'HeatLoad_kW', 1, [25 45 55 65]);
    add_in(path, 'Flow_m3h', 2, [25 115 55 135]);
    add_in(path, 'LoopDeltaT_K', 3, [25 185 55 205]);
    add_in(path, 'AmbientWetBulb_C', 4, [25 255 55 275]);
    add_in(path, 'ExternalLoopEfficiencyFactor', 5, [25 325 55 345]);
    add_in(path, 'TowerDesignHeat_kW', 6, [25 365 55 385]);
    add_in(path, 'TowerDesignFlow_m3h', 7, [25 405 55 425]);
    add_in(path, 'TowerMinimumFlowRatio', 8, [25 445 55 465]);
    add_in(path, 'TowerDesignRange_K', 9, [25 485 55 505]);
    add_in(path, 'TowerDesignWetBulb_C', 10, [25 525 55 545]);
    add_in(path, 'TowerDesignApproach_K', 11, [25 565 55 585]);
    add_in(path, 'TowerLoadSensitivity_K', 12, [25 605 55 625]);
    add_in(path, 'TowerLowFlowSensitivity_K', 13, [25 645 55 665]);
    add_in(path, 'TowerAmbientPowerSensitivity_per_K', 14, [25 685 55 705]);
    add_in(path, 'TowerFanDesign_kW', 15, [25 725 55 745]);
    add_in(path, 'TowerSprayPumpDesign_kW', 16, [25 765 55 785]);

    % Load ratio.
    add_block('simulink/Math Operations/Product', [path '/Load Ratio'], ...
        'Inputs', '*/', ...
        'Position', [105 35 195 75]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Load Ratio Limited'], 'LowerLimit', '0', ...
        'UpperLimit', '1.2', 'Position', [235 35 315 75]);
    add_block('simulink/Math Operations/Math Function', ...
        [path '/Load Ratio Squared'], 'Operator', 'square', ...
        'Position', [355 40 420 75]);
    add_block('simulink/Math Operations/Product', ...
        [path '/Aeration Adjusted Load Ratio'], 'Inputs', '*/', ...
        'Position', [440 35 510 75]);

    % Flow ratio and low-flow penalty.
    add_block('simulink/Math Operations/Product', [path '/Flow Ratio'], ...
        'Inputs', '*/', ...
        'Position', [105 105 195 145]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Flow Ratio Limited'], ...
        'LowerLimit', 'tower_minimum_flow_ratio', ...
        'UpperLimit', '2', 'Position', [235 105 315 145]);
    add_block('simulink/Sources/Constant', [path '/One'], ...
        'Value', '1', 'Position', [355 115 395 135]);
    add_block('simulink/Math Operations/Sum', [path '/Low Flow Deficit'], ...
        'Inputs', '+-', 'Position', [440 95 485 155]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Positive Flow Deficit'], ...
        'LowerLimit', '0', 'UpperLimit', '2', ...
        'Position', [525 105 605 145]);

    % Loop range ratio.
    add_block('simulink/Math Operations/Product', [path '/Range Ratio'], ...
        'Inputs', '*/', 'Position', [235 170 290 220]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Range Ratio Limited'], 'LowerLimit', '0.2', ...
        'UpperLimit', '2', 'Position', [335 175 415 215]);

    % Ambient-temperature power correction.
    add_block('simulink/Math Operations/Sum', [path '/Wet Bulb Excess K'], ...
        'Inputs', '+-', 'Position', [250 235 300 290]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Positive Wet Bulb Excess'], 'LowerLimit', '0', ...
        'UpperLimit', '30', 'Position', [345 245 440 275]);
    add_block('simulink/Math Operations/Product', [path '/Ambient Penalty'], ...
        'Inputs', '**', ...
        'Position', [485 240 595 280]);
    add_block('simulink/Sources/Constant', [path '/Ambient Base'], ...
        'Value', '1', 'Position', [485 305 525 325]);
    add_block('simulink/Math Operations/Sum', [path '/Ambient Factor'], ...
        'Inputs', '++', 'Position', [640 255 685 320]);

    % Supply temperature.
    add_block('simulink/Math Operations/Product', [path '/Load Approach'], ...
        'Inputs', '**', ...
        'Position', [655 35 755 75]);
    add_block('simulink/Math Operations/Product', [path '/Flow Approach'], ...
        'Inputs', '**', ...
        'Position', [655 175 755 215]);
    add_block('simulink/Math Operations/Sum', [path '/Supply Temperature C'], ...
        'Inputs', '++++', 'Position', [820 95 870 220]);

    % Fan and spray-pump power.
    add_block('simulink/Math Operations/Product', [path '/Fan Demand'], ...
        'Inputs', '***', 'Position', [760 285 820 350]);
    add_block('simulink/Discontinuities/Saturation', ...
        [path '/Fan Demand Limited'], 'LowerLimit', '0', ...
        'UpperLimit', '1', 'Position', [865 295 945 335]);
    add_block('simulink/Math Operations/Math Function', ...
        [path '/Fan Demand Squared'], 'Operator', 'square', ...
        'Position', [990 295 1055 330]);
    add_block('simulink/Math Operations/Product', [path '/Fan Demand Cubed'], ...
        'Inputs', '**', 'Position', [1100 285 1160 340]);
    add_block('simulink/Math Operations/Product', [path '/Fan Power kW'], ...
        'Inputs', '**', ...
        'Position', [1205 290 1305 335]);
    add_block('simulink/Math Operations/Product', [path '/Spray Pump Power kW'], ...
        'Inputs', '**', ...
        'Position', [865 385 990 425]);
    add_block('simulink/Math Operations/Sum', [path '/Tower Power kW'], ...
        'Inputs', '++', 'Position', [1100 375 1150 435]);

    add_block('simulink/Math Operations/Sum', [path '/Capacity Margin kW'], ...
        'Inputs', '+-', 'Position', [1010 455 1060 520]);

    add_out(path, 'SupplyTemperature_C', 1, [1380 145 1410 165]);
    add_out(path, 'TowerPower_kW', 2, [1380 400 1410 420]);
    add_out(path, 'FanPower_kW', 3, [1380 310 1410 330]);
    add_out(path, 'SprayPumpPower_kW', 4, [1380 455 1410 475]);
    add_out(path, 'CapacityMargin_kW', 5, [1380 510 1410 530]);

    add_line(path, 'HeatLoad_kW/1', 'Load Ratio/1');
    add_line(path, 'TowerDesignHeat_kW/1', 'Load Ratio/2');
    add_line(path, 'Load Ratio/1', 'Load Ratio Limited/1');
    add_line(path, 'Load Ratio Limited/1', 'Aeration Adjusted Load Ratio/1');
    add_line(path, 'ExternalLoopEfficiencyFactor/1', 'Aeration Adjusted Load Ratio/2');
    add_line(path, 'Aeration Adjusted Load Ratio/1', 'Load Ratio Squared/1');

    add_line(path, 'Flow_m3h/1', 'Flow Ratio/1');
    add_line(path, 'TowerDesignFlow_m3h/1', 'Flow Ratio/2');
    add_line(path, 'Flow Ratio/1', 'Flow Ratio Limited/1');
    add_line(path, 'One/1', 'Low Flow Deficit/1');
    add_line(path, 'Flow Ratio Limited/1', 'Low Flow Deficit/2');
    add_line(path, 'Low Flow Deficit/1', 'Positive Flow Deficit/1');

    add_line(path, 'LoopDeltaT_K/1', 'Range Ratio/1');
    add_line(path, 'TowerDesignRange_K/1', 'Range Ratio/2');
    add_line(path, 'Range Ratio/1', 'Range Ratio Limited/1');

    add_line(path, 'AmbientWetBulb_C/1', 'Wet Bulb Excess K/1');
    add_line(path, 'TowerDesignWetBulb_C/1', 'Wet Bulb Excess K/2');
    add_line(path, 'Wet Bulb Excess K/1', 'Positive Wet Bulb Excess/1');
    add_line(path, 'Positive Wet Bulb Excess/1', 'Ambient Penalty/1');
    add_line(path, 'TowerAmbientPowerSensitivity_per_K/1', 'Ambient Penalty/2');
    add_line(path, 'Ambient Base/1', 'Ambient Factor/1');
    add_line(path, 'Ambient Penalty/1', 'Ambient Factor/2');

    add_line(path, 'Load Ratio Squared/1', 'Load Approach/1');
    add_line(path, 'TowerLoadSensitivity_K/1', 'Load Approach/2');
    add_line(path, 'Positive Flow Deficit/1', 'Flow Approach/1');
    add_line(path, 'TowerLowFlowSensitivity_K/1', 'Flow Approach/2');
    add_line(path, 'AmbientWetBulb_C/1', 'Supply Temperature C/1');
    add_line(path, 'TowerDesignApproach_K/1', 'Supply Temperature C/2');
    add_line(path, 'Load Approach/1', 'Supply Temperature C/3');
    add_line(path, 'Flow Approach/1', 'Supply Temperature C/4');
    add_line(path, 'Supply Temperature C/1', 'SupplyTemperature_C/1');

    add_line(path, 'Aeration Adjusted Load Ratio/1', 'Fan Demand/1');
    add_line(path, 'Range Ratio Limited/1', 'Fan Demand/2');
    add_line(path, 'Ambient Factor/1', 'Fan Demand/3');
    add_line(path, 'Fan Demand/1', 'Fan Demand Limited/1');
    add_line(path, 'Fan Demand Limited/1', 'Fan Demand Squared/1');
    add_line(path, 'Fan Demand Squared/1', 'Fan Demand Cubed/1');
    add_line(path, 'Fan Demand Limited/1', 'Fan Demand Cubed/2');
    add_line(path, 'Fan Demand Cubed/1', 'Fan Power kW/1');
    add_line(path, 'TowerFanDesign_kW/1', 'Fan Power kW/2');
    add_line(path, 'Aeration Adjusted Load Ratio/1', 'Spray Pump Power kW/1');
    add_line(path, 'TowerSprayPumpDesign_kW/1', 'Spray Pump Power kW/2');
    add_line(path, 'Fan Power kW/1', 'Tower Power kW/1');
    add_line(path, 'Spray Pump Power kW/1', 'Tower Power kW/2');

    add_line(path, 'TowerDesignHeat_kW/1', 'Capacity Margin kW/1');
    add_line(path, 'HeatLoad_kW/1', 'Capacity Margin kW/2');

    add_line(path, 'Tower Power kW/1', 'TowerPower_kW/1');
    add_line(path, 'Fan Power kW/1', 'FanPower_kW/1');
    add_line(path, 'Spray Pump Power kW/1', 'SprayPumpPower_kW/1');
    add_line(path, 'Capacity Margin kW/1', 'CapacityMargin_kW/1');
end
