function bold_task_2_nifti(directories,Settings,currSbjFolder,sub,participants)
    %% BOLD (task)
    if Settings.iHAVE.bold_task==1
        if contains(currSbjFolder.metadata.SeriesDescription,'task') && ...
                contains(currSbjFolder.metadata.SeriesDescription,'ap_bold')

            run_nr = str2double(regexp(currSbjFolder.metadata.SeriesDescription, '(\d+)', 'tokens', 'once'));
            
            if Settings.iHAVE.Physio==1
                
                if contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                    newName_phys = sprintf('sub-0%d_ses-%s_task-%s_run-%d_part-mag_phys.dcm',sub,Settings.session,Settings.taskName,run_nr);
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
                    newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                    newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_sbref.json',sub,Settings.session,Settings.taskName,run_nr);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                    
                    origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                    json_file = spm_jsonread(origName);
                    json_file.TaskName = Settings.taskName;
                    %write json file
                    json_options.indent = '   '; 
                    spm_jsonwrite(origName,json_file,json_options);
                %else
                    newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                    newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_sbref.json',sub,Settings.session,Settings.taskName,run_nr);
                    % RENAME
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                    movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                        fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                    
                    origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                    json_file = spm_jsonread(origName);
                    json_file.TaskName = Settings.taskName;
                    %write json file
                    json_options.indent = '   '; 
                    spm_jsonwrite(origName,json_file,json_options);
                    %end
                end
            end

            % TASK RUNS MAGNITUDE AP
            if contains(currSbjFolder.metadata.ImageType,'\M\') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog') && ...
                ~contains(currSbjFolder.metadata.SeriesDescription,'rest')

                disp(['Converting task run nr ', num2str(run_nr)])
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_bold.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_bold.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                
                origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                json_file = spm_jsonread(origName);
                json_file.TaskName = Settings.taskName;
                %write json file
                json_options.indent = '   '; 
                spm_jsonwrite(origName,json_file,json_options);

                if Settings.iHAVE.behav == 1
                    %Moving behavioral data
                    behStruct = dir(fullfile(Settings.beh_dir,participants.Behav{sub},'Task','source_data'));
                    behStructNames = { behStruct.name };
                    behNames = sort(behStructNames(contains(behStructNames,'.mat')));
                    if run_nr == 1
                        newName_beh = sprintf('sub-0%d_ses-%s_task-%s_expinfo.mat',sub,Settings.session,Settings.taskName);
                        copyfile(fullfile(Settings.beh_dir,participants.Behav{sub},'Task','source_data',behNames{1}),...
                            fullfile(directories.subjects_raw_behav{1,sub},newName_beh));
                    end
                    newName_beh = sprintf('sub-0%d_ses-%s_task-%s_run-%d_events.mat',sub,Settings.session,Settings.taskName,run_nr);
                    copyfile(fullfile(Settings.beh_dir,participants.Behav{sub},'Task','source_data',behNames{1,run_nr+1}),...
                        fullfile(directories.subjects_raw_behav{1,sub},newName_beh))

                    % Making events .tsv file
                    events_file = load(fullfile(directories.subjects_raw_behav{1,sub},newName_beh));
                    exp_info_file = load(fullfile(Settings.beh_dir,participants.Behav{sub},'Task','source_data',behNames{1}));
                    onset = transpose(events_file.Stimulus_Onset);
                    duration = repmat(exp_info_file.Stimulus_duration,[exp_info_file.Events_in_block*exp_info_file.Blocks_in_run],1);
                    response_type = transpose(events_file.GoNoGo_target);
                    
                    for trl=1:length(events_file.Stimulus_Onset)

                        if events_file.Reward_Probability(trl,1:end)=='high'
                            rew = 'H';
                        else
                            rew = 'L';
                        end

                        if events_file.Emotion_of_Distractor(trl) == -1
                            emo = 'S';
                        elseif events_file.Emotion_of_Distractor(trl) == 1
                            emo = 'N';
                        else
                            emo = 'H';
                        end

                        if events_file.Gender_of_Distractor(trl) == 1
                            gen = 'M';
                        else
                            gen = 'F';
                        end

                        trial_type{trl,1}=[rew emo gen];

                    end

                    correct_trial = transpose(events_file.Correct);
                    sub_response = transpose(events_file.Sub_Response);
                    reward_onset = transpose(events_file.Trial_Reward_Onset);
                    reward_duration = repmat(exp_info_file.Reward_presentationDur,[exp_info_file.Events_in_block*exp_info_file.Blocks_in_run],1);
                    reward_feedback = transpose(events_file.Monetary_rewards);
                    t = table(onset,...
                                duration,...
                                trial_type,...
                                response_type,...
                                correct_trial,...
                                sub_response,...
                                reward_onset,...
                                reward_duration,...
                                reward_feedback);
                    name_event = sprintf('sub-0%d_ses-%s_task-%s_run-%d_events.tsv',sub,Settings.session,Settings.taskName,run_nr);
                    writetable(t, fullfile(directories.subjects_raw_bold{1,sub},name_event), ...
                                'FileType', 'text', ...
                                'Delimiter', '\t'); 
                end

            end
            % task run phase
            if contains(currSbjFolder.metadata.ImageType,'\P\') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'rest')

                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_bold.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_bold.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold{1,sub},newName_json));
                
                origName = fullfile(directories.subjects_raw_bold{1,sub},newName_json);
                json_file = spm_jsonread(origName);
                json_file.TaskName = Settings.taskName;
                %write json file
                json_options.indent = '   '; 
                spm_jsonwrite(origName,json_file,json_options);
            end


        elseif contains(currSbjFolder.metadata.SeriesDescription,'task') && ...
            contains(currSbjFolder.metadata.SeriesDescription,'pa_bold')
        
            run_nr = str2double(regexp(currSbjFolder.metadata.SeriesDescription, '(\d+)', 'tokens', 'once'));

            if contains(currSbjFolder.metadata.SeriesDescription,'SBRef')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i -m n ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_part-mag_sbref.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = Settings.taskName;
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);

                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_part-phase_sbref.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_sbref.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = Settings.taskName;
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);
               
            end

            if contains(currSbjFolder.metadata.ImageType,'\M\') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_epi.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_epi.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-mag_bold.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = Settings.taskName;
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);

            end
            if contains(currSbjFolder.metadata.ImageType,'\P\') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'SBRef') && ...
                    ~contains(currSbjFolder.metadata.SeriesDescription,'PhysioLog')
                system([fullfile(Settings.dicom2niix_dir) ' -o ' fullfile(directories.subjects_raw_bold_fmap{1,sub}), ...
                ' -b y -z y -f %i ', fullfile(currSbjFolder.getFilesFrom(1).folder)]);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_epi-phase.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                newName_json = sprintf('sub-0%d_ses-%s_task-%s_dir-pa_run-%d_epi-phase.json',sub,Settings.session,Settings.taskName,run_nr);
                % RENAME
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.nii.gz',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_nii));
                movefile(fullfile(directories.subjects_raw_bold_fmap{1,sub},sprintf('%s_ph.json',currSbjFolder.metadata.PatientID)),...
                    fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json));
                
                jsonName = fullfile(directories.subjects_raw_bold_fmap{1,sub},newName_json);
                json_file = spm_jsonread(jsonName);
                newName_nii = sprintf('sub-0%d_ses-%s_task-%s_dir-ap_run-%d_part-phase_bold.nii.gz',sub,Settings.session,Settings.taskName,run_nr);
                extractstring = extractAfter(fullfile(directories.subjects_raw_bold{1,sub},newName_nii),[sprintf('sub-0%d',sub),'/']);
                json_file.IntendedFor = extractstring;
                json_file.TaskName = Settings.taskName;
                json_options.indent = '   '; 
                spm_jsonwrite(jsonName,json_file,json_options);
            end
        end   
    end     
end