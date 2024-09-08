function participants=participants_list()
% Import the data
[FileName, PathName]=uigetfile(('*.xlsx'), 'Choose participant list file');
[~, ~, participants] = xlsread(fullfile(PathName, FileName), 'Sheet1'); % 'Sheet1' or the name of the sheet to read

participants= cell2table(participants(2:end,:),'VariableNames',participants(1,:));
end