%% Default parameters for DataCenter_D2C_Hierarchical_v3
% Edit this file, then run build_model.m from the repository root.

%% Model and simulation
model = 'DataCenter_D2C_Hierarchical_v3';
simulation_time_s = 3600;
load_step_time_s = 1800;
initial_load_fraction = 0.50;
final_load_fraction = 1.00;

%% Facility scale
rack_count = 1;
rack_U = 48;
kW_per_U = 1.0;
heat_capture_fraction = 1.00;
coldplate_paths_per_rack = 48;

%% Cold-plate thermal path
% Total chip/package/TIM/plate/convection resistance for one equivalent path.
Rth_chip_to_coolant_K_W = 0.020;
Rth_aeration_sensitivity = 4.0;

%% Internal cold-plate loop fluid
% Initially identical to PG25. Change these independently later if needed.
nu_internal_cSt = 1.95;
rho_internal_kg_m3 = 1000;
cp_internal_J_kgK = 3980;
k_internal_W_mK = 0.49;
air_void_fraction_internal = 0.02;

%% External PG25 loop fluid
nu_external_cSt = 1.95;
rho_external_kg_m3 = 1000;
cp_external_J_kgK = 3980;
k_external_W_mK = 0.49;
air_void_fraction_external = 0.00;

%% Gas phase used for the free-gas mixture estimate
rho_air_kg_m3 = 1.184;
cp_air_J_kgK = 1006;

%% Aeration pump derating model
% Empirical calibration inputs, not universal physical constants.
internal_flow_derating_coefficient = 2.0;
external_flow_derating_coefficient = 2.0;
internal_efficiency_derating_coefficient = 4.0;
external_efficiency_derating_coefficient = 4.0;
minimum_pump_flow_capacity_factor = 0.50;
minimum_pump_efficiency_fraction = 0.40;

%% Temperature targets and CDU
internal_target_deltaT_K = 6;
external_target_deltaT_K = 5;
HX_approach_K = 3;

%% Internal hydraulic model
internal_reference_pressure_drop_Pa = 120e3;
internal_pump_efficiency = 0.65;
mu_internal_reference_Pas = 1.95e-3;

%% External facility-loop hydraulic model
external_reference_pressure_drop_Pa = 80e3;
external_pump_efficiency = 0.70;
mu_external_reference_Pas = 1.95e-3;
mu_pressure_exponent = 0.20;

%% Cooling tower / closed-circuit heat-rejection model
ambient_wet_bulb_C = 20;
tower_design_wet_bulb_C = 20;
tower_design_heat_kW = 60;
tower_design_range_K = 5;
tower_design_approach_K = 4;
tower_approach_load_sensitivity_K = 1.0;
tower_approach_low_flow_sensitivity_K = 2.0;
tower_ambient_power_sensitivity_per_K = 0.03;
tower_minimum_flow_ratio = 0.20;
tower_fan_design_kW = 1.50;
tower_spray_pump_design_kW = 0.50;

%% Facility electrical accounting
facility_auxiliary_power_kW = 0.50;
electricity_price_per_kWh = 0.20;  % Currency units per kWh
operating_months = 12;
hours_per_day = 24;
days_per_month = 365.25 / 12;
