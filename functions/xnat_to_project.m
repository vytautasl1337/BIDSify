function [directories,Settings]=xnat_to_project(directories,Settings,participants,instance)
if instance==1
    files_transfered  = questdlg('Are the DICOM files in the BIDS project directory?', ...
        'XNAT transfer', ...
        'Yes','No','Yes');
    switch files_transfered
        case 'Yes'
           disp('DICOMS are already in the BIDS directory')
           Settings.dicoms_in_bids = 1;
        case 'No'
           disp('DICOMS were not transfered')
           Settings.dicoms_in_bids = 0;
    end
    
    
elseif instance==2
    files_transfered  = questdlg('Do you want to move the DICOMS from your settings.mat specified folder or your chosen folder?', ...
        'DICOMS transfer', ...
        'Move from the server','I wish to chooses the source folder','I wish to chooses the source folder');
    switch files_transfered
        case 'Move from the server'
           disp('Moving DICOMS from the server.')
           xnat=1;
        case 'I wish to chooses the source folder'
           directories.source_folder=uigetdir(pwd,'Select the source data folder');
           xnat=0;
    end
    disp('Starting copying DICOM files...');
    for copypaste=1:length(participants.MRI)
        progressbar(copypaste/length(participants.MRI));
        if xnat==1
            try
                copyfile(char(fullfile(Settings.levelZeroFolder,participants.MRI{copypaste})),...
                        char(directories.subjects_source(1,copypaste)))
            catch
                copyfile(char(fullfile(Settings.levelZeroFolder,lower(participants.Behav{copypaste}))),...
                        char(directories.subjects_source(1,copypaste)))
            end
        elseif xnat==0
            try
                copyfile(char(fullfile(directories.source_folder,participants.MRI{copypaste})),...
                        char(directories.subjects_source(1,copypaste)))
            catch
                copyfile(char(fullfile(directories.source_folder,participants.Behav{copypaste})),...
                        char(directories.subjects_source(1,copypaste)))
            end
            
        end
    end
    log=spm_jsonread(fullfile(directories.project_folder,'BIDS_project_log.json'));
    log.Source_dir = directories.parentBIDS_source;
    log.Participant_nr = length(participants.MRI);
    json_options.indent = '   '; 
    spm_jsonwrite(fullfile(directories.project_folder,'BIDS_project_log.json'),log,json_options);

    disp('DICOMS imported to the BIDS source folder. JSON file updated.');
end