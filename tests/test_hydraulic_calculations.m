function tests = test_hydraulic_calculations
% Checks for the native hydraulic reference calculations.
tests = functiontests(localfunctions);
end

function testFiniteAndPhysicalBaseline(testCase)
    repo_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(repo_root));
    run(fullfile(repo_root, 'config', 'default_parameters.m'));
    run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

    verifyGreaterThan(testCase, internal_reference_Re, 0);
    verifyGreaterThan(testCase, external_reference_Re, 0);
    verifyGreaterThan(testCase, internal_reference_pressure_drop_Pa, 0);
    verifyGreaterThan(testCase, external_reference_pressure_drop_Pa, 0);
    verifyGreaterThan(testCase, internal_clean_raw_pump_kW, 0);
    verifyGreaterThan(testCase, external_clean_raw_pump_kW, 0);
    verifyTrue(testCase, isfinite(configured_total_pump_power_kW));
end

function testExternalRackLengthScales(testCase)
    repo_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(repo_root));
    run(fullfile(repo_root, 'config', 'default_parameters.m'));
    run(fullfile(repo_root, 'src', 'initialize_parameters.m'));

    one_rack_length = external_fixed_pipe_length_m + ...
        additional_external_pipe_length_per_rack_m;
    two_rack_length = external_fixed_pipe_length_m + ...
        2*additional_external_pipe_length_per_rack_m;
    verifyGreaterThan(testCase, two_rack_length, one_rack_length);
    verifyEqual(testCase, total_coldplate_paths, ...
        facility_total_U*coldplates_per_U, 'AbsTol', 1e-12);
end
