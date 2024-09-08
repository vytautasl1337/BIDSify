function source_to_raw(directories,participants,Settings)
    for sub = 1 : size(participants,1)
        progressbar(sub/length(participants.MRI));
        disp('---------------------------------------------------------------')
        disp(['Working on participant: ',num2str(sub),'/',num2str(size(participants,1))])
        disp('---------------------------------------------------------------')

        getFilesFrom = dir(fullfile(directories.subjects_source{1,sub},'SCANS','*','*','*.dcm'));
        folders = {};
        for i = 1 :numel(getFilesFrom)
            folders{i,1} = getFilesFrom(i).folder;
        end
        folders = unique(folders);
        for i = 1 :numel(folders)
            currSbjFolder.getFilesFrom = dir(fullfile(folders{i,1},'*.dcm'));
            currSbjFolder.metadata = dicominfo(fullfile(currSbjFolder.getFilesFrom(1).folder,currSbjFolder.getFilesFrom(1).name));
            number_of_images = numel(currSbjFolder.getFilesFrom);
            disp(currSbjFolder.metadata.SeriesDescription)
            disp(number_of_images)
            disp(currSbjFolder.metadata.ImageType)
            disp('-----------------------------------------------------------')
            %% GO THROUGH EACH FOLDER AND IDENTIFY DICOMS
            % ANATOMICAL T1W AND T2W
            anat_to_nifti(directories,Settings,currSbjFolder,sub)
            % TASK MRI
            bold_task_2_nifti(directories,Settings,currSbjFolder,sub,participants)
            % REST MRI
            rest_2_nifti(directories,Settings,currSbjFolder,sub,participants)
            % Diffusion MRI
            diff_2_nifti(directories,Settings,currSbjFolder,sub)
        end
       
%         disp('DICOM conversion completed')
%         disp('Updating .json files...')
%         DirsStruct = dir(directories.subjects_raw_bold{1,sub});
%         DirNames = { DirsStruct.name };
%         origNames = DirNames(contains(DirNames,'_bold.json'));
%         for j=1:length(origNames)
%             origName = fullfile(directories.subjects_raw_bold{1,sub},origNames{j});
%             json_file = spm_jsonread(origName);
%             json_file.TaskName = Settings.taskName;
%             %write json file
%             json_options.indent = '   '; 
%             spm_jsonwrite(origName,json_file,json_options);
%         end  
%         clear DirsStruct DirNames origNames json_file json_options
%         disp('.json files updated')
        %----------------------------------------------------------------------
    end
    
    %--------------------------------------------------------------------------
    disp('Creating dataset_description.json...')
    descr.BIDSVersion='1.8.0';
    descr.DatasetType='raw';
    descr.Name='PBCTI';
    descr.Authors=['Vytautas Labanauskas'];
    json_options.indent = '    ';
    spm_jsonwrite(fullfile(directories.parentBIDS_raw,'dataset_description.json'),descr,json_options)
    %% --------------------------------------------------------------------------
    disp('Creating participants.tsv file...')
    % Get a list of subjects from the raw folder
    source.raw_folders = dir(directories.parentBIDS_raw);
    source.raw_Flags = [source.raw_folders.isdir];
    source.raw_subFolders = source.raw_folders(source.raw_Flags);
    source.raw_subFolderNames = {source.raw_subFolders(3:end).name};
    % Sort sub-x names in ascending order
    [~,I] = sort(cellfun(@length,source.raw_subFolderNames));
    source.raw_subFolderNames = source.raw_subFolderNames(I);

    for part=1:length(source.raw_subFolderNames)
            behStruct = dir(fullfile(Settings.beh_dir,participants.Behav{part},'Task','source_data'));
            behStructNames = { behStruct.name };
            behNames = sort(behStructNames(contains(behStructNames,'.mat')));
            participant_id {part,1} = source.raw_subFolderNames{1,part};
            exp_info_file = load(fullfile(Settings.beh_dir,participants.Behav{part},'Task','source_data',behNames{1}));
            sex {part,1} = exp_info_file.Gender;
            age {part,1} = exp_info_file.Age;  
            handedness {part,1} = participants.Handedness(part);
            heterosexuality {part,1} = participants.Heterosexuality(part);
    end
    t = table(participant_id,...
                sex,...
                age,...
                handedness,...
                heterosexuality);
    writetable(t, fullfile(directories.parentBIDS,'participants.tsv'), ...
                'FileType', 'text', ...
                'Delimiter', '\t');


    disp('Raw data set up in BIDS format. Happpy pre-processing')
end