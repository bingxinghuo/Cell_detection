filedir='/Users/bhuo/CSHLservers/gpu2_Mdrives/M29/PeterStrickData/';
cd([filedir,'Normalized'])
system('ls *.jp2 > filenames.txt')
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
sizepar=[2,1000]; % radius in microns
sigma=[200 1]; % s.d. in microns
N=10000;
for f=1:length(filelist)
    sampleid=filelist{f}(1:end-4);
    outputfile=[filedir,'unsupervised/',sampleid,'.mat'];
    if ~exist(outputfile,'file') % skip the ones that are already processed
        if ismember('DL26',sampleid)
            resolution=.25;
        elseif ismember('242',sampleid)
            resolution=.25;
        else
            resolution=.5;
        end
        rabiescell(filedir,sampleid,sigma,sizepar,resolution,N);
    end
end