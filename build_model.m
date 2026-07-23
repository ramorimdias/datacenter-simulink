%% Build the current hierarchical data-center model
repo_root = fileparts(mfilename('fullpath'));
addpath(genpath(repo_root));
run(fullfile(repo_root, 'src', 'build_datacenter_D2C_v3_hierarchical.m'));
