%% util_get_parcel_atlas
% This function computes parcel-based direct structural connectivity measures using an MNI-registered brain parcellation and the curated HCP-842 structural connectome template described in Yeh et al., (2018 - NeuroImage)
% It also outputs voxel-wise tract density imaging (TDI) maps as nifti files. 

%%%% Inputs
% This function takes a cfg structure as input (see manual or example scripts for details on cfg structure contents)

%%%% Outputs
% This function outputs the following files:
% 1. a .trk.gz file. This contains all of the streamlines in the atlas and is redundant with the file all_tracts_1mm.nii.gz. Can be deleted if desired
% 2. a .mat file with the suffix .connectivity.mat. This contains both the structural connection matrix (connectivity) and parcel names (name), although you must use char(name) to convert to actual names. 
% 3. a .txt file with the suffix .network_measures.txt. This file contains various graph measures for the SC matrix
% 4. a .txt file with the suffix .connectogram.txt. This file contains a connectogram that can be viewed on http://mkweb.bcgsc.ca/tableviewer/visualize/ by checking the two size options in step 2A (col with row size, row with col size)
% 5. a .tdi.nii.gz file named the same way as the .trk.gz file. This contains a nifti image volume with track density imaging (TDI) values from the .trk.gz file at each voxel. It is essentially a way of converting the .trk.gz file into voxel space. Higher values indicate higher streamline densities at each grid element (voxel).

% Joseph Griffis 2020

% file name for output tracts
cd(cfg.out_path);
if isfolder('Atlas') == 0
    mkdir('Atlas');
end
out_file = fullfile(pwd, ['atlas_' cfg.file_suffix]);

% Run DSI_Studio CLI 
if contains(cfg.source_path, 'HCP_1065') == 1
    source_fib = 'HCP1065.1mm.fib.gz';
    all_tracts = 'all_tracts.trk.gz';
elseif contains(cfg.source_path, 'HCP_842') == 1
    source_fib = 'HCP842_1mm.fib.gz';
    all_tracts = 'all_tracts_1mm.trk.gz';
end

DSI_path = '/Applications/dsi_studio.app/Contents/MacOS/dsi_studio';
cmd= sprintf('"%s" --action=ana --source="%s"  --tract="%s" --output="%s" --connectivity="%s" --connectivity_type="%s" --connectivity_threshold=0 --export=tdi',...
  DSI_path,fullfile(cfg.source_path, source_fib),fullfile(cfg.source_path, all_tracts),out_file,cfg.parcel_path,cfg.con_type);

system(cmd)

disp('Finished creating atlas files');
    
