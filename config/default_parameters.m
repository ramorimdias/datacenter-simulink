%% Default parameters for DataCenter_D2C_Interactive_TCO_v5
% Edit this file, then run build_model.m or run_analysis.m from the
% repository root.
%
% Financial assumptions reproduce the colleague Excel baseline where data
% were supplied. Parameters not present in that baseline, especially tower
% performance, remain explicit engineering placeholders.
%
% The generated model contains Dashboard Sliders inside the Fluid Properties
% and Aeration Model subsystems. Slider changes apply during normal-mode
% simulation. Rebuilding the model restores the values in this file.

%% Model and representative simulation
model = 'DataCenter_D2C_Interactive_TCO_v5';
simulation_time_s = 3600;
load_step_time_s = 1800;

% The Excel baseline is a constant 10 MW, 24/7 design case.
initial_load_fraction = 1.00;
final_load_fraction = 1.00;

%% Project and facility assumptions
facility_IT_load_MW = 10.00;
facility_IT_load_kW = facility_IT_load_MW * 1000;
design_deltaT_K = 10.00;
operating_hours_per_year = 8760;
analysis_horizon_years = 10;
tco_reporting_years = [5 10];
electricity_price_year1_per_kWh = 0.13;
electricity_price_escalation_annual = 0.03;
fluid_general_cost_escalation_annual = 0.02;

%% Rack representation
% The physical model uses equivalent 48U rack groups. The facility power is
% imposed directly above, so an integer number of racks is not required.
rack_U = 48;
kW_per_U = 1.0;
heat_capture_fraction = 1.00;
coldplate_paths_per_rack = 48;

%% Loop and water-equivalent baseline assumptions
loop_fluid_volume_factor_L_per_kW = 4.00;
baseline_CDU_pump_CAPEX_per_kW_IT = 150.00;
baseline_pump_power_fraction_of_IT = 0.012;

% When true, the detailed hydraulic correlations are scaled so that total
% internal plus external pump power at the clean-fluid design point matches
% the Excel PG25 baseline: water pump power x PG25 multiplier.
% Legacy Excel pump calibration is retained only for comparison reporting;
% active Simulink pump outputs use the hydraulic equations directly.

%% PG25 fluid properties and commercial assumptions
% Colleague baseline values at approximately 30 degC.
fluid_name = 'PG25';
cp_external_J_kgK = 3980;
rho_external_kg_m3 = 1015;
dynamic_viscosity_external_cP = 2.50;
k_external_W_mK = 0.49;
freeze_protection_C = -10.0;
fluid_unit_price_year1_per_L = 3.20;
pumping_power_multiplier_vs_water = 1.30;
CDU_pump_CAPEX_uplift_vs_water = 1.08;
annual_makeup_loss_fraction = 0.05;
full_replacement_interval_years = 4;
disposal_cost_per_full_drain_year1 = 8000;
annual_maintenance_monitoring_year1 = 25000;

%% Internal cold-plate fluid
% Initially identical to the external PG25 loop. These can be separated in
% a future comparison of different technology-cooling fluids.
cp_internal_J_kgK = cp_external_J_kgK;
rho_internal_kg_m3 = rho_external_kg_m3;
dynamic_viscosity_internal_cP = dynamic_viscosity_external_cP;
k_internal_W_mK = k_external_W_mK;

%% Cold-plate thermal path
% Total clean-liquid chip/package/TIM/plate/convection resistance for one
% equivalent cooling path at the reference conductivity below.
Rth_chip_to_coolant_K_W = 0.020;
Rth_aeration_sensitivity = 4.0;

% Fraction of the total clean thermal resistance attributed to fluid-side
% convection. Only this fraction scales inversely with conductivity. The
% remaining fraction represents package, TIM, plate, and other solid paths.
coldplate_fluid_side_resistance_fraction = 0.50;
k_internal_reference_W_mK = 0.49;

%% Entrained free-gas model
% The Excel baseline is deaerated. Change either value, for example to 0.02
% for 2 vol.% free gas, to quantify aeration penalties. These variables do
% not represent dissolved gas.
air_void_fraction_internal = 0.00;
air_void_fraction_external = 0.00;
rho_air_kg_m3 = 1.184;
cp_air_J_kgK = 1006;

% Pump hydraulic-efficiency correction ratios. These are calibration inputs,
% not universal physical constants. The clean pump efficiency is applied
% separately in the hydraulic subsystems.
internal_efficiency_derating_coefficient = 4.0;
external_efficiency_derating_coefficient = 4.0;
minimum_pump_efficiency_fraction = 0.40;

% Optional homogeneous-model correction for additional two-phase losses not
% captured by mixture density and velocity. Leave at zero until calibrated
% from component or loop measurements.
internal_two_phase_dp_coefficient = 0.0;
external_two_phase_dp_coefficient = 0.0;

% Deprecated compatibility parameters. They are retained so older scripts do
% not fail, but the live model no longer divides required flow by a pump
% capacity factor. Pump mixture flow is calculated from liquid flow and void
% fraction directly.
internal_flow_derating_coefficient = 2.0;
external_flow_derating_coefficient = 2.0;
minimum_pump_flow_capacity_factor = 0.50;

%% Temperature targets and CDU
internal_target_deltaT_K = design_deltaT_K;
external_target_deltaT_K = design_deltaT_K;
HX_approach_K = 3;

%% Reduced-order hydraulic model before Excel-baseline calibration
internal_reference_pressure_drop_Pa = 120e3;
internal_pump_efficiency = 0.65;
internal_motor_efficiency = 0.95;
internal_vfd_efficiency = 0.97;

external_reference_pressure_drop_Pa = 80e3;
external_pump_efficiency = 0.70;
external_motor_efficiency = 0.95;
external_vfd_efficiency = 0.97;

mu_pressure_exponent = 0.20;

% Average-case piping assumptions for Darcy-Weisbach pressure loss.
internal_fixed_pipe_length_m = 50;
internal_pipe_length_per_U_m = 0.005;
external_fixed_pipe_length_m = 100;
additional_external_pipe_length_per_rack_m = 0.24;
internal_pipe_diameter_m = 0.25;
external_pipe_diameter_m = 0.30;
internal_pipe_roughness_m = 1.5e-6;
external_pipe_roughness_m = 1.5e-6;
internal_fittings_loss_coefficient = 20;
external_fittings_loss_coefficient = 15;
coldplates_per_U = 3;

% Reference pressure loss for one cold-plate branch at the clean-fluid design
% branch flow. The live model scales this term with branch mixture flow squared.
coldplate_pressure_drop_Pa = 30000;

%% Cooling tower / closed-circuit heat-rejection model
% Tower power and temperature correlations were not supplied in the Excel
% baseline. These values are therefore visible placeholders to calibrate
% against selected equipment data later.
ambient_wet_bulb_C = 20;
tower_design_wet_bulb_C = 20;
tower_design_heat_kW = 10500;
tower_design_range_K = design_deltaT_K;
tower_design_approach_K = 4;
tower_approach_load_sensitivity_K = 1.0;
tower_approach_low_flow_sensitivity_K = 2.0;
tower_ambient_power_sensitivity_per_K = 0.03;
tower_minimum_flow_ratio = 0.20;
tower_fan_design_kW = 150;
tower_spray_pump_design_kW = 50;

%% Facility electrical accounting
facility_auxiliary_power_kW = 0.0;

% Compatibility inputs used by the visual Operating Scenario block.
electricity_price_per_kWh = electricity_price_year1_per_kWh;
operating_months = analysis_horizon_years * 12;
hours_per_day = 24;
days_per_month = operating_hours_per_year / (12 * hours_per_day);
