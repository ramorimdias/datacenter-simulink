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
pos.inputs   = [30 40 480 340];
pos.aeration = [520 40 790 340];
pos.cdu      = [830 40 1110 340];
pos.loop     = [1150 40 1430 340];
pos.tower    = [1470 40 1750 340];
pos.energy   = [760 390 1060 700];
pos.tco      = [1120 390 1420 700];

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
for i = 1:11
    add_line(model, ['Inputs/' num2str(33+i)], ...
        ['Cooling Tower/' num2str(5+i)], 'autorouting', 'on');
end

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
add_line(model, 'Inputs/30', 'TCO Financial Model/3', 'autorouting', 'on');
add_line(model, 'Inputs/31', 'TCO Financial Model/4', 'autorouting', 'on');
add_line(model, 'Inputs/32', 'TCO Financial Model/5', 'autorouting', 'on');
add_line(model, 'Inputs/33', 'TCO Financial Model/6', 'autorouting', 'on');

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

% Final user-facing displays are placed to the right of the workflow.
add_block('simulink/Signal Routing/Mux', [model '/Coolant Per U Inputs'], ...
    'Inputs', '2', 'Position', [1780 510 1800 570]);
add_block('simulink/User-Defined Functions/Fcn', [model '/Coolant Flow per U m3_h'], ...
    'Expr', 'u(1)/u(2)', 'Position', [1830 515 1980 555]);
add_line(model, 'Rack CDU and Internal Loop/2', 'Coolant Per U Inputs/1', 'autorouting', 'on');
add_line(model, 'Inputs/29', 'Coolant Per U Inputs/2', 'autorouting', 'on');
add_line(model, 'Coolant Per U Inputs/1', 'Coolant Flow per U m3_h/1', 'autorouting', 'on');

display_defs = {
    'PUE (x)', 'Facility Energy and Cost/7', [1800 40 2025 75];
    'Internal Loop pump electrical (kW)', 'Rack CDU and Internal Loop/3', [1800 95 2025 130];
    'External Loop pump electrical (kW)', 'Facility PG25 Loop/3', [1800 150 2025 185];
    'Cooling tower power (kW)', 'Cooling Tower/2', [1800 205 2025 240];
    'Nominal facility TCO ($)', 'TCO Financial Model/2', [1800 265 2025 300];
    'Annual facility energy (kWh)', 'Facility Energy and Cost/8', [1800 325 2025 360];
    'Chip temperature (C)', 'Rack CDU and Internal Loop/5', [1800 385 2025 420];
    'Useful liquid flow (m3 per h)', 'Rack CDU and Internal Loop/2', [1800 445 2025 480];
    'Useful liquid flow per U (m3 per h)', 'Coolant Flow per U m3_h/1', [1800 565 2025 600]
};
for idx = 1:size(display_defs,1)
    add_block('simulink/Sinks/Display', [model '/' display_defs{idx,1}], ...
        'Position', display_defs{idx,3});
    add_line(model, display_defs{idx,2}, [display_defs{idx,1} '/1'], ...
        'autorouting', 'on');
end

% Export principal results as Timeseries for reproducible analysis scripts.
monitor_sources = {
    'Facility Energy and Cost/7', 'PUE_period';
    'Rack CDU and Internal Loop/3', 'P_internal_loop_pump_kW';
    'Facility PG25 Loop/3', 'P_external_loop_pump_kW';
    'Cooling Tower/2', 'P_tower_kW';
    'TCO Financial Model/2', 'TCO_nominal_facility';
    'Facility Energy and Cost/8', 'E_annual_facility_kWh';
    'Facility Energy and Cost/9', 'E_annual_cooling_kWh';
    'Facility Energy and Cost/1', 'P_facility_kW';
    'Facility Energy and Cost/10', 'P_cooling_kW';
    'Rack CDU and Internal Loop/5', 'T_chip_C';
    'Rack CDU and Internal Loop/2', 'flow_coolant_total_m3h';
    'Coolant Flow per U m3_h/1', 'flow_coolant_per_U_m3h'
};
xout = 2070;
yout = 35;
for idx = 1:size(monitor_sources,1)
    block_name = ['Output ' monitor_sources{idx,2}];
    add_block('simulink/Sinks/To Workspace', [model '/' block_name], ...
        'VariableName', monitor_sources{idx,2}, ...
        'SaveFormat', 'Timeseries', ...
        'Position', [xout yout+(idx-1)*28 xout+180 yout+20+(idx-1)*28]);
    add_line(model, monitor_sources{idx,1}, [block_name '/1'], ...
        'autorouting', 'on');
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

% Consistent user-facing terminology. Keep compact signal identifiers such as
% InternalViscosity_Pa_s unchanged; only visible block labels are renamed.
try
    set_param([model '/Facility PG25 Loop'], 'Name', 'Facility External Loop');
catch
end
all_blocks = find_system(model, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'Type', 'Block');
for idx = numel(all_blocks):-1:1
    block_path = all_blocks{idx};
    try
        block_name = get_param(block_path, 'Name');
        % Protect already-correct phrases before expanding standalone words.
        renamed = strrep(block_name, 'Internal Loop', '__INTERNAL_LOOP__');
        renamed = strrep(renamed, 'External Loop', '__EXTERNAL_LOOP__');
        renamed = strrep(renamed, 'Internal loop', '__INTERNAL_LOOP__');
        renamed = strrep(renamed, 'External loop', '__EXTERNAL_LOOP__');
        renamed = strrep(renamed, 'Internal ', 'Internal Loop ');
        renamed = strrep(renamed, 'External ', 'External Loop ');
        renamed = strrep(renamed, '__INTERNAL_LOOP__', 'Internal Loop');
        renamed = strrep(renamed, '__EXTERNAL_LOOP__', 'External Loop');
        if ~strcmp(block_name, renamed)
            set_param(block_path, 'Name', renamed);
        end
    catch
        % Naming is cosmetic; leave any release-specific block untouched.
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
