function tests = test_financial_baseline
% Regression tests for colleague Excel baseline values.
tests = functiontests(localfunctions);
end

function testDerivedBaselineValues(testCase)
repo_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(repo_root));
run(fullfile(repo_root, 'config', 'default_parameters.m'));
run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

verifyEqual(testCase, facility_design_IT_power_kW, 10000, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, operating_hours_per_year, 8760, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, total_loop_fluid_volume_L, 40000, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, baseline_CDU_pump_CAPEX, 1500000, ...
    'AbsTol', 1e-6);
verifyEqual(testCase, PG25_CDU_pump_CAPEX, 1620000, ...
    'AbsTol', 1e-6);
verifyEqual(testCase, initial_fluid_fill_cost, 128000, ...
    'AbsTol', 1e-6);
verifyEqual(testCase, initial_cooling_CAPEX, 1748000, ...
    'AbsTol', 1e-6);
verifyEqual(testCase, baseline_water_pump_power_kW, 120, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, target_PG25_total_pump_power_kW, 156, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, clean_calibrated_total_pump_power_kW, 156, ...
    'AbsTol', 1e-6);
verifyEqual(testCase, annual_makeup_volume_L, 2000, ...
    'AbsTol', 1e-9);
verifyEqual(testCase, dynamic_viscosity_external_cP, 2.50, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, rho_external_kg_m3, 1015, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, cp_external_J_kgK, 3980, ...
    'AbsTol', 1e-12);
verifyEqual(testCase, k_external_W_mK, 0.49, ...
    'AbsTol', 1e-12);
end

function testReplacementSchedule(testCase)
repo_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(repo_root));
run(fullfile(repo_root, 'config', 'default_parameters.m'));
run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

p = struct();
p.analysis_horizon_years = analysis_horizon_years;
p.tco_reporting_years = tco_reporting_years;
p.discount_rate_annual = discount_rate_annual;
p.electricity_price_year1_per_kWh = ...
    electricity_price_year1_per_kWh;
p.electricity_price_escalation_annual = ...
    electricity_price_escalation_annual;
p.fluid_general_cost_escalation_annual = ...
    fluid_general_cost_escalation_annual;
p.annual_makeup_volume_L = annual_makeup_volume_L;
p.fluid_unit_price_year1_per_L = fluid_unit_price_year1_per_L;
p.annual_maintenance_monitoring_year1 = ...
    annual_maintenance_monitoring_year1;
p.full_replacement_interval_years = full_replacement_interval_years;
p.total_loop_fluid_volume_L = total_loop_fluid_volume_L;
p.disposal_cost_per_full_drain_year1 = ...
    disposal_cost_per_full_drain_year1;
p.initial_cooling_CAPEX = initial_cooling_CAPEX;

[yearly, milestones, summary] = calculate_tco(1e6, 1e5, p);
replacement_years = yearly.Year(yearly.ReplacementEvent);
verifyEqual(testCase, replacement_years, [4; 8]);
verifyEqual(testCase, milestones.Year, [5; 10]);
verifyEqual(testCase, summary.full_replacement_events, 2);
end
