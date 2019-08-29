%% filelsread.m
% This file retrieves a list of files in the order of scanning sequence
% Input:
%   - none. Make sure the working directory has all the JP2 files
% Output:
%   - filelist: a N-by-1 cell array containing the file name in each cell
function filelist=filelsread(filespec,savedir)
% If there is no list of file names, create one using shell script
if nargin==1
    savedir='./';
end
if ~exist([savedir,'/filenames.txt'],'file')
    system(['ls -h ', filespec, ' | sort -t"_" -k3 > ',savedir,'/filenames.txt']);
end
% read the file list from the text file
fid=fopen([savedir,'/filenames.txt']);
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
end