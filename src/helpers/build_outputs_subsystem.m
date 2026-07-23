function build_outputs_subsystem(path)
%BUILD_OUTPUTS_SUBSYSTEM User-facing result dashboard.

    names = {'PUEInput','InternalPumpInput','ExternalPumpInput','TowerPowerInput', ...
        'TCOInput','AnnualEnergyInput','ChipTemperatureInput','CoolantTotalFlowInput', ...
        'FacilityUInput'};
    labels = {'PUE (x)','Internal loop pump power (kW)', ...
        'External loop pump power (kW)','Cooling tower power (kW)', ...
        'Nominal facility TCO (currency)','Annual facility energy (kWh)', ...
        'Chip temperature (C)','Total coolant flow (m3 per h)', ...
        'Facility U'};
    positions = [30 35; 30 95; 30 155; 30 215; 30 275; 30 335; ...
        30 395; 30 455; 30 515];
    for i = 1:numel(names)
        add_in(path, names{i}, i, [positions(i,1) positions(i,2) ...
            positions(i,1)+30 positions(i,2)+20]);
    end

    add_block('simulink/User-Defined Functions/Fcn', [path '/Coolant Flow per U m3h'], ...
        'Expr', 'u(1)/u(2)', 'Position', [300 505 470 545]);
    add_block('simulink/Signal Routing/Mux', [path '/Coolant Per U Inputs'], ...
        'Inputs', '2', 'Position', [240 500 260 560]);
    add_out(path, 'PUE', 1, [650 45 680 65]);
    add_out(path, 'InternalPumpPower_kW', 2, [650 105 680 125]);
    add_out(path, 'ExternalPumpPower_kW', 3, [650 165 680 185]);
    add_out(path, 'TowerPower_kW', 4, [650 225 680 245]);
    add_out(path, 'TCO_cost', 5, [650 285 680 305]);
    add_out(path, 'AnnualEnergy_kWh', 6, [650 345 680 365]);
    add_out(path, 'ChipTemperature_C', 7, [650 405 680 425]);
    add_out(path, 'CoolantTotalFlow_m3h', 8, [650 465 680 485]);
    add_out(path, 'CoolantFlowPerU_m3h', 9, [650 525 680 545]);

    out_names = {'PUE','InternalPumpPower_kW','ExternalPumpPower_kW','TowerPower_kW', ...
        'TCO_cost','AnnualEnergy_kWh','ChipTemperature_C','CoolantTotalFlow_m3h'};
    for i = 1:8
        add_block('simulink/Sinks/Display', [path '/' labels{i}], ...
            'Position', [500 positions(i,2)-5 625 positions(i,2)+30]);
        add_line(path, [names{i} '/1'], [labels{i} '/1']);
        add_line(path, [names{i} '/1'], [out_names{i} '/1']);
    end
    add_block('simulink/Sinks/Display', [path '/' labels{9}], ...
        'Position', [500 510 625 545]);
    add_line(path, 'Coolant Flow per U m3h/1', [labels{9} '/1']);

    add_line(path, 'CoolantTotalFlowInput/1', 'Coolant Per U Inputs/1');
    add_line(path, 'FacilityUInput/1', 'Coolant Per U Inputs/2');
    add_line(path, 'Coolant Per U Inputs/1', 'Coolant Flow per U m3h/1');
    add_line(path, 'Coolant Flow per U m3h/1', 'CoolantFlowPerU_m3h/1');

    Simulink.Annotation(path, sprintf([ ...
        'OUTPUTS\n' ...
        'Only the selected user-facing results are shown here.']));
end
