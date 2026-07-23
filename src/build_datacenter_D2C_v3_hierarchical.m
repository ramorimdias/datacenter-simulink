%% build_datacenter_D2C_v3_hierarchical.m
% Generates a visually organized reduced-order direct-to-chip data-center
% model. The top level contains identifiable black-box subsystems. Each
% subsystem contains the detailed correlations used by that organ.
%
% Top-level organs:
%   Operating Scenario
%   IT Racks
%   Rack CDU and Internal Loop
%   Facility PG25 Loop
%   Cooling Tower
%   Facility Energy and Cost
%
% Run from the repository root with:
%   build_model

clearvars;
clc;

%% 1. LOAD PARAMETERS AND DERIVED VALUES
script_path = mfilename('fullpath');
repo_root = fileparts(fileparts(script_path));
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

% Top-level subsystem positions.
pos.scenario = [35 90 210 265];
pos.racks    = [280 105 465 245];
pos.cdu      = [535 70 755 285];
pos.loop     = [830 70 1050 285];
pos.tower    = [1125 70 1345 285];
pos.energy   = [830 390 1080 625];

add_subsystem(model, 'Operating Scenario', pos.scenario, 'lightBlue');
add_subsystem(model, 'IT Racks', pos.racks, 'lightGreen');
add_subsystem(model, 'Rack CDU and Internal Loop', pos.cdu, 'yellow');
add_subsystem(model, 'Facility PG25 Loop', pos.loop, 'orange');
add_subsystem(model, 'Cooling Tower', pos.tower, 'cyan');
add_subsystem(model, 'Facility Energy and Cost', pos.energy, 'magenta');

build_scenario_subsystem([model '/Operating Scenario']);
build_it_racks_subsystem([model '/IT Racks']);
build_cdu_subsystem([model '/Rack CDU and Internal Loop']);
build_facility_loop_subsystem([model '/Facility PG25 Loop']);
build_tower_subsystem([model '/Cooling Tower']);
build_energy_cost_subsystem([model '/Facility Energy and Cost']);

%% 3. TOP-LEVEL CONNECTIONS
% Scenario to racks and tower.
add_line(model, 'Operating Scenario/1', 'IT Racks/1', 'autorouting', 'on');
add_line(model, 'Operating Scenario/2', 'Cooling Tower/4', ...
    'autorouting', 'on');
add_line(model, 'Operating Scenario/3', 'Facility Energy and Cost/5', ...
    'autorouting', 'on');
add_line(model, 'Operating Scenario/4', 'Facility Energy and Cost/6', ...
    'autorouting', 'on');

% IT racks to CDU.
add_line(model, 'IT Racks/2', 'Rack CDU and Internal Loop/1', ...
    'autorouting', 'on');

% Cooling tower supply temperature to both liquid loops.
add_line(model, 'Cooling Tower/1', 'Rack CDU and Internal Loop/2', ...
    'autorouting', 'on');
add_line(model, 'Cooling Tower/1', 'Facility PG25 Loop/2', ...
    'autorouting', 'on');

% CDU to facility loop.
add_line(model, 'Rack CDU and Internal Loop/1', 'Facility PG25 Loop/1', ...
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

%% 4. TOP-LEVEL MONITORING
monitor_sources = {
    'IT Racks/1',                          'P_IT_kW';
    'Rack CDU and Internal Loop/2',        'flow_internal_m3h';
    'Rack CDU and Internal Loop/3',        'P_internal_pump_kW';
    'Rack CDU and Internal Loop/5',        'T_chip_C';
    'Facility PG25 Loop/2',                'flow_external_m3h';
    'Facility PG25 Loop/3',                'P_external_pump_kW';
    'Cooling Tower/1',                     'T_tower_supply_C';
    'Cooling Tower/2',                     'P_tower_kW';
    'Cooling Tower/5',                     'tower_capacity_margin_kW';
    'Facility Energy and Cost/1',          'P_facility_kW';
    'Facility Energy and Cost/2',          'PUE_instantaneous';
    'Facility Energy and Cost/3',          'E_simulation_kWh';
    'Facility Energy and Cost/4',          'E_projected_kWh';
    'Facility Energy and Cost/5',          'projected_cost';
    'Facility Energy and Cost/6',          'average_monthly_cost';
    'Facility Energy and Cost/7',          'PUE_period'
};

xout = 1435;
yout = 55;
for idx = 1:size(monitor_sources,1)
    block_name = ['Output ' monitor_sources{idx,2}];
    add_block('simulink/Sinks/To Workspace', [model '/' block_name], ...
        'VariableName', monitor_sources{idx,2}, ...
        'SaveFormat', 'Timeseries', ...
        'Position', [xout yout+(idx-1)*42 xout+145 yout+25+(idx-1)*42]);
    add_line(model, monitor_sources{idx,1}, [block_name '/1'], ...
        'autorouting', 'on');
end

% A compact visual display area for the main commercial outputs.
display_defs = {
    'Facility Energy and Cost/4', 'Projected energy kWh';
    'Facility Energy and Cost/5', 'Projected electricity cost';
    'Facility Energy and Cost/6', 'Average monthly cost';
    'Facility Energy and Cost/7', 'Period PUE'
};
for idx = 1:size(display_defs,1)
    add_block('simulink/Sinks/Display', [model '/' display_defs{idx,2}], ...
        'Position', [1125 395+(idx-1)*58 1335 430+(idx-1)*58]);
    add_line(model, display_defs{idx,1}, [display_defs{idx,2} '/1'], ...
        'autorouting', 'on');
end

add_block('simulink/Signal Routing/Mux', [model '/Main Scope Mux'], ...
    'Inputs', '7', 'Position', [1125 690 1145 835]);
add_block('simulink/Sinks/Scope', [model '/Main Scope'], ...
    'Position', [1220 735 1280 795]);

scope_sources = {
    'IT Racks/1';
    'Rack CDU and Internal Loop/3';
    'Facility PG25 Loop/3';
    'Cooling Tower/2';
    'Facility Energy and Cost/1';
    'Facility Energy and Cost/2';
    'Rack CDU and Internal Loop/5'
};
for idx = 1:numel(scope_sources)
    add_line(model, scope_sources{idx}, ...
        ['Main Scope Mux/' num2str(idx)], 'autorouting', 'on');
end
add_line(model, 'Main Scope Mux/1', 'Main Scope/1', 'autorouting', 'on');

% Model annotation.
Simulink.Annotation(model, sprintf([ ...
    'DIRECT-TO-CHIP DATA CENTER\n' ...
    'Top level shows the main organs. Double-click a subsystem to inspect ' ...
    'its internal correlations.\n' ...
    'Cost projection repeats the simulated load profile for the selected ' ...
    'number of 24/7 operating months.']));

%% 5. SAVE
save_system(model, fullfile(repo_root, [model '.slx']));
open_system(model);

fprintf('\nCreated: %s\n', fullfile(repo_root, [model '.slx']));
fprintf('Run with: simOut = sim(''%s'');\n', model);
fprintf('Final projected cost: projected_cost.Data(end)\n\n');
