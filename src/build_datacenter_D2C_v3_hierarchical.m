%% build_datacenter_D2C_v3_hierarchical.m
% Generates a visually organized reduced-order direct-to-chip data-center
% model. The top level contains identifiable black-box subsystems. Each
% subsystem contains the detailed correlations used by that organ.
%
% Top-level organs:
%   Operating Scenario
%   Fluid Properties
%   Aeration Model
%   IT Racks
%   Rack CDU and Internal Loop
%   Facility PG25 Loop
%   Cooling Tower
%   Facility Energy and Cost
%   TCO Financial Model
%
% Run from the repository root with:
%   build_model

clearvars;
clc;

%% 1. LOAD PARAMETERS AND DERIVED VALUES
script_path = mfilename('fullpath');
repo_root = fileparts(fileparts(script_path));
addpath(genpath(repo_root));
run(fullfile(repo_root, 'config', 'default_parameters.m'));
run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

%% 2. CREATE MODEL
if bdIsLoaded(model)
    close_system(model, 0);
end
if isfile(fullfile(repo_root, [model '.slx']))
    delete(fullfile(repo_root, [model '.slx']));
end

new_system(model);
open_system(model);
set_param(model, ...
    'StopTime', num2str(simulation_time_s), ...
    'Solver', 'ode45', ...
    'SimulationMode', 'normal');

% Top-level subsystem positions. The model is intentionally wide so the
% physical information flow remains readable from left to right.
pos.scenario = [35 80 210 260];
pos.fluid    = [260 50 500 300];
pos.aeration = [550 40 810 310];
pos.racks    = [860 95 1030 235];
pos.cdu      = [1080 40 1320 310];
pos.loop     = [1370 40 1590 310];
pos.tower    = [1640 40 1860 310];
pos.energy   = [850 390 1100 635];
pos.tco      = [1170 390 1420 635];

add_subsystem(model, 'Operating Scenario', pos.scenario, 'lightBlue');
add_subsystem(model, 'Fluid Properties', pos.fluid, 'lightBlue');
add_subsystem(model, 'Aeration Model', pos.aeration, 'gray');
add_subsystem(model, 'IT Racks', pos.racks, 'lightGreen');
add_subsystem(model, 'Rack CDU and Internal Loop', pos.cdu, 'yellow');
add_subsystem(model, 'Facility PG25 Loop', pos.loop, 'orange');
add_subsystem(model, 'Cooling Tower', pos.tower, 'cyan');
add_subsystem(model, 'Facility Energy and Cost', pos.energy, 'magenta');
add_subsystem(model, 'TCO Financial Model', pos.tco, 'gray');

build_scenario_subsystem([model '/Operating Scenario']);
build_fluid_properties_subsystem([model '/Fluid Properties']);
build_aeration_subsystem([model '/Aeration Model']);
build_it_racks_subsystem([model '/IT Racks']);
build_cdu_subsystem([model '/Rack CDU and Internal Loop']);
build_facility_loop_subsystem([model '/Facility PG25 Loop']);
build_tower_subsystem([model '/Cooling Tower']);
build_energy_cost_subsystem([model '/Facility Energy and Cost']);
build_tco_subsystem([model '/TCO Financial Model']);
build_simscape_reference_subsystem([model '/Simscape Fluids Reference']);

%% 3. TOP-LEVEL CONNECTIONS
% Scenario to racks and tower.
add_line(model, 'Operating Scenario/1', 'IT Racks/1', 'autorouting', 'on');
add_line(model, 'Operating Scenario/2', 'Cooling Tower/4', ...
    'autorouting', 'on');
add_line(model, 'Operating Scenario/3', 'Facility Energy and Cost/5', ...
    'autorouting', 'on');
add_line(model, 'Operating Scenario/4', 'Facility Energy and Cost/6', ...
    'autorouting', 'on');

% Clean-liquid properties into the aeration model.
add_line(model, 'Fluid Properties/1', 'Aeration Model/1', 'autorouting', 'on');
add_line(model, 'Fluid Properties/2', 'Aeration Model/2', 'autorouting', 'on');
add_line(model, 'Fluid Properties/4', 'Aeration Model/3', 'autorouting', 'on');
add_line(model, 'Fluid Properties/5', 'Aeration Model/4', 'autorouting', 'on');
add_line(model, 'Fluid Properties/6', 'Aeration Model/5', 'autorouting', 'on');

