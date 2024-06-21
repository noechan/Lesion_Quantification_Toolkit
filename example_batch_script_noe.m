%% Example batch script

clc
clear all

% Toolkit Path
lqt_path = '/IPLlinux/raid0/homes/jcgriffis/Downloads/Lesion_Quantification_Toolkit';

% Add paths to support tools and core functions
addpath([lqt_path '/Functions']);
addpath(genpath([lqt_path '/Support_Tools']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set up cfg structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Assign relevant paths %%%%%%
% Path to DSI_Studio program
cfg.dsi_path = '/Shared/pinc/sharedopt/apps/DSI_Studio/Linux/x86_64/20200122/dsi_studio';
% Path to HCP842 or HCP1065 .fib template and tractography atlas (set final directory to either HCP_1065 or HCP_842)
cfg.source_path = fullfile(lqt_path, 'Support_Tools/Tractography_Atlas/HCP_1065');

% Path to output directory (patient and atlas result directories will be created within the output directory)
% cfg.out_path = '/Shared/boeslab/Users/jcgriffis/structural_lnm_comparison/disconnection_measures/lqt';
cfg.out_path = fullfile(lqt_path, 'Test_Outputs/HCP1065_1mm');
if isfolder(cfg.out_path) == 0
    mkdir(cfg.out_path)
end

% Path to lesion (pre-registered to MNI template)
% cfg.lesion_path = '/Shared/boeslab/Data/Lesion/Iowa/Registry/lesionMasks/Chronic/MNI152/1mm';
cfg.lesion_path = '/IPLlinux/raid0/homes/jcgriffis/Downloads/Lesion_Quantification_Toolkit/Support_Tools/Example_Lesions/';

% Path to parcellation (should have identical dimensions to lesion and be in MNI template space)
cfg.parcel_path = fullfile(lqt_path, '/Support_Tools/Parcellations/Schaefer_Yeo/Plus_Subcort/Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii');

%%%%% Output Filename Options %%%%%%
% Patient ID (used as prefix for output files)
cfg.pat_id = []; % could be a list, but in this example it is being taken from the file names selected later
% File suffix -- used as suffix for output files. Atlas name is recommended (e.g. AAL, Power, Gordon, etc.).
cfg.file_suffix = 'Yeo7100';

%%%%% Connectivity File Output Options %%%%%%
load([lqt_path '/Support_Tools/Parcellations/Schaefer_Yeo/Plus_Subcort/Schaefer2018_100Parcels_7Networks_order_plus_subcort.mat']);
cfg.node_label = t.RegionName; %t.RegionName; % n_regions by 1 cell array of strings corresponding to node labels (i.e. parcel names)
cfg.node_color = t.NetworkID; %t.NetworkID; % n_regions-by-1 array of integer values corresponding to e.g. network assignments or partitions (used to color nodes in external viewers)
cfg.parcel_coords = [t.X, t.Y, t.Z]; % Parcel coordinates. Used for plotting ball and stick brain graph. If not supplied, they will be estimated from the parcel file

%%%%% Connectivity Options %%%%%%
% connectivity type ('end' or 'pass'): if 'end', connections are defined based on streamline endpoints. If 'pass', connections are defined based on streamline pass-throughs. 'End' is recommended (most conservative).
cfg.con_type = 'end';
% Percent spared threshold for computing SSPLs (e.g. 100 means that only fully spared regions will be included in SSPL calculation; 1 means that all regions with at least 1% spared will be included. Default is 50)
cfg.sspl_spared_thresh = 50;
% smoothing for voxel maps (FWHM in voxel units)
cfg.smooth = 0; 

%%%%%% Navigate to directory containing lesion files %%%%%%
lesion_dir = cfg.lesion_path;
cd(lesion_dir);
lesion_files = dir('*.nii');
% load('/Shared/boeslab/Users/jcgriffis/structural_lnm_comparison/behavior/iowa_lesion_fnames.mat');

% Loop through lesion files and create measures
for i = 1%:length(lesion_files)

    % Get patient lesion file and patient ID
%     cfg.lesion_path = fullfile(lesion_dir, iowa_lesion_fnames(i,:)); % set lesion path to the current lesion
%     cfg.pat_id = iowa_lesion_fnames(i,1:4); % extract just the patient ID portion of the filename

    cfg.lesion_path = fullfile(lesion_dir, lesion_files(i).name);
    cfg.pat_id = lesion_files(i).name(1:7);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create Damage and Disconnection Measures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get parcel damage for patient
    util_get_parcel_damage(cfg);
    % Get tract SDC for patient
    util_get_tract_discon(cfg);
    % Get parcel SDC and SSPL measures for patient
    util_get_parcel_cons(cfg);
end
% navigate to output directory
cd(cfg.out_path);