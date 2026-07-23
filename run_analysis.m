function results = run_analysis()
%RUN_ANALYSIS Build, simulate, and export the annual TCO cash-flow model.
%
% Usage from the repository root:
%   results = run_analysis;
%
% Outputs are written to results/:
%   tco_yearly_cashflow.csv
%   tco_milestones.csv
%   tco_results.mat

repo_root = fileparts(mfilename('fullpath'));
addpath(genpath(repo_root));

% Load a local copy of the assumptions for TCO post-processing.
run(fullfile(repo_root, 'config', 'default_parameters.m'));
run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

% Build in the base workspace because Simulink block expressions resolve
% the generated parameter variables there.
escaped_root = strrep(repo_root, '''', '''''');
evalin('base', sprintf('cd(''%s''); build_model;', escaped_root));
evalin('base', sprintf([ ...
    'set_param(''%s'',''ReturnWorkspaceOutputs'',''on'');'], model));

fprintf('\nRunning representative %.2f h simulation...\n', ...
    simulation_duration_h);
simOut = evalin('base', sprintf('sim(''%s'')', model));

annual_facility_ts = simOut.get('E_annual_facility_kWh');
annual_cooling_ts = simOut.get('E_annual_cooling_kWh');
period_pue_ts = simOut.get('PUE_period');
facility_power_ts = simOut.get('P_facility_kW');
cooling_power_ts = simOut.get('P_cooling_kW');
internal_pump_ts = simOut.get('P_internal_pump_kW');
external_pump_ts = simOut.get('P_external_pump_kW');
tower_power_ts = simOut.get('P_tower_kW');

annual_facility_energy_kWh = annual_facility_ts.Data(end);
annual_cooling_energy_kWh = annual_cooling_ts.Data(end);

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

[yearly_cashflow, milestone_summary, tco_summary] = calculate_tco( ...
    annual_facility_energy_kWh, annual_cooling_energy_kWh, p);

results_dir = fullfile(repo_root, 'results');
if ~isfolder(results_dir)
    mkdir(results_dir);
end

writetable(yearly_cashflow, ...
    fullfile(results_dir, 'tco_yearly_cashflow.csv'));
writetable(milestone_summary, ...
    fullfile(results_dir, 'tco_milestones.csv'));

results = struct();
results.model = model;
results.assumptions = p;
results.yearly_cashflow = yearly_cashflow;
results.milestone_summary = milestone_summary;
results.tco_summary = tco_summary;
results.annual_facility_energy_kWh = annual_facility_energy_kWh;
results.annual_cooling_energy_kWh = annual_cooling_energy_kWh;
results.period_PUE = period_pue_ts.Data(end);
results.facility_power_kW = facility_power_ts.Data(end);
results.cooling_power_kW = cooling_power_ts.Data(end);
results.internal_pump_power_kW = internal_pump_ts.Data(end);
results.external_pump_power_kW = external_pump_ts.Data(end);
results.tower_power_kW = tower_power_ts.Data(end);
results.total_pump_power_kW = ...
    results.internal_pump_power_kW + results.external_pump_power_kW;

save(fullfile(results_dir, 'tco_results.mat'), 'results');
assignin('base', 'tco_results', results);
assignin('base', 'tco_yearly_cashflow', yearly_cashflow);
assignin('base', 'tco_milestones', milestone_summary);

fprintf('\nBASELINE RESULTS\n');
fprintf('Facility IT design load:              %12.1f kW\n', ...
    facility_design_IT_power_kW);
fprintf('Total pump power:                     %12.1f kW\n', ...
    results.total_pump_power_kW);
fprintf('Excel PG25 pump target:               %12.1f kW\n', ...
    target_PG25_total_pump_power_kW);
fprintf('Tower electrical power:               %12.1f kW\n', ...
    results.tower_power_kW);
fprintf('Total facility power:                 %12.1f kW\n', ...
    results.facility_power_kW);
fprintf('Period PUE:                           %12.4f\n', ...
    results.period_PUE);
fprintf('Annual facility energy:               %12.0f kWh\n', ...
    annual_facility_energy_kWh);
fprintf('Annual cooling energy:                %12.0f kWh\n', ...
    annual_cooling_energy_kWh);
fprintf('Initial cooling CAPEX incl. fluid:    %12.0f\n', ...
    tco_summary.initial_cooling_CAPEX);
fprintf('%d-year facility TCO:                  %12.0f\n', ...
    analysis_horizon_years, tco_summary.nominal_facility_TCO);
fprintf('%d-year cooling TCO:                   %12.0f\n', ...
    analysis_horizon_years, tco_summary.nominal_cooling_TCO);

fprintf('\nTCO MILESTONES\n');
disp(milestone_summary);
fprintf('CSV results saved in: %s\n\n', results_dir);
end
