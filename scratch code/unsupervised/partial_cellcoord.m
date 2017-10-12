%% 1. manually correct the automatically detected cells
mancell=manual_select();
%% 2. Get a zoom-in image
xl=xlim;
yl=ylim;
xl=round(xl);
yl=round(yl);
acimg=combtestimg(yl(1):yl(2),xl(1):xl(2),:);
% get new coordinates of the cells within the FOV
w=yl(2)-yl(1);
h=xl(2)-xl(1);
accells.x=mancell.new.x-xl(1);
accells.y=mancell.new.y-yl(1);
indx=find(accells.x>0);
indx=find(accells.x<h);
indy=find(accells.y>0);
indy=find(accells.y<w);
[common,ind]=ismember(indy,indx)
indmatch=indx(nonzeros(ind)); % alternatively, indmatch=indy(find(common));
accells.x=accells.x(indmatch);
accells.y=accells.y(indmatch);
%% save
fullcell.x=mancell.new.x;
fullcell.y=mancell.new.y;
save('FBcellcenters','fullcell','accells')