function diff_2_nifti(directories,Settings,currSbjFolder,sub)
    %% Diffusion MRI
    if Settings.iHAVE.dwi==1
        if contains(currSbjFolder.metadata.SeriesDescription,'diff') && ...
            contains(currSbjFolder.metadata.SeriesDescription,'AP')
        
            % Single band reference image ap
            if Settings.iHAVE.SBRef==1

                if contains(currSbjFolder.metadata.SeriesDescription,'SBRef')

                    system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_dwi{1,sub}), ...
                    ' -b y -z y -f %i -m n ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);

                    if contains(currSbjFolder.metadata.ImageType,'\M\')
                        newName_nii = sprintf('sub-0%d_ses-%s_dir-ap_part-mag_sbref.nii.gz',sub,Settings.session);
                        newName_json = sprintf('sub-0%d_ses-%s_dir-ap_part-mag_sbref.json',sub,Settings.session);
                        % RENAME
                        movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                            fullfile(directories.subjects_raw_dwi{1,sub},newName_nii));
                        movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                            fullfile(directories.subjects_raw_dwi{1,sub},newName_json));
                    else
                        newName_nii = sprintf('sub-0%d_ses-%s_dir-ap_part-phase_sbref.nii.gz',sub,Settings.session);
                        newName_json = sprintf('sub-0%d_ses-%s_dir-ap_part-phase_sbref.json',sub,Settings.session);
                        % RENAME
                        movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                            fullfile(directories.subjects_raw_dwi{1,sub},newName_nii));
                        movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                            fullfile(directories.subjects_raw_dwi{1,sub},newName_json));
                    end
                end
            end
            
            % Diffusion run AP
            if  ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')

                disp('Converting diffusion run...')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_dwi{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_dir-ap_dwi.nii.gz',sub,Settings.session);
                newName_json = sprintf('sub-0%d_ses-%s_dir-ap_dwi.json',sub,Settings.session);
                newName_bval = sprintf('sub-0%d_ses-%s_dir-ap_dwi.bval',sub,Settings.session);
                newName_bvec = sprintf('sub-0%d_ses-%s_dir-ap_dwi.bvec',sub,Settings.session);
                % RENAME
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_json));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.bval',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_bval));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.bvec',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_bvec));

            end


        elseif contains(currSbjFolder.metadata.SeriesDescription,'diff') && ...
            contains(currSbjFolder.metadata.SeriesDescription,'PA')

            if contains(currSbjFolder.metadata.SeriesDescription,'SBRef')
                if contains(currSbjFolder.metadata.ImageType,'\M\')
                    system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_dwi{1,sub}), ...
                    ' -b y -z y -f %i -m n ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                    newName_nii = sprintf('sub-0%d_ses-%s_dir-pa_part-mag_sbref.nii.gz',sub,Settings.session);
                    newName_json = sprintf('sub-0%d_ses-%s_dir-pa_part-mag_sbref.json',sub,Settings.session);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_dwi{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_dwi{1,sub},newName_json));
                else
                    newName_nii = sprintf('sub-0%d_ses-%s_dir-pa_part-phase_sbref.nii.gz',sub,Settings.session);
                    newName_json = sprintf('sub-0%d_ses-%s_dir-pa_part-phase_sbref.json',sub,Settings.session);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                end
            end

            if  ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
            
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_dwi{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_dir-pa_dwi.nii.gz',sub,Settings.session);
                newName_json = sprintf('sub-0%d_ses-%s_dir-pa_dwi.json',sub,Settings.session);
                newName_bval = sprintf('sub-0%d_ses-%s_dir-pa_dwi.bval',sub,Settings.session);
                newName_bvec = sprintf('sub-0%d_ses-%s_dir-pa_dwi.bvec',sub,Settings.session);
                % RENAME
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_json));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.bval',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_bval));
                movefile(fullfile(directories.subjects_raw_dwi{1,sub},sprintf('%s.bvec',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_dwi{1,sub},newName_bvec));
                

            end
            
        end   
    end    
end