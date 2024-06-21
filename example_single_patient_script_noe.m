%% Example single-subject script
clear all
%%%%% Assign relevant paths %%%%%%
% Path to DSI_Studio program
DSI_path = '/Applications/dsi_studio.app/Contents/MacOS/dsi_studio';
% Path to HCP1065.fib template and tractography atlas
source_path = '/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Tractography_Atlas/HCP_1065';
% Path to output directory (patient and atlas result directories will be created within the output directory)
out_path = '/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Outputs/HCP_1065_1mm/';
% Path to lesion (pre-registered to MNI template)
lesion_path = '/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions/FCS_024_A_lesion_111_fnirt_111MNI.nii';
% Path to parcellation (should have identical dimensions to lesion and be in MNI template space)
parcel_path = '/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Parcellations/Schaefer_Yeo/Plus_Subcort/';

%%%%% Output Filename Options %%%%%%
% Patient ID (used as prefix for output files)
pat_id = 'FCS_024_test';
% File suffix -- used as suffix for output files. Atlas name is recommended (e.g. AAL, Power, Gordon, etc.).
file_suffix = 'Yeo7100';

%%%%% Connectivity Options %%%%%%
% connectivity type ('end' or 'pass'): if 'end', connections are defined based on streamline endpoints. If 'pass', connections are defined based on streamline pass-throughs. 'End' is recommended (most conservative).
con_type = 'end';

% Get parcel-wise connectivity matrix from template
cmd= sprintf('%s --action=ana --source=%s  --tract=%s --output=%s --connectivity=%s --connectivity_type=%s --connectivity_threshold=0 --export=tdi',...
DSI_path,fullfile(source_path, 'HCP1065.1mm.fib.gz'),fullfile(source_path, 'all_tracts.trk.gz'),fullfile(out_path,'atlas_Yeo7100'),fullfile(parcel_path,'Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii'), con_type);

system(cmd)

% Get parcel SDC for patient
% Create disconnection matrix, .trk file, and TDI map
cmd2=sprintf('%s --action=ana --source=%s  --tract=%s --roi=%s --output=%s --connectivity=%s  --connectivity_type=%s --connectivity_threshold=0 --export=tdi',...
 DSI_path,fullfile(source_path, 'HCP1065.1mm.fib.gz'),fullfile(source_path, 'all_tracts.trk.gz'),lesion_path,fullfile(out_path, '/FCS_024_test/Parcel_Disconnection','FCS_024_test_trk.gz'),fullfile(parcel_path,'Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii'), con_type);

system(cmd2)

% load connectivity file (raw streamline counts)
con_file = dir('*connectivity.mat');
pat_con = load(con_file(2).name);

% load atlas SC matrix
cd(fullfile(out_path, 'Atlas'));
atlas_file = dir('*connectivity.mat');
atlas_con = load(atlas_file(2).name);

% convert patient matrix to % disconnection and save
cd(fullfile(out_path, '/FCS_024_test/Parcel_Disconnection'));
sdc_matrix = pat_con.connectivity./atlas_con.connectivity;
sdc_matrix(isnan(sdc_matrix))=0;
save(['FCS_024_test' '_' 'parcel_SDC.mat'], 'pct_sdc_matrix');
pct_sdc_matrix = 100.*(pat_con.connectivity./atlas_con.connectivity);
pct_sdc_matrix(isnan(pct_sdc_matrix))=0;
save(['FCS_024_test' '_' 'percent_parcel_SDC.mat'], 'pct_sdc_matrix');

spared_sc_matrix =(atlas_con.connectivity-pat_con.connectivity)./atlas_con.connectivity;
spared_sc_matrix(isnan(spared_sc_matrix)) = 0;
spared_sc_matrix(isinf(spared_sc_matrix)) = 0;
save(['FCS_024_test' '_'  'parcel_spared_SC.mat'], 'pct_spared_sc_matrix');
pct_spared_sc_matrix = 100.*((atlas_con.connectivity-pat_con.connectivity)./atlas_con.connectivity);
pct_spared_sc_matrix(isnan(pct_spared_sc_matrix)) = 0;
pct_spared_sc_matrix(isinf(pct_spared_sc_matrix)) = 0;
save(['FCS_024_test' '_'  'percent_parcel_spared_SC.mat'], 'pct_spared_sc_matrix');
