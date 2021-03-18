%% 1 summarize into desired voxel size, isotropic
simgscale=64;
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
% e.g. atlas-seg_to_M826-F69--_1_0137.vtk
[x,y,z,segimg,title,names,spacing,origin] = read_vtk_image('atlas-seg_to_M826-F69--_1_0137.vtk')
%% 3 cell centroids for this section
fbcelltf=FBnissl{fileinds_nissl(n)};
fbcelltfdown=round(fbcelltf/M);
if ~isempty(fbcelltfdown)
    % remove out of boundary coordinates
    [ind1,~]=find(fbcelltfdown<=0);
    ind2=find(fbcelltfdown(:,1)>imgwidth);
    ind3=find(fbcelltfdown(:,2)>imgheight);
    fbcelltfdown([ind1;ind2;ind3],:)=[];
    % read out the annotation indices
    annoind=zeros(size(fbcelltfdown,1),1);
    for i=1:size(fbcelltfdown,1)
        annoind(i)=regmask(fbcelltfdown(i,2),fbcelltfdown(i,1))/15;
    end
    % statistics
    annoids=unique(annoind);
    if length(annoids)>1
        annoids=nonzeros(annoids); % remove 0
        for d=1:length(annoids)
            regcount(n,annoids(d))=sum(annoind==annoids(d)); % count cells within individual region
        end
    end
end