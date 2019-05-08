%% filelsread.m
% This file retrieves a list of files in the order of scanning sequence
% Input:
%   - none. Make sure the working directory has all the JP2 files
% Output:
%   - filelist: a N-by-1 cell array containing the file name in each cell
function filelist=filelsread(filespec)
% If there is no list of file names, create one using shell script
if ~exist([pwd,'/','filenames.txt'],'file')
    system(['ls -h ', filespec, ' | sort -t"_" -k3 > filenames.txt']);
end
% read the file list from the text file
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
end