function comparison = run_aeration_comparison(alpha_cases)
%RUN_AERATION_COMPARISON Compare pumping energy at constant useful liquid flow.
%
%   comparison = run_aeration_comparison
%   comparison = run_aeration_comparison([0 0.01 0.02 0.05])
%
% Both internal and external loops are assigned the same free-gas volume
% fraction for each case. The generated model keeps useful liquid flow
% separate from total pump mixture flow. Results are exported to:
%
%   results/aeration_pumping_comparison.csv

    if nargin < 1 || isempty(alpha_cases)
        alpha_cases = [0 0.005 0.01 0.02 0.03 0.05];
    end

    validateattributes(alpha_cases, {'numeric'}, ...
        {'vector','real','finite','>=',0,'<',0.30});

    % Always include the clean reference case and process in ascending order.
    alpha_cases = unique([0 alpha_cases(:).']);

    repo_root = fileparts(mfilename('fullpath'));
    addpath(genpath(repo_root));

    run(fullfile(repo_root, 'config', 'default_parameters.m'));
    run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

    escaped_root = strrep(repo_root, '''', '''''');
    evalin('base', sprintf('cd(''%s''); build_model;', escaped_root));
    evalin('base', sprintf( ...
        'set_param(''%s'',''ReturnWorkspaceOutputs'',''on'');', model));

    n = numel(alpha_cases);
    internal_pump_kW = zeros(n,1);
    external_pump_kW = zeros(n,1);
    total_pump_kW = zeros(n,1);
    useful_liquid_flow_m3h = zeros(n,1);
    pump_mixture_flow_m3h = zeros(n,1);
    annual_pump_energy_kWh = zeros(n,1);
    annual_pump_cost = zeros(n,1);
    period_PUE = zeros(n,1);

    internal_alpha_block = ...
        [model '/Aeration Model/Internal Air Volume Fraction'];
    external_alpha_block = ...
        [model '/Aeration Model/External Air Volume Fraction'];

    for i = 1:n
        alpha = alpha_cases(i);
        alpha_text = num2str(alpha, 15);

        set_param(internal_alpha_block, 'Value', alpha_text);
        set_param(external_alpha_block, 'Value', alpha_text);

        simOut = evalin('base', sprintf('sim(''%s'')', model));

        internal_ts = simOut.get('P_internal_loop_pump_kW');
        external_ts = simOut.get('P_external_loop_pump_kW');
        liquid_flow_ts = simOut.get('flow_coolant_total_m3h');
        pue_ts = simOut.get('PUE_period');

        internal_pump_kW(i) = time_average(internal_ts);
        external_pump_kW(i) = time_average(external_ts);
        total_pump_kW(i) = internal_pump_kW(i) + external_pump_kW(i);
        useful_liquid_flow_m3h(i) = time_average(liquid_flow_ts);
        pump_mixture_flow_m3h(i) = ...
            useful_liquid_flow_m3h(i) / (1-alpha);
        annual_pump_energy_kWh(i) = ...
            total_pump_kW(i) * operating_hours_per_year;
        annual_pump_cost(i) = ...
            annual_pump_energy_kWh(i) * electricity_price_year1_per_kWh;
        period_PUE(i) = pue_ts.Data(end);
    end

    clean_power_kW = total_pump_kW(1);
    clean_cost = annual_pump_cost(1);

    delta_pump_power_kW = total_pump_kW - clean_power_kW;
    pump_power_increase_percent = 100 * delta_pump_power_kW / clean_power_kW;
    annual_cost_difference = annual_pump_cost - clean_cost;

    comparison = table( ...
        alpha_cases(:), ...
        100*alpha_cases(:), ...
        useful_liquid_flow_m3h, ...
        pump_mixture_flow_m3h, ...
        internal_pump_kW, ...
        external_pump_kW, ...
        total_pump_kW, ...
        delta_pump_power_kW, ...
        pump_power_increase_percent, ...
        annual_pump_energy_kWh, ...
        annual_pump_cost, ...
        annual_cost_difference, ...
        period_PUE, ...
        'VariableNames', { ...
        'AirVolumeFraction', ...
        'AirVolumePercent', ...
        'UsefulLiquidFlow_m3h', ...
        'PumpMixtureFlow_m3h', ...
        'InternalPumpElectrical_kW', ...
        'ExternalPumpElectrical_kW', ...
        'TotalPumpElectrical_kW', ...
        'DeltaPumpPower_kW', ...
        'PumpPowerIncrease_percent', ...
        'AnnualPumpEnergy_kWh', ...
        'AnnualPumpCost', ...
        'AnnualCostDifferenceVsClean', ...
        'PeriodPUE'});

    results_dir = fullfile(repo_root, 'results');
    if ~isfolder(results_dir)
        mkdir(results_dir);
    end

    output_file = fullfile(results_dir, ...
        'aeration_pumping_comparison.csv');
    writetable(comparison, output_file);

    assignin('base', 'aeration_pumping_comparison', comparison);

    fprintf('\nAERATION PUMPING COMPARISON\n');
    disp(comparison);
    fprintf('CSV results saved in: %s\n\n', output_file);
end

function value = time_average(ts)
%TIME_AVERAGE Time-weighted average of a scalar Timeseries.

    t = double(ts.Time(:));
    y = double(ts.Data(:));

    if isempty(y)
        error('run_aeration_comparison:EmptySignal', ...
            'A required simulation output is empty.');
    elseif numel(y) == 1 || numel(t) < 2 || t(end) <= t(1)
        value = y(end);
    else
        value = trapz(t, y) / (t(end)-t(1));
    end
end
