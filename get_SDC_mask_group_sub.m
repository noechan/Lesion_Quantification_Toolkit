% Calculates group structural disconnection mask 
clear all, close all
addpath(genpath('/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Code/'))
stroke_SDC_path='/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Outputs/HCP_1065_1mm/';

cd(stroke_SDC_path)
sub_names=dir('*sub*');
sub_names_mac=sub_names(46:end);
for sub=1:numel(sub_names_mac)
    cd(fullfile(stroke_SDC_path, sub_names_mac(sub).name, 'Parcel_Disconnection'))
    sdc_fname=dir('*percent_parcel_SDC*');
    load(sdc_fname(2).name)
    stroke_mask_sub(:,:,sub)=pct_sdc_matrix/100;  
    inv_stroke_mask_sub(:,:,sub)=1-stroke_mask_sub(:,:,sub);
end

cd(stroke_SDC_path)
stroke_mask_group_longR=nanmean(inv_stroke_mask_sub,3);

save('stroke_mask_group_longR', 'stroke_mask_group_longR','inv_stroke_mask_sub')


