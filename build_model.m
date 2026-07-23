%% build_model.m
% Repository entry point.
repo_root = fileparts(mfilename('fullpath'));
run(fullfile(repo_root, 'src', 'build_datacenter_D2C_v2.m'));
