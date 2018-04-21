%% jp2ind.m
% This function takes a part of the file name and search for its index and
% file ID from the file list
% Inputs:
%   - filelist: a cell structure containing the file names, output of
%   jp2lsread.m
%   - partial_name: a string of a part of the file name. Typically takes
%   the form of 'FXXX--', where XXX represents the slide number.
% Outputs:
%   - fileind: the index of the file in filelist
%   - fileid: the full name of the file that we are searching for
function [fileind,fileid]=jp2ind(filelist,partial_name)
files=strfind(filelist,partial_name); % find all the files containing the partial name
fileind=find(~cellfun(@isempty,files)); % find all the indices
% if there is more than 1 files containing the partial name, ask for manual
% input to select one
if isempty(fileind)
    fileind=[];
    fileid=[];
    disp('No matching file!')
else
    if length(fileind)>1
        celldisp(filelist(fileind))
        fileind_ind=input('Please select the file index that you want: ');
        fileind=fileind(fileind_ind);
    end
    % retrieve the full file name
    fileid=filelist{fileind};
end