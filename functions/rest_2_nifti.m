function rest_2_nifti(directories,Settings,currSbjFolder,sub,participants)
    %% BOLD (rest)
    if Settings.iHAVE.bold_rest==1
        if contains(currSbjFolder.metadata.SeriesDescription,'rest') && ...
                contains(currSbjFolder.metadata.SeriesDescription,'ap_bold')

            run_nr = str2double(regexp(currSbjFolder.metadata.SeriesDescription, '(\d+)', 'tokens', 'once'));
            
            if Settings.iHAVE.behav == 1
                %Moving behavioral data
                behStruct = dir(fullfile(Settings.beh_dir,participants.Behav{sub},'Rest','source_data'));
                behStructNames = { behStruct.name };
                behNames = sort(behStructNames(contains(behStructNames,'.mat')));

                newName_beh = sprintf('sub-0%d_ses-%s_task-rest_run-%d_events.mat',sub,Settings.session,run_nr);
                copyfile(fullfile(Settings.beh_dir,participants.Behav{sub},'Rest','source_data',behNames{1}),...
                    fullfile(directories.subjects_raw_behav{1,sub},newName_beh))
            end
            
            if Settings.iHAVE.Physio==1
                
                if contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                    newName_phys = sprintf('sub-0%d_ses-%s_task-rest_run-%d_part-mag_phys.dcm',sub,Settings.session,run_nr);
                    copyfile(currSbjFolder.metadata.Filename,...
                        fullfile(directories.subjects_raw_behav{1,sub},newName_phys));
                end
            end

            % Single band reference image ap
            if Settings.iHAVE.SBRef==1

                if contains(currSbjFolder.metadata.SeriesDescription,'SBRef')

                    system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold{1,sub}), ...
                    ' -b y -z y -f %i -m n ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);

                    %if contains(currSbjFolder.metadata.ImageType,'\M\')
                    newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,run_nr);
                    newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_sbref.json',sub,Settings.session,run_nr);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                    
                    origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                    json_file = spm_jsonread(origName);
                    json_file.TaskName = 'rest';
                    %write json file
                    json_options.indent = '   '; 
                    spm_jsonwrite(origName,json_file,json_options);
                %else
                    newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,run_nr);
                    newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_sbref.json',sub,Settings.session,run_nr);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                    
                    origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                    json_file = spm_jsonread(origName);
                    json_file.TaskName = 'rest';
                    %write json file
                    json_options.indent = '   '; 
                    spm_jsonwrite(origName,json_file,json_options);
                    %end
                end
            end

            % REST RUNS MAGNITUDE AP
            if contains(currSbjFolder.metadata.ImageType,'\M\') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'task')

                disp(['Converting rest run nr ', num2str(run_nr)])
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_bold.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_bold.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                
                origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                json_file = spm_jsonread(origName);
                json_file.TaskName = 'rest';
                %write json file
                json_options.indent = '   '; 
                spm_jsonwrite(origName,json_file,json_options);


                %Moving behavioral data
                if run_nr == 1
                    behStruct = dir(fullfile(Settings.beh_dir,participants.Behav{sub},'Rest','source_data'));
                    behStructNames = { behStruct.name };
                    behNames = sort(behStructNames(contains(behStructNames,'.mat')));

                    newName_beh = sprintf('sub-0%d_ses-%s_task-rest_run-%d_events.mat',sub,Settings.session,run_nr);
                    copyfile(fullfile(Settings.beh_dir,participants.Behav{sub},'Rest','source_data',behNames{1}),...
                        fullfile(directories.subjects_raw_behav{1,sub},newName_beh))

                    % Making events .tsv file
                    rest_file = load(fullfile(Settings.beh_dir,participants.Behav{sub},'Rest','source_data',behNames{1}));
                    onset = transpose(rest_file.Response_onset);
                    duration = repmat(1,[length(rest_file.Response)],1);

                end
               
                sub_response = transpose(rest_file.Response);
                t = table(onset,...
                            duration,...
                            sub_response);
                name_event = sprintf('sub-0%d_ses-%s_task-rest_run-%d_events.tsv',sub,Settings.session,run_nr);
                writetable(t, fullfile(directories.subjects_raw_bold{1,sub},name_event), ...
                            'FileType', 'text', ...
                            'Delimiter', '\t'); 

            end
            % rest run phase
            if contains(currSbjFolder.metadata.ImageType,'\P\')&& ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'task')

                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
            
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_bold.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_bold.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                
                origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                json_file = spm_jsonread(origName);
                json_file.TaskName = 'rest';
                %write json file
                json_options.indent = '   '; 
                spm_jsonwrite(origName,json_file,json_options);
            end


        elseif contains(currSbjFolder.metadata.SeriesDescription,'rest') && ...
            contains(currSbjFolder.metadata.SeriesDescription,'pa_bold')
        
            run_nr = str2double(regexp(currSbjFolder.metadata.SeriesDescription, '(\d+)', 'tokens', 'once'));

            if contains(currSbjFolder.metadata.SeriesDescription,'SBRef')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i -m n ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_part-mag_sbref.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = 'rest';
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);

                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_part-phase_sbref.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = 'rest';
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);
            end

            if contains(currSbjFolder.metadata.ImageType,'\M\') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_epi.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_epi.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-mag_bold.nii.gz',sub,Settings.session,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = 'rest';
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);

            end
            if contains(currSbjFolder.metadata.ImageType,'\P\') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_epi-phase.nii.gz',sub,Settings.session,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-rest_dir-pa_run-%d_epi-phase.json',sub,Settings.session,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-rest_dir-ap_run-%d_part-phase_bold.nii.gz',sub,Settings.session,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = 'rest';
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);
            end
        end   
    end    
end