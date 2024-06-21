#!/bin/bash

# Set up path

Data_path='/Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/';
Ref_path=${Data_path}/Reference/';
Les_path=${Data_path}/Lesions_LASA/;

cd $Schaefer1000_path/';

#Extract parcels from atlas

REF=${Ref_path}/Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii

for s in ${Les_path}/sub*LESION.nii; do

flirt -ref=${REF} -in ${s}  -omat my_affine_guess.mat
fnirt --ref=MNI152_T1_2mm.nii --in=my_brain.nii --aff=my_affine_guess.mat ..

done;

/usr/local/fsl/bin/flirt -in /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION.nii -ref /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Reference/Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii -out /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION_flirt_MNI1mm.nii -omat /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION_flirt_MNI1mm.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear

Finished

/usr/local/fsl/bin/flirt -in /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION_flirt_MNI1mm.nii.gz -applyxfm -init /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION_flirt_MNI1mm.mat -out /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Lesions_LASA/sub-01_ses-001_roLESION_fnirt_MNI1mm.nii.gz -paddingsize 0.0 -interp trilinear -ref /Volumes/LASA/Aphasia_project/Lesion_Quantification_Toolkit/Reference/Schaefer2018_100Parcels_7Networks_order_plus_subcort.nii

Done