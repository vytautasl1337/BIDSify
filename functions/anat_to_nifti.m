function anat_to_nifti(directories,Settings,currSbjFolder,sub)

    %% T1W
    if Settings.iHAVE.t1==1
        if contains(currSbjFolder.metadata.SeriesDescription,'t1_')
            disp('Converting T1w images...');
            system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_anat{1,sub}), ...
            ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
            newName_nii = sprintf('sub-0%d_ses-%s_part-mag_T1w.nii.gz',sub,Settings.session);
            newName_json = sprintf('sub-0%d_ses-%s_part-mag_T1w.json',sub,Settings.session);
            % RENAME
            movefile(fullfile(directories.subjects_raw_anat{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
               fullfile(directories.subjects_raw_anat{1,sub},newName_nii));
            movefile(fullfile(directories.subjects_raw_anat{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
               fullfile(directories.subjects_raw_anat{1,sub},newName_json));
        end
        
    end
    
    
    
    % T2W
    if Settings.iHAVE.t2==1
        
        if contains(currSbjFolder.metadata.SeriesDescription,'t2_')
            disp('Converting T2w images...');
            system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_anat{1,sub}), ...
            ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
            newName_nii = sprintf('sub-0%d_ses-%s_part-mag_T2w.nii.gz',sub,Settings.session);
            newName_json = sprintf('sub-0%d_ses-%s_part-mag_T2w.json',sub,Settings.session);
            % RENAME
            movefile(fullfile(directories.subjects_raw_anat{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
               fullfile(directories.subjects_raw_anat{1,sub},newName_nii));
            movefile(fullfile(directories.subjects_raw_anat{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
               fullfile(directories.subjects_raw_anat{1,sub},newName_json));
        end
        
    end

end