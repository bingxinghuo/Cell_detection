<<<<<<< HEAD
<<<<<<< HEAD
function L=eccentricity(L,thresh)
idx=1:max(max(L));
ecc=regionprops(L,'Eccentricity');
for k=1:length(ecc)
    if ecc(k).Eccentricity>thresh % close to a line
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx); % remove the index
[~,L] = ismember(L,idx); % pick out only small enough cell bodies

%%
% imgobj=imgbit.*(L2==1); % take the image region
% [x,y]=find(L2==1);
% theta=atan(y./x); % calculate the angle of every point
% [~,ra]=minBoundingBox([x,y]'); % angle of rotational frame
% X1(1,:)=x./cos(theta).*cos(theta+pi/2-ra); % new coordinates
% X1(2,:)=x./cos(theta).*sin(theta+pi/2-ra);
% % new image
% for i=1:size(X1,2)
% imgobj1(floor(X1(1,i)),floor(X1(2,i)))=imgobj(x(i),y(i));
% end
% % variance
% imgobj1((imgobj1==0))=nan;
% histhori=nanvar(imgobj1,[],1);
% histvert=nanvar(imgobj1,[],2);
=======
=======
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
function bwimg=eccentricity(bwimg,thresh)
cc=bwconncomp(bwimg);
ecc=regionprops(cc,'Eccentricity');
idx=find([ecc.Eccentricity]<thresh);
bwimg = ismember(labelmatrix(cc),idx);  % pick out only "round" enough cell bodies
<<<<<<< HEAD
>>>>>>> e5d0bdbddf523e435e56c4836761d554711cd2bd
=======
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
