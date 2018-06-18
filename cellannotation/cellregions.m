%% cellregions.m
% Identify individual cell's correspondence with brain region
function [regionind,cellregionid]=cellregions(tfcellcoordds,annoimg)
% 5.2 read out region numbers with manual check
% 1. directly read from the corresponding region
Ncells=size(tfcellcoordds,1);
cellregionid=zeros(Ncells,1);
for i=1:Ncells
    cellregionid(i)=annoimg(tfcellcoordds(i,1),tfcellcoordds(i,2));
end
regionind=unique(cellregionid);
% 2. Manually identify cells without assignment
if sum(regionind==0)>0
    figure, ax1=imagesc(annoimg); hold on
    misscellid=find(regionind==0);
    for imiss=1:length(misscellid)
        h=scatter(tfcellcoordds(misscellid(imiss),1),tfcellcoordds(misscellid(imiss),2),'m*');
        manassign=input('Can you manually identify a brain region for this cell? (y/n) ','s');
        if manassign=='y'
            title('Please click on the brain region associated to this cell.')
            selectpt='n';
            while selectpt=='n'
                [x,y]=getpts(ax1);
                x=round(x);
                y=round(y);
                if size(x,1)==1
                    selectpt='y';
                else
                    selectpt='n';
                end
            end
            cellregionid(misscellid(imiss))=annoimg(y,x); % assign a brain region to this cell
            delete(h)
        end
    end
    regionind=unique(cellregionid);
    regionind=nonzeros(regionind);
    close
end