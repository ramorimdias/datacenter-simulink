function build_energy_cost_subsystem(path)
    add_in(path, 'ITPower_kW', 1, [25 45 55 65]);
    add_in(path, 'InternalPump_kW', 2, [25 105 55 125]);
    add_in(path, 'ExternalPump_kW', 3, [25 165 55 185]);
    add_in(path, 'TowerPower_kW', 4, [25 225 55 245]);
    add_in(path, 'ElectricityPrice', 5, [25 355 55 375]);
    add_in(path, 'OperatingMonths', 6, [25 415 55 435]);

    add_block('simulink/Sources/Constant', [path '/Facility Aux kW'], ...
        'Value', 'facility_auxiliary_power_kW', ...
        'Position', [105 275 195 305]);
    add_block('simulink/Math Operations/Sum', [path '/Facility Power kW'], ...
        'Inputs', '+++++', 'Position', [265 90 320 220]);

    add_block('simulink/Sources/Constant', [path '/PUE Epsilon'], ...
        'Value', '1e-9', 'Position', [370 260 425 290]);
    add_block('simulink/Math Operations/Sum', [path '/IT plus epsilon'], ...
        'Inputs', '++', 'Position', [470 210 515 275]);
    add_block('simulink/Math Operations/Product', ...
        [path '/Instantaneous PUE'], 'Inputs', '*/', ...
        'Position', [570 115 625 175]);

    add_block('simulink/Continuous/Integrator', ...
        [path '/Facility kW seconds'], 'InitialCondition', '0', ...
        'Position', [380 40 420 80]);
    add_block('simulink/Math Operations/Gain', ...
        [path '/Simulation Facility Energy kWh'], 'Gain', '1/3600', ...
        'Position', [470 35 595 85]);
    add_block('simulink/Continuous/Integrator', ...
        [path '/IT kW seconds'], 'InitialCondition', '0', ...
        'Position', [380 320 420 360]);
    add_block('simulink/Math Operations/Gain', ...
        [path '/Simulation IT Energy kWh'], 'Gain', '1/3600', ...
        'Position', [470 315 595 365]);
    add_block('simulink/Math Operations/Sum', ...
        [path '/IT Energy plus epsilon'], 'Inputs', '++', ...
        'Position', [650 300 695 365]);
    add_block('simulink/Math Operations/Product', [path '/Period PUE'], ...
        'Inputs', '*/', 'Position', [750 240 805 300]);

    add_block('simulink/Math Operations/Gain', [path '/Operating Hours'], ...
        'Gain', 'days_per_month*hours_per_day', ...
        'Position', [110 405 220 445]);
    add_block('simulink/Math Operations/Gain', [path '/Projection Factor'], ...
        'Gain', '1/simulation_duration_h', ...
        'Position', [270 405 370 445]);
    add_block('simulink/Math Operations/Product', [path '/Projected Energy kWh'], ...
        'Inputs', '**', 'Position', [650 50 710 110]);
    add_block('simulink/Math Operations/Product', [path '/Projected Cost'], ...
        'Inputs', '**', 'Position', [770 65 830 125]);
    add_block('simulink/Math Operations/Product', ...
        [path '/Average Monthly Cost'], 'Inputs', '*/', ...
        'Position', [900 85 960 145]);

    add_out(path, 'FacilityPower_kW', 1, [1040 115 1070 135]);
    add_out(path, 'InstantaneousPUE', 2, [1040 180 1070 200]);
    add_out(path, 'SimulationEnergy_kWh', 3, [1040 245 1070 265]);
    add_out(path, 'ProjectedEnergy_kWh', 4, [1040 310 1070 330]);
    add_out(path, 'ProjectedCost', 5, [1040 375 1070 395]);
    add_out(path, 'AverageMonthlyCost', 6, [1040 440 1070 460]);
    add_out(path, 'PeriodPUE', 7, [1040 505 1070 525]);

    add_line(path, 'ITPower_kW/1', 'Facility Power kW/1');
    add_line(path, 'InternalPump_kW/1', 'Facility Power kW/2');
    add_line(path, 'ExternalPump_kW/1', 'Facility Power kW/3');
    add_line(path, 'TowerPower_kW/1', 'Facility Power kW/4');
    add_line(path, 'Facility Aux kW/1', 'Facility Power kW/5');
    add_line(path, 'Facility Power kW/1', 'FacilityPower_kW/1');

    add_line(path, 'ITPower_kW/1', 'IT plus epsilon/1');
    add_line(path, 'PUE Epsilon/1', 'IT plus epsilon/2');
    add_line(path, 'Facility Power kW/1', 'Instantaneous PUE/1');
    add_line(path, 'IT plus epsilon/1', 'Instantaneous PUE/2');
    add_line(path, 'Instantaneous PUE/1', 'InstantaneousPUE/1');

    add_line(path, 'Facility Power kW/1', 'Facility kW seconds/1');
    add_line(path, 'Facility kW seconds/1', ...
        'Simulation Facility Energy kWh/1');
    add_line(path, 'Simulation Facility Energy kWh/1', ...
        'SimulationEnergy_kWh/1');

    add_line(path, 'ITPower_kW/1', 'IT kW seconds/1');
    add_line(path, 'IT kW seconds/1', 'Simulation IT Energy kWh/1');
    add_line(path, 'Simulation IT Energy kWh/1', ...
        'IT Energy plus epsilon/1');
    add_line(path, 'PUE Epsilon/1', 'IT Energy plus epsilon/2');
    add_line(path, 'Simulation Facility Energy kWh/1', 'Period PUE/1');
    add_line(path, 'IT Energy plus epsilon/1', 'Period PUE/2');
    add_line(path, 'Period PUE/1', 'PeriodPUE/1');

    add_line(path, 'OperatingMonths/1', 'Operating Hours/1');
    add_line(path, 'Operating Hours/1', 'Projection Factor/1');
    add_line(path, 'Simulation Facility Energy kWh/1', ...
        'Projected Energy kWh/1');
    add_line(path, 'Projection Factor/1', 'Projected Energy kWh/2');
    add_line(path, 'Projected Energy kWh/1', 'ProjectedEnergy_kWh/1');

    add_line(path, 'Projected Energy kWh/1', 'Projected Cost/1');
    add_line(path, 'ElectricityPrice/1', 'Projected Cost/2');
    add_line(path, 'Projected Cost/1', 'ProjectedCost/1');
    add_line(path, 'Projected Cost/1', 'Average Monthly Cost/1');
    add_line(path, 'OperatingMonths/1', 'Average Monthly Cost/2');
    add_line(path, 'Average Monthly Cost/1', 'AverageMonthlyCost/1');
end
