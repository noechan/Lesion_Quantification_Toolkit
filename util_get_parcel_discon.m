%% util_get_parcel_discon 
% This function computes parcel-based direct disconnection measures using an MNI-registered lesion file and an MNI-registered brain parcellation.
% It also outputs voxel-wise tract density imaging (TDI) disconnection maps as nifti files. 

%%%% Inputs
% This function takes a cfg structure as input (see manual or example scripts for details on cfg structure contents)

%%%% Outputs
% This function outputs the following files:
% 1. a .trk.gz file. This contains all of the streamlines that intersected the lesion and can be viewed using e.g. DSI_Studio
% 2. a .mat file with the suffix .connectivity.mat. This contains both the structural disconnection matrix (connectivity) and parcel names (name), although you must use char(name) to convert to actual names. 
% 3. a .txt file with the suffix .connectogram.txt. This file contains a connectomgram that can be viewed on http://mkweb.bcgsc.ca/tableviewer/visualize/ by checking the two size options in step 2A (col with row size, row with col size)
% 4. a .mat file with the suffix _percent_parcel_SDC.mat. This file contains a disconnection adjacency matrix where each cell quantifies the % disconnection for each edge in the SC atlas
% 5. a .mat file with the suffix _percent_parcel_spared_SC.mat. This file contains a spared connection adjacency matrix where each cell quantifies the % of each connection spared by the lesion for each edge in the SC atlas (i.e. it is equal to the difference between the Atlas SC matrix and the percent SDC matrix)
% 6. a .node file with the suffix _percent_parcel_SDC.node. This file contains the node information for external connectome viewers (e.g. MRIcroGL). Node sizes are proportional to the number of affected connections. Node colors can be pre-assigned in the .cfg file (cfg.node_color), but if not, they will be proportional to the amount of disconnection sustained analogous to node size.
% 7. a .edge file with the suffix _percent_parcel_SDC.edge. This file contains the percent SDC matrix in a format that can be loaded into external viewers (e.g. MRICroGL).
% 8. a .node file with the suffix _percent_parcel_spared_SC.node. This is analogous to (7), but for the spared SC matrix.
% 9. a .edge file with the suffix _percent_parcel_spared_SC.edge. This is analogous to (8), but for the spared SC matrix.
% 10. a .tdi.nii.gz file named the same way as the .trk.gz file. This contains a nifti image volume with track density imaging (TDI) values from the .trk.gz file at each voxel. It is essentially a way of converting the .trk.gz file into voxel space. Higher values indicate higher streamline densities at each grid element (voxel).
% 11. a .nii file with the suffix _percent_tdi.nii. For each voxel, values correspond the % reduction in streamline density relative to the atlas when accounting for the effects of the lesion.

% This function requires that the atlas structural connectome already have been computed.
% Joseph Griffis 2020

function cfg = util_get_parcel_discon(cfg)

f = filesep;

% file name for output tracts
cd(cfg.out_path);
if isfolder('Atlas') == 0
    error('Atlas folder does not exist in output directory; cannot convert streamline counts or TDI values to % disconnection. Please run util_get_parcel_atlas before attempting to create patient disconnection measures.');
end
if isfolder(cfg.pat_id) == 0
    mkdir(cfg.pat_id);
end
cd(['.' f cfg.pat_id]);
if isfolder('Parcel_Disconnection') == 0
    mkdir('Parcel_Disconnection');
end
if isfolder('Disconnection_Maps') == 0
    mkdir('Disconnection_Maps');
end
    
cd(['.' f 'Parcel_Disconnection']);
out_file = fullfile(pwd, [cfg.pat_id '_' cfg.file_suffix '.trk.gz']);

% Run DSI_Studio CLI 
if contains(cfg.source_path, 'HCP_1065') == 1
    source_fib = 'HCP1065.1mm.fib.gz';
    all_tracts = 'all_tracts.trk.gz';
elseif contains(cfg.source_path, 'HCP_842') == 1
    source_fib = 'HCP842_1mm.fib.gz';
    all_tracts = 'all_tracts_1mm.trk.gz';
end

% Create disconnection matrix, .trk fle, and TDI map
eval(['! ' cfg.dsi_path ' --action=ana --source=' fullfile(cfg.source_path, source_fib) ' --tract=' fullfile(cfg.source_path, all_tracts) ' --roi=' cfg.lesion_path...
    ' --output=' out_file ' --connectivity=' cfg.parcel_path ' --connectivity_type=' cfg.con_type...
    ' --connectivity_threshold=0 --export=tdi']);

% load connectivity file (raw streamline counts)
con_file = dir('*connectivity.mat');
pat_con = load(con_file(1).name);

% load atlas SC matrix
cd(fullfile(cfg.out_path, 'Atlas'));
atlas_file = dir('*connectivity.mat');
atlas_con = load(atlas_file(1).name);

