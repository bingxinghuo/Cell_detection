%% readanno3.m
% This script incorporates manual identifcation of the region to avoid
% mistakes in the text file downloaded from web portal
% Version 3. Updated 3/23/2018
function regiondata=readanno3(jp2file,tifdir)
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
regiondata=cell(R,1);
%% 1. import text file as cell array
regionoutlinetxt=['Marking-',jp2file,'.txt'];
C=fileread(regionoutlinetxt);
addind0=strfind(C,'Add:[[');
C=C(addind0:end); % ignore all the deleted regions
%
% identify how many regions were annotated
delims=strfind(C,'[[');
for d=1:length(delims)
    % identify the region sequence
    regind0=delims(d)+1; % start of the sequence
    regind1=strfind(C(regind0:end),']]'); % first encounter of ]] after the region starts
    regind1=regind1(1)+regind0-1;
    regionseq=C(regind0:regind1);
    % isolate the last entry as the label
    labelarr0=strfind(regionseq,'[');
    labelarr0=labelarr0(end);
    % read out the label
    labelind0=strfind(regionseq,'(');
    labelind1=strfind(regionseq,')');
    labelseq=regionseq(labelind0+1:labelind1-1);
    r=find(strcmp(regionlist,labelseq)); % identify the region
    % read out polygon
    regionseq=regionseq(1:labelarr0-2); % update the region sequence
    regionseq(strfind(regionseq,'['))=[' '];
    regionseq(strfind(regionseq,']'))=[' '];
    regionseq(strfind(regionseq,','))=[' '];
    A=sscanf(regionseq,'%f');
    regiondata{r}=zeros(length(A)/2,2);
    for i=1:length(A)/2
        regiondata{r}(i,:)=A((i-1)*2+1:i*2);
    end
    regiondata{r}=round(abs(regiondata{r}));
end

%% Manual quality control
if nargin>1 % trigger visualization tool
    M=64; % all in 64X downsampled images
    nissltif=[tifdir,'/',jp2file(1:end-4),'.tif'];
    nisslsmall=imread(nissltif,'tif');
    figure, imagesc(nisslsmall)
    regpass=zeros(R,1);
    for r=1:R
        if ~isempty(regiondata{r})
            regiondatatemp=round(abs(regiondata{r}))/M;
            h=impoly(gca,regiondatatemp);
            title(regionlist{r})
            regcheck=input('Accept the current label? (y/n) ','s');
            if regcheck=='y'
                regpass(r)=1;
            end 
            delete(h)
        end
    end
end