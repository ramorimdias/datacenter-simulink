function build_it_racks_subsystem(path)
    add_in(path, 'LoadFraction', 1, [30 85 60 105]);
    add_block('simulink/Math Operations/Gain', [path '/Facility IT Power'], ...
        'Gain', 'facility_design_IT_power_kW', ...
        'Position', [115 70 215 120]);
    add_block('simulink/Math Operations/Gain', [path '/Heat Capture'], ...
        'Gain', 'heat_capture_fraction', ...
        'Position', [270 135 355 180]);
    add_out(path, 'ITPower_kW', 1, [430 80 460 100]);
    add_out(path, 'HeatToLiquid_kW', 2, [430 150 460 170]);

    add_line(path, 'LoadFraction/1', 'Facility IT Power/1');
    add_line(path, 'Facility IT Power/1', 'ITPower_kW/1');
    add_line(path, 'Facility IT Power/1', 'Heat Capture/1');
    add_line(path, 'Heat Capture/1', 'HeatToLiquid_kW/1');
end
