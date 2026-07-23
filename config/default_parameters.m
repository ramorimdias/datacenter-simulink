%% default_parameters.m
% User-editable parameters for build_datacenter_D2C_v2.m
%
% Aeration variables are FREE-GAS VOLUME FRACTIONS between 0 and 1.
% Example: 0.02 means 2 vol.% entrained free gas.

%% Model and simulation
model = 'DataCenter_D2C_Rack_v2';
simulation_time_s = 3600;
load_step_time_s = 1800;
initial_load_fraction = 0.50;
final_load_fraction = 1.00;

%% Rack and cold plates
rack_U = 48;
kW_per_U = 1.0;
heat_capture_fraction = 1.00;
coldplate_paths = 48;

% Total clean-liquid chip-to-bulk-coolant resistance for one cooling path.
Rth_chip_to_coolant_K_W = 0.020;

%% External PG25 loop, constant properties
nu_external_cSt = 1.95;
rho_external_kg_m3 = 1000;
cp_external_J_kgK = 3980;
k_external_W_mK = 0.49;
mu_external_Pas = nu_external_cSt * 1e-6 * rho_external_kg_m3;

%% Internal cold-plate loop
% Initially set equal to the external PG25 properties.
nu_internal_cSt = nu_external_cSt;
rho_internal_kg_m3 = rho_external_kg_m3;
cp_internal_J_kgK = cp_external_J_kgK;
k_internal_W_mK = k_external_W_mK;
mu_internal_Pas = nu_internal_cSt * 1e-6 * rho_internal_kg_m3;

%% Entrained-air model
% Free-gas void fractions. Do not use these parameters for dissolved air.
air_void_fraction_internal = 0.02;
air_void_fraction_external = 0.00;

% Approximate air properties used only in mixture density and heat capacity.
rho_air_kg_m3 = 1.184;
cp_air_J_kgK = 1007;

% Empirical flow-capacity derating:
% capacity_factor = max(minimum, 1 - coefficient * void_fraction)
internal_flow_derating_coefficient = 2.0;
external_flow_derating_coefficient = 2.0;
minimum_pump_flow_capacity_factor = 0.50;

% Empirical pump-efficiency derating:
% efficiency_factor = max(minimum, 1 - coefficient * void_fraction)
internal_efficiency_derating_coefficient = 4.0;
external_efficiency_derating_coefficient = 4.0;
minimum_pump_efficiency_fraction = 0.40;

% Empirical thermal-resistance multiplier:
% Rth_effective = Rth_clean * (1 + sensitivity * void_fraction)
Rth_aeration_sensitivity = 4.0;

%% Thermal targets
% The current reduced-order model calculates flow needed to meet these
% coolant temperature rises.
deltaT_internal_K = 6;
deltaT_external_K = 5;
T_external_supply_C = 25;
HX_approach_K = 3;

%% Internal loop hydraulic model
% Reference pressure drop is specified at the deaerated design flow.
dp_internal_ref_Pa = 120e3;
eta_internal_pump = 0.65;

%% External PG25 hydraulic model
dp_external_ref_Pa = 80e3;
eta_external_pump = 0.70;

%% Pressure-loss scaling
mu_internal_ref_Pas = mu_internal_Pas;
rho_internal_ref_kg_m3 = rho_internal_kg_m3;
mu_external_ref_Pas = mu_external_Pas;
rho_external_ref_kg_m3 = rho_external_kg_m3;
mu_pressure_exponent = 0.20;

%% Closed-circuit heat-rejection unit
tower_design_heat_kW = 60;
tower_fan_design_kW = 1.50;
tower_spray_pump_design_kW = 0.50;

%% Other facility consumption
auxiliary_power_kW = 0.50;
