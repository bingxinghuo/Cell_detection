function [cellsignals,boundboxs,cellmasks]=cellcut_auto(cellsignal,cellid,boundbox,Ithresh,colorspec)
global sigma sizepar eccpar
if strcmp(colorspec,'b')
    C=3;
elseif strcmp(colorspec,'g')
    C=2;
elseif strcmp(colorspec,'r')
    C=1;
elseif strcmp(colorspec,'m') % assume R and G are identical
    C=1; % use red channel to process
end
%
cellind=find(cellid);
cellsignals=[];
boundboxs=[];
cellmasks=[];
if ~isempty(cellind)
%     figure('Color',[0 0 0]) % black background for easier visualization of fluorescent images
    %
    for i=1:length(cellind)
        ic=cellind(i);
        %         cellimg=uint16(cellsignal{ic});
        cellimg=uint8(cellsignal{ic});
        cellmask0=cellimg(:,:,C)>Ithresh;
        [cellsignal1,cellmask1,boundbox1]=cellcut_tile_v2(cellmask0,cellimg,boundbox(ic));
        if ~isempty(cellsignal1{1})
            cellsignals=[cellsignals;cellsignal1];
            cellmasks=[cellmasks;cellmask1];
            boundboxs=[boundboxs;boundbox1];
        end
    end
%     close
end