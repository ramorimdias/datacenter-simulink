function [yearly_cashflow, milestone_summary, summary] = calculate_tco( ...
    annual_facility_energy_kWh, annual_cooling_energy_kWh, p)
%CALCULATE_TCO Calculate nominal facility and cooling TCO.

arguments
    annual_facility_energy_kWh (1,1) double {mustBeNonnegative}
    annual_cooling_energy_kWh (1,1) double {mustBeNonnegative}
    p struct
end

N = p.analysis_horizon_years;
years = (0:N)';
operating_years = (1:N)';
electricity_price = zeros(N+1,1);
facility_electricity_cost = zeros(N+1,1);
cooling_electricity_cost = zeros(N+1,1);
makeup_volume_L = zeros(N+1,1);
makeup_cost = zeros(N+1,1);
maintenance_cost = zeros(N+1,1);
replacement_event = false(N+1,1);
replacement_fluid_cost = zeros(N+1,1);
disposal_cost = zeros(N+1,1);
initial_capex = zeros(N+1,1);
initial_capex(1) = p.initial_cooling_CAPEX;

electricity_price(2:end) = p.electricity_price_year1_per_kWh .* ...
    (1+p.electricity_price_escalation_annual).^(operating_years-1);
general_cost_factor = (1+p.fluid_general_cost_escalation_annual).^(operating_years-1);
facility_electricity_cost(2:end) = annual_facility_energy_kWh .* electricity_price(2:end);
cooling_electricity_cost(2:end) = annual_cooling_energy_kWh .* electricity_price(2:end);
makeup_volume_L(2:end) = p.annual_makeup_volume_L;
makeup_cost(2:end) = p.annual_makeup_volume_L .* p.fluid_unit_price_year1_per_L .* general_cost_factor;
maintenance_cost(2:end) = p.annual_maintenance_monitoring_year1 .* general_cost_factor;
replacement_event(2:end) = mod(operating_years, p.full_replacement_interval_years) == 0;
replacement_fluid_cost(2:end) = replacement_event(2:end) .* p.total_loop_fluid_volume_L .* ...
    p.fluid_unit_price_year1_per_L .* general_cost_factor;
disposal_cost(2:end) = replacement_event(2:end) .* p.disposal_cost_per_full_drain_year1 .* general_cost_factor;
nonenergy_opex = makeup_cost + maintenance_cost + replacement_fluid_cost + disposal_cost;
nominal_facility_cashflow = initial_capex + facility_electricity_cost + nonenergy_opex;
nominal_cooling_cashflow = initial_capex + cooling_electricity_cost + nonenergy_opex;
cumulative_nominal_facility_TCO = cumsum(nominal_facility_cashflow);
cumulative_nominal_cooling_TCO = cumsum(nominal_cooling_cashflow);

yearly_cashflow = table(years, electricity_price, ...
    repmat(annual_facility_energy_kWh,N+1,1), repmat(annual_cooling_energy_kWh,N+1,1), ...
    facility_electricity_cost, cooling_electricity_cost, makeup_volume_L, makeup_cost, ...
    maintenance_cost, replacement_event, replacement_fluid_cost, disposal_cost, nonenergy_opex, ...
    initial_capex, cumulative_nominal_facility_TCO, cumulative_nominal_cooling_TCO, ...
    'VariableNames', {'Year','ElectricityPrice_per_kWh','AnnualFacilityEnergy_kWh', ...
    'AnnualCoolingEnergy_kWh','FacilityElectricityCost','CoolingElectricityCost','MakeupVolume_L', ...
    'MakeupCost','MaintenanceCost','ReplacementEvent','ReplacementFluidCost','DisposalCost', ...
    'NonEnergyOPEX','InitialCAPEX','CumulativeNominalFacilityTCO','CumulativeNominalCoolingTCO'});

reporting_years = unique(p.tco_reporting_years(:));
reporting_years = reporting_years(reporting_years >= 0 & reporting_years <= N & mod(reporting_years,1) == 0);
rows = reporting_years + 1;
milestone_summary = table(reporting_years, cumulative_nominal_facility_TCO(rows), ...
    cumulative_nominal_cooling_TCO(rows), 'VariableNames', ...
    {'Year','NominalFacilityTCO','NominalCoolingTCO'});

summary = struct('analysis_horizon_years',N, ...
    'annual_facility_energy_kWh',annual_facility_energy_kWh, ...
    'annual_cooling_energy_kWh',annual_cooling_energy_kWh, ...
    'initial_cooling_CAPEX',p.initial_cooling_CAPEX, ...
    'nominal_facility_TCO',cumulative_nominal_facility_TCO(end), ...
    'nominal_cooling_TCO',cumulative_nominal_cooling_TCO(end), ...
    'full_replacement_events',nnz(replacement_event));
end