% IT racks to CDU.
add_line(model, 'IT Racks/2', 'Rack CDU and Internal Loop/1', ...
    'autorouting', 'on');

% Cooling-tower supply temperature to both liquid loops.
add_line(model, 'Cooling Tower/1', 'Rack CDU and Internal Loop/2', ...
    'autorouting', 'on');
add_line(model, 'Cooling Tower/1', 'Facility PG25 Loop/2', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/11', 'Cooling Tower/5', ...
    'autorouting', 'on');

% Live internal-loop fluid and aeration signals into the CDU.
add_line(model, 'Aeration Model/3', 'Rack CDU and Internal Loop/3', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/4', 'Rack CDU and Internal Loop/4', ...
    'autorouting', 'on');
add_line(model, 'Fluid Properties/3', 'Rack CDU and Internal Loop/5', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/5', 'Rack CDU and Internal Loop/6', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/6', 'Rack CDU and Internal Loop/7', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/7', 'Rack CDU and Internal Loop/8', ...
    'autorouting', 'on');

% CDU to facility loop.
add_line(model, 'Rack CDU and Internal Loop/1', 'Facility PG25 Loop/1', ...
    'autorouting', 'on');
add_line(model, 'IT Racks/3', 'Facility PG25 Loop/8', 'autorouting', 'on');

% Live external-loop fluid and aeration signals.
add_line(model, 'Aeration Model/8', 'Facility PG25 Loop/3', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/9', 'Facility PG25 Loop/4', ...
    'autorouting', 'on');
add_line(model, 'Fluid Properties/7', 'Facility PG25 Loop/5', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/10', 'Facility PG25 Loop/6', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/11', 'Facility PG25 Loop/7', ...
    'autorouting', 'on');

% Facility loop to tower.
add_line(model, 'Facility PG25 Loop/1', 'Cooling Tower/1', ...
    'autorouting', 'on');
add_line(model, 'Facility PG25 Loop/2', 'Cooling Tower/2', ...
    'autorouting', 'on');
add_line(model, 'Facility PG25 Loop/5', 'Cooling Tower/3', ...
    'autorouting', 'on');

% Electrical accounting.
add_line(model, 'IT Racks/1', 'Facility Energy and Cost/1', ...
    'autorouting', 'on');
add_line(model, 'Rack CDU and Internal Loop/3', ...
    'Facility Energy and Cost/2', 'autorouting', 'on');
add_line(model, 'Facility PG25 Loop/3', ...
    'Facility Energy and Cost/3', 'autorouting', 'on');
add_line(model, 'Cooling Tower/2', 'Facility Energy and Cost/4', ...
    'autorouting', 'on');

% Annual energy into the financial model.
add_line(model, 'Facility Energy and Cost/8', 'TCO Financial Model/1', ...
    'autorouting', 'on');
add_line(model, 'Facility Energy and Cost/9', 'TCO Financial Model/2', ...
    'autorouting', 'on');

%% 4. TOP-LEVEL MONITORING
monitor_sources = {
    'IT Racks/1',                            'P_IT_kW';
    'IT Racks/3',                            'facility_U';
    'Rack CDU and Internal Loop/2',          'flow_internal_m3h';
    'Rack CDU and Internal Loop/3',          'P_internal_loop_pump_kW';
    'Rack CDU and Internal Loop/5',          'T_chip_C';
    'Facility PG25 Loop/2',                  'flow_external_m3h';
    'Facility PG25 Loop/3',                  'P_external_loop_pump_kW';
    'Cooling Tower/1',                       'T_tower_supply_C';
    'Cooling Tower/2',                       'P_tower_kW';
    'Facility Energy and Cost/1',            'P_facility_kW';
    'Facility Energy and Cost/7',            'PUE_period';
    'Facility Energy and Cost/8',            'E_annual_facility_kWh';
    'Facility Energy and Cost/9',            'E_annual_cooling_kWh';
    'Facility Energy and Cost/10',           'P_cooling_kW';
    'TCO Financial Model/1',                 'CAPEX_initial_cooling';
    'TCO Financial Model/2',                 'TCO_nominal_facility';
    'TCO Financial Model/3',                 'TCO_nominal_cooling'
};

