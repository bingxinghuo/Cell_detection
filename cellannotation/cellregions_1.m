parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
marmosetlistfile='~/Documents/GITHUB/Connectivity_matrix/marmosetregionlist.mat';
targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
%%
i=8;
animalid=motorbraininfo(i).animalid;
originresolution=motorbraininfo(i).originresolution;
workpath=[parentpath,'/',animalid,'/',animalid,'F/JP2-REG/'];
load([workpath,'/FBdetectdata_consolid.mat'])
savedir=[targetdir,'/',animalid];
annoimgfile=[savedir,'/',upper(animalid),'_annotation.img'];
seclistfile=[savedir,'/',upper(animalid),'F_anno_seclist.csv']; % correspondence file
flips=[1,2];
[annoimgs,seclist]=loadannoimg(annoimgfile,seclistfile,flips);
seccorr=seclist{2};
%%
annocell=cell(length(FBclear),1);
for f=1:length(FBclear)
    if ~isempty(FBclear{f}.x)
        x1=round(FBclear{f}.x*originresolution/80);
        y1=round(FBclear{f}.y*originresolution/80);
        annocell{f}=zeros(length(x1),1);
        annomap=squeeze(annoimgs(:,40+seccorr(f),:));
        for i=1:length(x1)
            annocell{f}(i)=annomap(y1(i),x1(i));
        end
        annocell{f}=nonzeros(annocell{f});
    end
end
annocell1=cell2mat(annocell);
annocellregions=unique(annocell1);
for i=1:length(annocellregions)
    annocellregions(i,2)=sum(annocell1==annocellregions(i));
end
%% sort the output
[densitysorted,isort]=sort(annocellregions(:,2),'descend');
regionsorted=cell(size(annocellregions,1),2);
idsorted=(annocellregions(isort,1));
regionLUT=load(marmosetlistfile);
field=fieldnames(regionLUT);
regionLUT=getfield(regionLUT,field{1});
regionlistid=cell2mat(regionLUT(:,4));
for c=1:size(annocellregions,1)
    ind=find(regionlistid==idsorted(c));
    if ~isempty(ind)
        regionsorted(c,:)=regionLUT(ind,2:3);
    end
end


%% save
outputfile=[savedir,'/',animalid,'_region','cell','.csv'];
fid=fopen(outputfile,'w');

for i=1:size(regionsorted,1)
    fprintf(fid,'%d,%d,%s,%s\n',idsorted(i),densitysorted(i),regionsorted{i,:});
end

fclose(fid);