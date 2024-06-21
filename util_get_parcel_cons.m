function util_get_parcel_cons(cfg)
% This is a wrapper function that calls a series of functions to creae various parcel disconnection measures.
% This function takes a .cfg file as input (see expample scripts or manual for details on relevant fields).
% Joseph Griffis 2020

f = filesep;

cd(cfg.out_path);
if isfolder('Atlas') == 0    
    % Get parcel SC for atlas
    util_get_parcel_atlas(cfg);
    util_get_atlas_sspl(cfg);
else
    cd(fullfile(cfg.out_path, 'Atlas'));
    % check if atlas connectivity matrix exists
    con_check = dir(['*' cfg.file_suffix '*connectivity.mat']);
    if isempty(con_check) 
        util_get_parcel_atlas(cfg); % if not, create it
    end
    % check if atlas SSPL file exists
    sspl_check = dir(['*' cfg.file_suffix '*SSPL_matrix.mat']);
    if isempty(sspl_check) % if not, create it
        util_get_atlas_sspl(cfg);
    end
end
% Get parcel SDC for patient
cfg = util_get_parcel_discon(cfg);
% Get parcel SSPL and delta SSPL for patient
util_get_patient_sspl(cfg);

cd(fullfile(cfg.out_path, cfg.pat_id));
save cfg cfg
end