xout = 1980;
yout = 35;
for idx = 1:size(monitor_sources,1)
    block_name = ['Output ' monitor_sources{idx,2}];
    add_block('simulink/Sinks/To Workspace', [model '/' block_name], ...
        'VariableName', monitor_sources{idx,2}, ...
        'SaveFormat', 'Timeseries', ...
        'Position', [xout yout+(idx-1)*28 xout+175 yout+20+(idx-1)*28]);
    add_line(model, monitor_sources{idx,1}, [block_name '/1'], ...
        'autorouting', 'on');
end

% Numeric displays show actual values during simulation and preserve the final
% value when the run finishes. The labels identify the quantity and unit.
display_defs = {
    'Rack CDU and Internal Loop/5',   'Estimated chip temperature (C)', [325 520 540 555];
    'Facility Energy and Cost/1',     'Facility power (kW)',            [35 590 285 625];
    'Facility Energy and Cost/7',     'Period PUE (x)',                  [325 590 540 625];
    'Facility Energy and Cost/9',     'Annual cooling energy (kWh)',    [35 640 285 675];
    'TCO Financial Model/3',          'Nominal cooling TCO (currency)', [325 640 540 675]
};
for idx = 1:size(display_defs,1)
    add_block('simulink/Sinks/Display', [model '/' display_defs{idx,2}], ...
        'Position', display_defs{idx,3});
    add_line(model, display_defs{idx,1}, [display_defs{idx,2} '/1'], ...
        'autorouting', 'on');
end

% Use fixed-point formatting for all numeric displays so large values remain
% readable (for example 18,000,000 instead of 1.8e7).
display_blocks = find_system(model, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'BlockType', 'Display');
for idx = 1:numel(display_blocks)
    try
        set_param(display_blocks{idx}, 'Format', 'bank');
    catch
        % Formatting is cosmetic and varies slightly by Simulink release.
    end
end

% Whole-model visual convention: editable parameter sources are orange and
% monitored/result sinks are red. This makes the user-facing data flow clear
% even when the parameters live inside a subsystem.

% Viscosity is a small quantity in Pa.s, so retain enough precision to make
% values such as 0.00250 visible instead of rounding them to 0.00.
viscosity_displays = find_system(model, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'RegExp', 'on', 'Name', '.*Viscosity Display');
for idx = 1:numel(viscosity_displays)
    try
        set_param(viscosity_displays{idx}, 'Format', 'long');
    catch
    end
end

add_block('simulink/Signal Routing/Mux', [model '/Main Scope Mux'], ...
    'Inputs', '9', 'Position', [590 405 610 610]);
add_block('simulink/Sinks/Scope', [model '/Main Scope'], ...
    'Position', [675 480 735 540]);

scope_sources = {
    'IT Racks/1';
    'Rack CDU and Internal Loop/3';
    'Facility PG25 Loop/3';
    'Cooling Tower/2';
    'Facility Energy and Cost/1';
    'Facility Energy and Cost/2';
    'Rack CDU and Internal Loop/5';
    'Aeration Model/1';
    'Aeration Model/7'
};
for idx = 1:numel(scope_sources)
    add_line(model, scope_sources{idx}, ...
        ['Main Scope Mux/' num2str(idx)], 'autorouting', 'on');
end
add_line(model, 'Main Scope Mux/1', 'Main Scope/1', 'autorouting', 'on');

% Model annotation.
Simulink.Annotation(model, sprintf([ ...
    'DIRECT-TO-CHIP DATA CENTER - INTERACTIVE EXCEL BASELINE\n' ...
    '10 MW IT, 10 K design delta T, 8760 h/year, PG25 assumptions.\n' ...
    'Double-click Fluid Properties or Aeration Model to access live ' ...
    'Dashboard Sliders and numeric displays.']));

%% 5. SAVE
save_system(model, fullfile(repo_root, [model '.slx']));
open_system(model);

fprintf('\nCreated: %s\n', fullfile(repo_root, [model '.slx']));
fprintf('Run with: simOut = sim(''%s'');\n', model);
fprintf('Open Fluid Properties and Aeration Model for live controls.\n');
fprintf('For the annual cash-flow table, run: run_analysis\n\n');
