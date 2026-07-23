function build_tco_subsystem(path)
%BUILD_TCO_SUBSYSTEM Nominal TCO using visible cost assumptions.

    add_in(path, 'AnnualFacilityEnergy_kWh', 1, [25 40 55 60]);
    add_in(path, 'AnnualCoolingEnergy_kWh', 2, [25 90 55 110]);
    add_in(path, 'AnnualTopUpQuantity_L_per_year', 3, [25 140 55 160]);
    add_in(path, 'FluidPrice_$_per_L', 4, [25 190 55 210]);
    add_in(path, 'FluidRenewalLifetime_years', 5, [25 240 55 260]);
    add_in(path, 'AnnualMaintenanceCost_$_per_year', 6, [25 290 55 310]);

    add_block('simulink/Math Operations/Gain', [path '/Nominal Facility Electricity'], ...
        'Gain', 'electricity_nominal_price_factor_horizon', 'Position', [110 40 285 80]);
    add_block('simulink/Math Operations/Gain', [path '/Nominal Cooling Electricity'], ...
        'Gain', 'electricity_nominal_price_factor_horizon', 'Position', [110 100 285 140]);

    add_block('simulink/Math Operations/Product', [path '/Top-up Cost Horizon'], ...
        'Inputs', '**', 'Position', [330 165 385 215]);
    add_block('simulink/Math Operations/Gain', [path '/Top-up Escalation'], ...
        'Gain', 'general_cost_factor_horizon', 'Position', [420 165 560 215]);
    add_block('simulink/Math Operations/Product', [path '/Maintenance Cost Horizon'], ...
        'Inputs', '**', 'Position', [330 265 385 315]);
    add_block('simulink/Math Operations/Gain', [path '/Maintenance Escalation'], ...
        'Gain', 'general_cost_factor_horizon', 'Position', [420 265 560 315]);

    add_block('simulink/User-Defined Functions/Fcn', [path '/Renewal Events'], ...
        'Expr', 'floor(analysis_horizon_years/u(1))', 'Position', [330 365 560 405]);
    add_block('simulink/Math Operations/Product', [path '/Renewal Fluid Cost'], ...
        'Inputs', '***', 'Position', [600 350 655 410]);
    add_block('simulink/Sources/Constant', [path '/Initial Pump CAPEX'], ...
        'Value', 'PG25_CDU_pump_CAPEX', 'Position', [330 450 490 480]);
    add_block('simulink/Math Operations/Product', [path '/Initial Fluid Fill Cost'], ...
        'Inputs', '**', 'Position', [330 510 385 560]);
    add_block('simulink/Math Operations/Sum', [path '/Initial Cooling CAPEX'], ...
        'Inputs', '++', 'Position', [600 485 650 545]);
    add_block('simulink/Sources/Constant', [path '/Fluid Volume L'], ...
        'Value', 'total_loop_fluid_volume_L', 'Position', [110 510 270 540]);
    add_block('simulink/Sources/Constant', [path '/Disposal Cost Horizon'], ...
        'Value', 'sum(disposal_cost_by_year)', 'Position', [600 590 760 620]);

    add_block('simulink/Math Operations/Sum', [path '/Nominal Facility TCO'], ...
        'Inputs', '+++', 'Position', [820 180 875 270]);
    add_block('simulink/Math Operations/Sum', [path '/Nominal Cooling TCO'], ...
        'Inputs', '+++', 'Position', [820 340 875 430]);
    add_block('simulink/Math Operations/Sum', [path '/Nonenergy Cost Horizon'], ...
        'Inputs', '++++', 'Position', [700 250 750 330]);

    add_out(path, 'InitialCoolingCAPEX', 1, [1000 40 1030 60]);
    add_out(path, 'NominalFacilityTCO', 2, [1000 180 1030 200]);
    add_out(path, 'NominalCoolingTCO', 3, [1000 340 1030 360]);

    add_line(path, 'AnnualFacilityEnergy_kWh/1', 'Nominal Facility Electricity/1');
    add_line(path, 'AnnualCoolingEnergy_kWh/1', 'Nominal Cooling Electricity/1');
    add_line(path, 'AnnualTopUpQuantity_L_per_year/1', 'Top-up Cost Horizon/1');
    add_line(path, 'FluidPrice_$_per_L/1', 'Top-up Cost Horizon/2');
    add_line(path, 'Top-up Cost Horizon/1', 'Top-up Escalation/1');
    add_line(path, 'AnnualMaintenanceCost_$_per_year/1', 'Maintenance Cost Horizon/1');
    add_line(path, 'Maintenance Cost Horizon/1', 'Maintenance Escalation/1');
    add_line(path, 'FluidRenewalLifetime_years/1', 'Renewal Events/1');
    add_line(path, 'Renewal Events/1', 'Renewal Fluid Cost/1');
    add_line(path, 'FluidPrice_$_per_L/1', 'Renewal Fluid Cost/2');
    add_line(path, 'Fluid Volume L/1', 'Renewal Fluid Cost/3');
    add_line(path, 'Fluid Volume L/1', 'Initial Fluid Fill Cost/1');
    add_line(path, 'FluidPrice_$_per_L/1', 'Initial Fluid Fill Cost/2');
    add_line(path, 'Initial Pump CAPEX/1', 'Initial Cooling CAPEX/1');
    add_line(path, 'Initial Fluid Fill Cost/1', 'Initial Cooling CAPEX/2');
    add_line(path, 'Top-up Escalation/1', 'Nonenergy Cost Horizon/1');
    add_line(path, 'Maintenance Escalation/1', 'Nonenergy Cost Horizon/2');
    add_line(path, 'Renewal Fluid Cost/1', 'Nonenergy Cost Horizon/3');
    add_line(path, 'Disposal Cost Horizon/1', 'Nonenergy Cost Horizon/4');
    add_line(path, 'Nominal Facility Electricity/1', 'Nominal Facility TCO/1');
    add_line(path, 'Initial Cooling CAPEX/1', 'Nominal Facility TCO/2');
    add_line(path, 'Nonenergy Cost Horizon/1', 'Nominal Facility TCO/3');
    add_line(path, 'Nominal Cooling Electricity/1', 'Nominal Cooling TCO/1');
    add_line(path, 'Initial Cooling CAPEX/1', 'Nominal Cooling TCO/2');
    add_line(path, 'Nonenergy Cost Horizon/1', 'Nominal Cooling TCO/3');
    add_line(path, 'Initial Cooling CAPEX/1', 'InitialCoolingCAPEX/1');
    add_line(path, 'Nominal Facility TCO/1', 'NominalFacilityTCO/1');
    add_line(path, 'Nominal Cooling TCO/1', 'NominalCoolingTCO/1');
end
