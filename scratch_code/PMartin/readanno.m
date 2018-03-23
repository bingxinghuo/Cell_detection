
function regiondata=readanno(regionoutlinetxt)
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
regiondata=cell(R,1);
%% 1. import text file as cell array
% regionoutlinetxt=['Marking-',jp2file,'.txt'];
C=fileread(regionoutlinetxt);
% identify how many regions were annotated
delims=strfind(C,'[[');
if length(delims)==1 % unspecified with text
    secnum=str2num(regionoutlinetxt(end-11:end-8));
    if secnum<=335
        regind0=strfind(C,'[[')+length('[['); % start of the sequence
        regionind=C(regind0:end);
        regionind(strfind(regionind,'['))=[' '];
        regionind(strfind(regionind,']'))=[' '];
        regionind(strfind(regionind,','))=[' '];
        A=sscanf(regionind,'%f');
        regiondata{1}=zeros(length(A)/2,2);
        for i=1:length(A)/2
            regiondata{1}(i,:)=A((i-1)*2+1:i*2);
        end
        regiondata{1}=round(abs(regiondata{1}));
        %     else      % for later use with pulvinar
    end
else    % specification
    for r=1:R
        regind0=strfind(C,[regionlist{r},':'])+length([regionlist{r},':[[']); % start of the sequence
        if ~isempty(regind0)
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