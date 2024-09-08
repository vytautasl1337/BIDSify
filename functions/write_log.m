function log=write_log(Settings,directories)
%% WRITE json LOG
if Settings.parent_folders_exist==0
    log.Project_Onset = datestr(clock,'YYYYmmdd-HHMM');
    log.Project_dir = directories.project_folder;
    json_options.indent = '    ';
    spm_jsonwrite(fullfile(directories.project_folder,'BIDS_project_log.json'),log,json_options)
end