% reverse process of cellsavecsv.m
M=csvread('celloc.csv');
fid=fopen('sectionfiles.txt');
C=textscan(fid,'%d,%s\n');
fclose(fid);
fileinds=C{1};
filelist=C{2};