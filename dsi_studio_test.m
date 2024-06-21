
atlas_folder = '/Applications/Lesion_Quantification_Toolkit/Support_Tools/Tractography_Atlas/HCP_1065/';
cd(atlas_folder)
DSI_path = '/Applications/dsi_studio.app/Contents/MacOS/dsi_studio';
cmd= sprintf('%s --action=vis --source=%s --stay_open=1',DSI_path,fullfile(atlas_folder, 'HCP1065.1mm.fib.gz'));
system(cmd)

code_path="/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Code/";
cd(code_path)


cmd2= sprintf('%s --action=ana --source=%s  --tract=%s --output=%s --connectivity=%s --connectivity_type=%s --connectivity_threshold=0 --export=tdi',...
DSI_path,fullfile(code_path, 'HCP1065.1mm.fib.gz'),fullfile(code_path, 'all_tracts.trk.gz'),fullfile(code_path,'atlas_Yeo7100'),fullfile(code_path,'Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii'),'end');

system(cmd2)

im=imagesc(connectivity);
colorbar