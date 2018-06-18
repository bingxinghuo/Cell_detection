%% cellregionnissl.m
% developed based on cellonNissl_vis.m for LGN-Ipul project
% Called in manual_cell_reg_main.m
function regioncellcount=cellregionnissl(tfnisslimg,regionoutlines,tfcellcoord,cellregionid,regiontable,dsrate)
figure, hold on
% 1 Aligned Nissl image
if dsrate>1
    for c=1:3
        tfnisslimgds(:,:,c)=downsample_mean(tfnisslimg(:,:,c),dsrate);
    end
end
imagesc(uint8(tfnisslimgds))
% 2. Brain region outline
R=length(regionoutlines);
regionpoly=cell(R,1);
for r=1:R
    if ~isempty(regionoutlines{r})
        subpolys=length(regionoutlines{r});
        % reorganize into X and Y
        X=[];
        Y=[];
        for s=1:subpolys
            X=[X,{regionoutlines{r}{s}(:,2)/dsrate}];
            Y=[Y,{regionoutlines{r}{s}(:,1)/dsrate}];
        end
        regionpoly{r}=polyshape(X,Y);
    end
    plot(regionpoly{r})
end
% 3. Overlay cells
if ~isempty(tfcellcoord)
    scatter(tfcellcoord(:,1)/dsrate,tfcellcoord(:,2)/dsrate,'.')
end
% 4. statistics show in legend
regioncellcount=zeros(R,1);
countlabel_all=[]; % legend
% get all the region indices
regionind=unique(cellregionid);
regionind=nonzeros(regionind);
if length(regionind)==R
for r=1:R
    regioncellcount(r)=sum(cellregionid==regionind(r));
    if regioncellcount(r)>0
        regionid=regiontable{regionind(r)}; % read from a look up table
        countlabel=[regionid,'=',num2str(regioncellcount(r))];
        countlabel_all=[countlabel_all,',',countlabel];
    end
end
else
    error('Inconsistent number of regions!')
end
if ~isempty(countlabel_all)
    legend(countlabel_all(2:end))
end
% 5. Output cell counting results
regioncellcount=[regionind;regioncellcount];