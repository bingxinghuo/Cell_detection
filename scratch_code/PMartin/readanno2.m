%% readanno2.m
% This script incorporates manual identifcation of the region to avoid
% mistakes in the text file downloaded from web portal
function regiondata=readanno2(jp2file,regionoutlinetxt,tifdir,M)
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
regiondata=cell(R,1);
%% 1. import text file as cell array
% regionoutlinetxt=['Marking-',jp2file,'.txt'];
C=fileread(regionoutlinetxt);
% specification
regindr=zeros(R,1);
for r=1:R
    regind0=strfind(C,[regionlist{r},':'])+length([regionlist{r},':[[']); % start of the sequence
    if ~isempty(regind0)
        regindr(r)=regind0;
        regind1=strfind(C(regind0:end),']]'); % first encounter of ]] after the region starts
        regind1=regind1(1)+regind0-2; % end of the sequence
        regionind=C(regind0:regind1);
        regionind(strfind(regionind,'['))=[' '];
        regionind(strfind(regionind,']'))=[' '];
        regionind(strfind(regionind,','))=[' '];
        A=sscanf(regionind,'%f');
        regiondata{r}=zeros(length(A)/2,2);
        for i=1:length(A)/2
            regiondata{r}(i,:)=A((i-1)*2+1:i*2);
        end
        regiondata{r}=round(abs(regiondata{r}));
        
    end
end
if sum(regindr)==0 % unspecified with text
    nissltif=[tifdir,'/',jp2file(1:end-4),'.tif'];
    nisslsmall=imread(nissltif,'tif');
    figure, imagesc(nisslsmall)
    % identify how many regions were annotated
    delims=strfind(C,'[[');
    display(jp2file)
    cell2table(regionlist')
    % manual identification
    for r=1:length(delims) 
        %     secnum=str2num(regionoutlinetxt(end-11:end-8));
        regind0=delims(r)+length('[['); % start of the sequence
        regind1=strfind(C(regind0:end),']]'); % first encounter of ]] after the region starts
        regind1=regind1(1)+regind0-2; % end of the sequence
        regionind=C(regind0:regind1);
        regionind(strfind(regionind,'['))=[' '];
        regionind(strfind(regionind,']'))=[' '];
        regionind(strfind(regionind,','))=[' '];
        A=sscanf(regionind,'%f');
        regiondatatemp=zeros(length(A)/2,2);
        for i=1:length(A)/2
            regiondatatemp(i,:)=A((i-1)*2+1:i*2);
        end
        regiondatatemp1=round(abs(regiondatatemp))/M;
        h=impoly(gca,regiondatatemp1);
        rind=input('Please identify the index of the region: ');
        regiondata{rind}=round(abs(regiondatatemp));
        delete(h)
    end
    close(gcf)
end
%% 2. convert the cell array into coordinates
% regionoutline=cellfun(@str2num,regionoutline,'UniformOutput',false);
% regionoutline1=[];
% for i=1:size(regionoutline,2)
%     regionoutline1=[regionoutline1;round(regionoutline{i})];
% end
% regionoutline1=abs(regionoutline1);
%% 3. visualize
% nisslimg=imread(['STIF/',jp2file(1:end-4)],'tif');
% figure, imagesc(nisslimg)
% regiondatadown=cell(R,1);
% for r=1:R
%     regiondatadown{r}=round(regiondata{r}/64);
%     h=impoly(gca,regiondatadown{r});
%     pause
% end