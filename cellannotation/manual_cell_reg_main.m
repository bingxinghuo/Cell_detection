%% manual_cell_reg_main.m
% Inputs:
%   - animalid: animal of interest e.g. 'm820'
%   - secind: indices of slides, numbers after 'F'
%   - skdir: the directory that contains all information for this particular animal
%   - annoinds: section numbers in the annotation full stack (.img files)
%   cooresponding to secind
%   - regiontable: a table containing the correspondence between region
%   indices and the brain region abbreviations
% Calling functions: filelsread.m; jp2ind.m; readcellcoord.m; cellregions.m;
% cellregionnissl.m
% animalids={'m820';'m822'}; % animals of interest
% secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
% annoinds={182+(86-secinds{1});[244;241;240;239;237;236]};
% wkdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Rosa/';
% M=64; % downsample factor
% d=1;
%     animalid=animalids{d};
%     secind=secinds{d};
% regiontable=load('regionlookup.mat'); % a pre-identified look up table for region indices and their abbreviations
% regiontable=regiontable.regiontable;
%% 1. Get cell coordinates in full resolution fluorescent images
% for d=1:2
cd(wkdir) % set working directory
% get file names
cd([animalid,'/',upper(animalid),'F-STIF/'])
filelist=filelsread('*.tif');
cd([wkdir,animalid])
S=length(secind);
fileind=zeros(S,1);
fileid=cell(S,1);
cellcoordfull=cell(S,1);
for s=1:S
    % 0. find file names corresponding to the section indices
    [fileind(s),fileid{s}]=jp2ind(filelist,['F',num2str(secind(s))]);
    % 1. load cell coordinates
    cellcoordfull{s}=readcellcoord([animalid,'_cells/cellanno/',fileid{s}(1:end-4),'.jp2.txt']);
end
save('cellfullcoord','cellcoordfull')
save('cellfileind','fileind','fileid')
% end
%%%%%%% run on BNB %%%%%%%
%% 2. generate cell masks
% cellmaskrun_partial.sh
%% 3. transform cell masks
% python ~/scripts/LGNPulvinarProj/2_fluocell2nissl/applySTSCompositeTransform_fluo_marmoset_BH.py M820 136 161 304 311
% python ~/scripts/LGNPulvinarProj/2_fluocell2nissl/applySTSCompositeTransform_fluo_marmoset_BH.py M822 178 186 320 351
%% 4. generate Nissl series
% python ~/scripts/LGNPulvinarProj/applySTSCompositeTransform_nisslatlas_BH.py M820 132 159 304 311
% python ~/scripts/LGNPulvinarProj/applySTSCompositeTransform_nisslatlas_BH.py M822 182 190 320 351
%%%%%%%% transfer files to local machine %%%%%%%
%% 5. Identify brain region
% load registered atlas
annostack=load_nii([animalid,'/',upper(animalid),'_annotation.img']);
%     nisslstack=load_nii([animalid,'/',upper(animalid),'_orig_target_STS.img']);
secind=secinds{d};
S=length(secind);
%     regioninds=cell(S,1);
load([animalid,'/',animalid,'_cells/cellfileind.mat'])  % from above
%     load([animalid,'/cellregionout.mat'])
regioncellcount=cell(S,1);
for s=1:S
    annoimg=squeeze(annostack.img(:,annoinds{d}(s),:));
    %         annoimgRH=annoimg>9000;
    %         annoimg=annoimg-annoimgRH*10000;
    % 5.1 get cell coordinates
    tfcellimgfile=[animalid,'/',animalid,'_cells/cellmask2Nissl/cell',fileid{s}(end-7:end)];
    tfcellcoord=readtfcellcoord(tfcellimgfile);
    if ~isempty(tfcellcoord)
        %%%%%%%%%%%%% Visualization 1: overlay with Nissl %%%%%%%%%%%%%%%%%
        tfnisslimg=imread([animalid,'/',animalid,'nissl/tf',fileid{s}(end-7:end)]);
        figure, imagesc(uint8(tfnisslimg))
        axis image
        axis ij
        % overlay cells
        hold on, scatter(celly,cellx,'m.')
        axis off
        saveas(gca,[animalid,'/',animalid,'_cells/cell2Nissl/',fileid{s}])
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 5.2 read out region numbers from 80µm isotropic registered atlas
        dsrate=80/0.92; % downsample rate from full resolution to atlas .img file
        tfcellcoordds=round(tfcellcoord/dsrate);
        [regionind,cellregionid]=cellregions(tfcellcoordds,annoimg);
        %%%%%%%% Visualization 2: overlay cell and brain region with Nissl 
        M=64;
        legendid={'cell'};
        R=length(regionind);
        % adjust region outlines
        regionoutlines=cell(R,1);
        for r=1:R
            regionoutlines{r}=bwboundaries(annoimg==regionind(r));
        end
        % plot everything together and count cells
        regioncellcount{s}=cellregionnissl(tfnisslimg,regionoutlines,tfcellcoord,cellregionid,regiontable,M);
        % directly save as tif image
        saveas(gca,[animalid,'/cell2atlas/',fileid{s}])
        % Alternatively, save for Adobe Illustrator
        %             alpha 1
        %             saveas(gca,[animalid,'/cell2atlas/',fileid{s}(1:end-4),'.eps'])
        close
    else
        regioncellcount{s}=zeros(R,1);
    end
end
save([animalid,'/cellregioncount'],'regioncellcount')
% end