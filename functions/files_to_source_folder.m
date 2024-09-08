function files_to_source_folder(directories,source)
disp('Copying DICOM files...');
for copypaste=1:length(source.source_subFolderNames)
    progressbar(copypaste/length(source.source_subFolderNames));
    copyfile(char(fullfile(directories.source_folder,source.source_subFolderNames(1,copypaste))),...
            char(directories.subjects_source(1,copypaste)))
end
disp('DICOMS imported to the BIDS source folder');
end