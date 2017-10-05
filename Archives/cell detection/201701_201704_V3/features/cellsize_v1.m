function L=cellsize(L)
idx=1:max(max(L));
area=regionprops(L,'Area');
for k=1:length(area)
    if area(k).Area < (2/.46)^2*pi   % cell diameter > 4 microns, with 0.46 microns/pixel resolution
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx); % remove the index
[~,L] = ismember(L,idx); % pick out only small enough cell bodies