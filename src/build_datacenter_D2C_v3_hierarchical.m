%% build_datacenter_D2C_v3_hierarchical.m
% Generates a visually organized reduced-order direct-to-chip data-center
% model. The top level contains identifiable black-box subsystems. Each
% subsystem contains the detailed correlations used by that organ.
%
% Top-level organs:
%   Inputs (Operating Scenario, Fluid Properties, Facility/Hydraulic Hypotheses)
%   Aeration Model
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
pos.inputs   = [35 40 700 700];
pos.aeration = [550 40 810 310];
pos.cdu      = [1080 40 1320 310];
pos.loop     = [1370 40 1590 310];
pos.tower    = [1640 40 1860 310];
pos.energy   = [850 390 1100 635];
pos.tco      = [1170 390 1420 635];
pos.outputs  = [35 760 720 1135];

add_subsystem(model, 'Inputs', pos.inputs, 'orange');
add_subsystem(model, 'Aeration Model', pos.aeration, 'gray');
add_subsystem(model, 'Rack CDU and Internal Loop', pos.cdu, 'yellow');
add_subsystem(model, 'Facility PG25 Loop', pos.loop, 'orange');
add_subsystem(model, 'Cooling Tower', pos.tower, 'cyan');
add_subsystem(model, 'Facility Energy and Cost', pos.energy, 'magenta');
add_subsystem(model, 'TCO Financial Model', pos.tco, 'gray');

build_inputs_subsystem([model '/Inputs']);
build_aeration_subsystem([model '/Aeration Model']);
build_cdu_subsystem([model '/Rack CDU and Internal Loop']);
build_facility_loop_subsystem([model '/Facility PG25 Loop']);
build_tower_subsystem([model '/Cooling Tower']);
build_energy_cost_subsystem([model '/Facility Energy and Cost']);
build_tco_subsystem([model '/TCO Financial Model']);
add_subsystem(model, 'Outputs', pos.outputs, 'red');
build_outputs_subsystem([model '/Outputs']);
% Simscape integration is intentionally disabled for this native reduced-order
% model.  The hydraulic equations are implemented explicitly in the two loop
% subsystems below.

%% 3. TOP-LEVEL CONNECTIONS
% Centralized inputs to racks, tower, and energy accounting.
% IT load and rack sizing is nested inside Inputs.
add_line(model, 'Inputs/2', 'Cooling Tower/4', ...
    'autorouting', 'on');
add_line(model, 'Inputs/3', 'Facility Energy and Cost/5', ...
    'autorouting', 'on');
add_line(model, 'Inputs/4', 'Facility Energy and Cost/6', ...
    'autorouting', 'on');
% Centralized hydraulic hypotheses.
for i = 1:6
    add_line(model, ['Inputs/' num2str(14+i)], ...
        ['Rack CDU and Internal Loop/' num2str(9+i)], 'autorouting', 'on');
end
for i = 1:6
    add_line(model, ['Inputs/' num2str(20+i)], ...
        ['Facility PG25 Loop/' num2str(8+i)], 'autorouting', 'on');
end

% Clean-liquid properties into the aeration model.
add_line(model, 'Inputs/5', 'Aeration Model/1', 'autorouting', 'on');
add_line(model, 'Inputs/6', 'Aeration Model/2', 'autorouting', 'on');
add_line(model, 'Inputs/8', 'Aeration Model/3', 'autorouting', 'on');
add_line(model, 'Inputs/9', 'Aeration Model/4', 'autorouting', 'on');
add_line(model, 'Inputs/10', 'Aeration Model/5', 'autorouting', 'on');

% IT racks to CDU.
add_line(model, 'Inputs/28', 'Rack CDU and Internal Loop/1', ...
    'autorouting', 'on');
add_line(model, 'Inputs/29', 'Rack CDU and Internal Loop/9', ...
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
add_line(model, 'Inputs/7', 'Rack CDU and Internal Loop/5', ...
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
add_line(model, 'Inputs/29', 'Facility PG25 Loop/8', 'autorouting', 'on');

% Live external-loop fluid and aeration signals.
add_line(model, 'Aeration Model/8', 'Facility PG25 Loop/3', ...
    'autorouting', 'on');
add_line(model, 'Aeration Model/9', 'Facility PG25 Loop/4', ...
    'autorouting', 'on');
add_line(model, 'Inputs/11', 'Facility PG25 Loop/5', ...
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
add_line(model, 'Inputs/27', 'Facility Energy and Cost/1', ...
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

% Centralized user-facing outputs.
add_line(model, 'Facility Energy and Cost/7', 'Outputs/1', 'autorouting', 'on');
add_line(model, 'Rack CDU and Internal Loop/3', 'Outputs/2', 'autorouting', 'on');
add_line(model, 'Facility PG25 Loop/3', 'Outputs/3', 'autorouting', 'on');
add_line(model, 'Cooling Tower/2', 'Outputs/4', 'autorouting', 'on');
add_line(model, 'TCO Financial Model/2', 'Outputs/5', 'autorouting', 'on');
add_line(model, 'Facility Energy and Cost/8', 'Outputs/6', 'autorouting', 'on');
add_line(model, 'Rack CDU and Internal Loop/5', 'Outputs/7', 'autorouting', 'on');
add_line(model, 'Rack CDU and Internal Loop/2', 'Outputs/8', 'autorouting', 'on');
add_line(model, 'Inputs/29', 'Outputs/9', 'autorouting', 'on');

%% 4. TOP-LEVEL MONITORING
monitor_sources = {
    'Outputs/1', 'PUE';
    'Outputs/2', 'P_internal_loop_pump_kW';
    'Outputs/3', 'P_external_loop_pump_kW';
    'Outputs/4', 'P_tower_kW';
    'Outputs/5', 'TCO_nominal_facility';
    'Outputs/6', 'E_annual_facility_kWh';
    'Outputs/7', 'T_chip_C';
    'Outputs/8', 'flow_coolant_total_m3h';
    'Outputs/9', 'flow_coolant_per_U_m3h'
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

% Model annotation.
Simulink.Annotation(model, sprintf([ ...
    'DIRECT-TO-CHIP DATA CENTER - INTERACTIVE EXCEL BASELINE\n' ...
    '10 MW IT, 10 K design delta T, 8760 h/year, PG25 assumptions.\n' ...
    'Double-click Inputs (nested sections) or Aeration Model to access live ' ...
    'Dashboard Sliders and numeric displays.']));

%% 5. SAVE
save_system(model, fullfile(repo_root, [model '.slx']));
open_system(model);

fprintf('\nCreated: %s\n', fullfile(repo_root, [model '.slx']));
fprintf('Run with: simOut = sim(''%s'');\n', model);
fprintf('Open Inputs (nested sections) and Aeration Model for live controls.\n');
fprintf('For the annual cash-flow table, run: run_analysis\n\n');
