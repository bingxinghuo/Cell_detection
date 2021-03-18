%% 1 CELL MASK: summarize into desired voxel size, isotropic
simgscale=64; % 64X downsample
disp(['Summarizing the ',detecttype,' masks into ',num2str(datainfo.voxelsize(1)),'µm volume... '])
if isempty(imgdir)
    warning(['Dataset not transformed yet. Skip ',brainID])
else
    % use tmpsavedir0 to save
    outputdir=[tmpsavedir0,brainID,'/'];
    if ~exist(outputdir,'dir')
        mkdir(outputdir)
    end
    %         % Exception: rename files due to a bug with the online annotation tool
    cd(neurondir)
    system('for filename in *.tif; do mv "$filename" "${filename//"%26"/&}"; done')
    if strcmp(datainfo.species,'mouse')
        %                 if strcmpi(datainfo.tracer,'AAV')
        neurondensity=neuronvoxelize(datainfo,tissuemaskdir,neurondir,outputdir,0,detecttype,'tif');
        %                 elseif strcmpi(datainfo.tracer,'rAAV')
        %                     % Exception: for legacy Fiji annotated files, registered masks were saved as jp2 files
        %                     % neurondensity=neuronvoxelize(datainfo,tissuemaskdir,neurondir,outputdir,0,detecttype,'jp2');
        %                 end
    elseif strcmp(datainfo.species,'marmoset')
        neurondensity=neuronvoxelize(datainfo,tissuemaskdir,neurondir,outputdir,simgscale,detecttype,'tif');
    end
end
outputfile=[outputdir,'/',brainID,'_',detecttype,'_',num2str(datainfo.voxelsize(1)),'.mat'];
%% 2 load segmentation
[r,c,S]=size(neurondensity);
% S is the number of sections
for i=1:S
    filename
    % e.g. atlas-seg_to_M826-F69--_1_0137.vtk
    [x,y,z,regmask,title,names,spacing,origin] = read_vtk_image(['atlas-seg_to_',filename,'.vtk']);
    %% 3 cell centroids for this section
    fbcelltf=FBnissl{fileinds_nissl(i)}; % each Matlab cell contains the coordinates of all cells in high resolution image
    fbcelltfdown=round(fbcelltf/simgscale); % scale down coordinates 
    if ~isempty(fbcelltfdown)
        % remove out of boundary coordinates
        [ind1,~]=find(fbcelltfdown<=0);
        ind2=find(fbcelltfdown(:,1)>imgwidth);
        ind3=find(fbcelltfdown(:,2)>imgheight);
        fbcelltfdown([ind1;ind2;ind3],:)=[];
        % read out the annotation indices
        annoid=unique(regmask); % all region IDs within the section
        annoid=nonzeros(annoid); % remove 0
                % statistics
        if length(annoids)>1
            for d=1:length(annoids)
                regcount{i}(d,1)=annoids(d); % brain region ID
                regcount{i}(annoids(d),2)=sum(annoid==annoids(d)); % count cells within individual region
            end
        end
    end
end