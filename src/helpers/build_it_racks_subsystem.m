function build_it_racks_subsystem(path)
    add_in(path, 'LoadFraction', 1, [30 85 60 105]);
    add_in(path, 'FacilityITPower_kW', 2, [30 145 60 165]);
    add_in(path, 'FacilityUInput', 3, [30 205 60 225]);
    add_block('simulink/Math Operations/Product', [path '/Facility IT Power'], ...
        'Inputs', '**', 'Position', [115 70 215 120]);
    add_block('simulink/Math Operations/Gain', [path '/Heat Capture'], ...
        'Gain', 'heat_capture_fraction', ...
        'Position', [270 135 355 180]);
    add_out(path, 'ITPower_kW', 1, [430 80 460 100]);
    add_out(path, 'HeatToLiquid_kW', 2, [430 150 460 170]);
    add_out(path, 'FacilityU', 3, [430 210 460 230]);

    add_line(path, 'LoadFraction/1', 'Facility IT Power/1');
    add_line(path, 'FacilityITPower_kW/1', 'Facility IT Power/2');
    add_line(path, 'Facility IT Power/1', 'ITPower_kW/1');
    add_line(path, 'Facility IT Power/1', 'Heat Capture/1');
    add_line(path, 'Heat Capture/1', 'HeatToLiquid_kW/1');
    add_line(path, 'FacilityUInput/1', 'FacilityU/1');
end