% convert patient matrix to % disconnection and save
cd(['..' f cfg.pat_id f 'Parcel_Disconnection']);
pct_sdc_matrix = 100.*(pat_con.connectivity./atlas_con.connectivity);
pct_sdc_matrix(isnan(pct_sdc_matrix))=0;
save([cfg.pat_id '_' cfg.file_suffix '_percent_parcel_SDC.mat'], 'pct_sdc_matrix');
pct_spared_sc_matrix = 100.*((atlas_con.connectivity-pat_con.connectivity)./atlas_con.connectivity);
pct_spared_sc_matrix(isnan(pct_spared_sc_matrix)) = 0;
pct_spared_sc_matrix(isinf(pct_spared_sc_matrix)) = 0;
save([cfg.pat_id '_' cfg.file_suffix '_percent_parcel_spared_SC.mat'], 'pct_spared_sc_matrix');

%%% output .node and .edge files for external viewers (e.g. MRIcroGL)

% Get parcel coordinates if not supplied
if ~isfield(cfg, 'parcel_coords')
    disp('Warning: Parcel coordinates not provided, attempting to estimate coordinates from parcellation image');
    cfg.parcel_coords = util_get_coords(cfg);
elseif isempty(cfg.parcel_coords) == 1
    disp('Warning: Parcel coordinates not provided, attempting to estimate coordinates from parcellation image');
    cfg.parcel_coords = util_get_coords(cfg);
end
NodePos  = cfg.parcel_coords;
%Write out .edge files
dlmwrite([cfg.pat_id '_' cfg.file_suffix '_percent_parcel_SDC.edge'], pct_sdc_matrix, 'delimiter', '\t', 'precision', 4);
dlmwrite([cfg.pat_id '_' cfg.file_suffix '_percent_parcel_spared_SC.edge'], pct_spared_sc_matrix, 'delimiter', '\t', 'precision', 4);

% Write out .node files
NodeSize = (sum(pct_sdc_matrix,2)./(sum((atlas_con.connectivity>0).*100,2))); % size nodes according to % maximum # of affected connections in matrix
NodeSize(isnan(NodeSize))=0;
if ~isfield(cfg, 'node_color') == 1
    NodeColor = NodeSize;
elseif isfield(cfg, 'node_color') && isempty(cfg.node_color)
    NodeColor = NodeSize;
else
    NodeColor = cfg.node_color;
end
if ~isfield(cfg, 'node_label') % set ROI labels
    NodeLabel = cellstr(num2str((1:1:size(pct_sdc_matrix,1))'));
elseif isfield(cfg, 'node_label') && isempty(cfg.node_label)
    NodeLabel = cellstr(num2str((1:1:size(pct_sdc_matrix,1))'));
else
    NodeLabel = cfg.node_label;
end
% construct output filename and save
OutputFile = fullfile(pwd, [cfg.pat_id '_' cfg.file_suffix '_percent_parcel_SDC.node']); % output file name
C = gretna_gen_node_file(NodePos, NodeColor, NodeSize, NodeLabel, OutputFile);

NodeSize = (sum(pct_spared_sc_matrix,2)./(sum((atlas_con.connectivity>0).*100,2))); % size nodes according to % maximum # of affected connections in matrix
OutputFile = fullfile(pwd, [cfg.pat_id '_' cfg.file_suffix '_percent_parcel_spared_SC.node']); % output file name
C = gretna_gen_node_file(NodePos, NodeColor, NodeSize, NodeLabel, OutputFile);

%%% Save TDI map
% convert TDI to % disconnection
con_file = dir('*tdi.nii.gz');
[status, message] = copyfile(out_file, [cfg.out_path f cfg.pat_id f 'Disconnection_Maps']);
pat_con = load_nii(con_file(1).name);
cd(fullfile(cfg.out_path, 'Atlas'));
atlas_file = dir('*tdi.nii.gz');
atlas_con = load_nii(atlas_file(1).name);
cd(['..' f cfg.pat_id f 'Disconnection_Maps']);
save_nii(pat_con, con_file(1).name);
pat_con.img = 100.*(single(pat_con.img)./single(atlas_con.img));
pat_con.hdr.dime.datatype = 16;
pat_con.original.hdr.dime.datatype = 16;
pat_con.img(isnan(pat_con.img))=0;
pat_con.img(pat_con.img < 1) = 0;
if isempty(cfg.smooth)==0
    pat_con.img = GaussianSmooth(pat_con.img, cfg.smooth);
    pat_con.img(pat_con.img < 0.01) = 0;
end
save_nii(pat_con, [cfg.pat_id '_' cfg.file_suffix '_percent_tdi.nii']);
delete('*network_measures.txt')
cd('..');
cd(['.' f 'Parcel_Disconnection']);
delete('*.tdi.nii.gz');
delete('*.trk.gz');
display('Finished computing patient disconnection measures.');
end