function L=cellsize(varargin)
L=varargin{1};
if nargin>1    
    sizepar=varargin{2};
else
    sizepar=[(2/.46)^2*pi,5000];
end
idx=1:max(max(L));
area=regionprops(L,'Area');
for k=1:length(area)
    if area(k).Area < sizepar(1) || area(k).Area > sizepar(2) % cell diameter > 4 microns, with 0.46 microns/pixel resolution
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx); % remove the index
[~,L] = ismember(L,idx); % pick out only small enough cell bodies