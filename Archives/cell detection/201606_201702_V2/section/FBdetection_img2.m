%% FBdetection_img2.m
% Bingxing Huo
% This function contains strategy for detecting all cells within the same
% image
function FBclear=FBdetection_img2(fluoroimg,imgmask,win)
%% 0. Preparation
% 0.1 initialize
FBdetected.x=[];
FBdetected.y=[];
% 0.2 parameters
hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
thresh.intensity=100;
thresh.count=10;
%% 1. detect cells within each window
for v=1:vert % then move vertically
    for h=1:hori % first move horizontally
        % 3.1 get the moving window
        imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
        if (sum(sum(imgtemp_rgb(:,:,3)>thresh.intensity))>thresh.count) % if there are at least N pixels exceed the threshold of M
            % 3.2 assemble parameter variable
            pars2.v=v;
            pars2.h=h;
            pars2.win=win;
            % 3.3 detect cells within the window
            FBdetect_win=FBdetection_win2(imgtemp_rgb,pars2);
            % 3.4 assemble detected cells in different windows
            if ~isempty(FBdetect_win.x)
                FBdetected.x=[FBdetected.x;FBdetect_win.x];
                FBdetected.y=[FBdetected.y;FBdetect_win.y];
            end
        end
    end
end
%% 2. clean up the image
    FBclear=maskclean(FBdetected,imgmask);
end