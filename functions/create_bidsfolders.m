function directories=create_bidsfolders(Settings,directories,participants,log)
% Create BIDS subfolders

% Create main project folder
directories.parentBIDS = fullfile(directories.project_folder, ['BIDS_dataset_' log.Project_Onset] );
if ~exist(directories.parentBIDS, 'dir')
    mkdir(directories.parentBIDS)
    % Create source folder
    directories.parentBIDS_source=fullfile(directories.parentBIDS,'source');
    mkdir(directories.parentBIDS_source);
    % Create raw data folder
    directories.parentBIDS_raw=fullfile(directories.parentBIDS,'raw');
    mkdir(directories.parentBIDS_raw);
    % Create derivatives folder
    directories.parentBIDS_derivatives = fullfile(directories.parentBIDS,'derivatives');
    mkdir(directories.parentBIDS_derivatives);
end

% Create subject,session folders in BIDS format (only source and raw
% folders are affected)
for sbj=1:length(participants.MRI)
    disp(['Creating folders for subject ',participants.MRI{sbj}]);
    subject_folder = 'sub-0';
    ses = sprintf('ses-%s',Settings.session);

    directories.subjects_source{sbj}=fullfile(directories.parentBIDS_source,strcat(subject_folder,num2str(sbj)),ses);
    mkdir(directories.subjects_source{sbj});

    directories.subjects_raw{sbj}=fullfile(directories.parentBIDS_raw,strcat(subject_folder,num2str(sbj)),ses);
    mkdir(directories.subjects_raw{sbj});
    %For raw folders only
    %Anatomical subfolder
    if Settings.iHAVE.t1==1 || Settings.iHAVE.t2==1
        directories.subjects_raw_anat{sbj}=fullfile(directories.subjects_raw{sbj},'anat');
        mkdir(directories.subjects_raw_anat{sbj});
    end
    %dwi subfolder
    if Settings.iHAVE.dwi==1
        directories.subjects_raw_dwi{sbj}=fullfile(directories.subjects_raw{sbj},'dwi');
        mkdir(directories.subjects_raw_dwi{sbj});
    end
    %Functional subfolders
    if Settings.iHAVE.bold_task==1 || Settings.iHAVE.bold_rest==1
        directories.subjects_raw_bold{sbj}=fullfile(directories.subjects_raw{sbj},'func');
        mkdir(directories.subjects_raw_bold{sbj});
    end
    if Settings.iHAVE.fmap==1
        directories.subjects_raw_bold_fmap{sbj}=fullfile(directories.subjects_raw{sbj},'fmap');
        mkdir(directories.subjects_raw_bold_fmap{sbj});
    end
    %Behavioral subfolders
    if Settings.iHAVE.behav==1
        directories.subjects_raw_behav{sbj}=fullfile(directories.subjects_raw{sbj},'beh');
        mkdir(directories.subjects_raw_behav{sbj});
    end
end