%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%%----------SCRIPT FOR MRI BRAIN IMAGING DATA STRUCTURE (BIDS)-----------%%
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP CURRENT WORKING DIRECTORY
% Cleans everything
close all;clear;clc;

% Change current working directory to the one with the BIDSifying scripts
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
clear tmp

%% LOAD SETTINGS FILE AND FUNCTIONS  (can be modified)
load('settings.mat');

% Add subfolders with functions
currentFolderContents = dir(pwd);
currentFolderContents (~[currentFolderContents.isdir]) = [];
addpath(['./' currentFolderContents(3:end).name]) 
% Add spm to path for json correction
addpath (Settings.spm_dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% START NEW PROJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get your participants list  (first column must be 'MRI'; second column 'Behav' only (if you have task data), anything else is optional)
participants=participants_list();

%% SELECT BIDS OUTPUT FOLDER (main folder for your bids files, including source data, raw data and derivatives)
directories.project_folder=uigetdir(pwd,'Select your BIDS project folder');

bids_folder = dir(directories.project_folder);
bids_Flags = [bids_folder.isdir];
bids_subFolders = bids_folder(bids_Flags);
bids_subFolderNames = {bids_subFolders(3:end).name};
if any(contains(bids_subFolderNames,'BIDS_dataset_'))
    disp('Project folder already exists');
    disp('Using same folder for your BIDS project');
    Settings.parent_folders_exist = 1;
else
    disp('Project folder does not exist');
    Settings.parent_folders_exist = 0;
    % Write json file
    log=write_log(Settings,directories); 
end
%clear bids_Flags bids_folder bids_subFolderNames bids_subFolders
%% WERE FILES MOVED FROM XNAT? (if no, files will be first moved from xnat to your bids source folder)
if any(contains(bids_subFolderNames,'BIDS_dataset_'))
    disp('Project folder already exists');
    disp('Using same folder for your BIDS project');
    Settings.parent_folders_exist = 1;
    [directories,Settings]=xnat_to_project(directories,Settings,participants,1);
else
    % WRITE LOG
    time=write_log(Settings,directories);
    % CREATE SUBFOLDERS IN BIDS SUBDIRECTORIES
    directories=create_bidsfolders(Settings,directories,participants,log);
    % Move files from xnat (or different folder) to source folder (dicoms)
    [directories,Settings]=xnat_to_project(directories,Settings,participants,2);
end
%% CONVERT DICOMS TO NIFTIS AND MOVE FILES TO RAW SUBFOLDERS
source_to_raw(directories,participants,Settings);





